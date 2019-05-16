defmodule OmisePhoenix.Orders do
  @moduledoc """
  The Orders context.
  """
  alias OmisePhoenix.Repo
  alias OmisePhoenix.Orders.LimitOrder
  alias Ecto.Multi

  def create_limit_orders(orders) do
    Enum.with_index(orders)
    |> Enum.reduce(Multi.new(), fn order_with_index, multi ->
      {order, index} = order_with_index
      limit_order = "limit_order_#{index}"

      multi
      |> Multi.insert(limit_order, LimitOrder.changeset(%LimitOrder{}, order))
    end)
    |> Repo.transaction()
  end

  defp get_order(id) do
    LimitOrder
    |> LimitOrder.incomplete()
    |> Repo.get_by(id: id)
  end

  defp get_incomplete_orders(ids, command \\ nil) do
    LimitOrder
    |> LimitOrder.id_in(ids)
    |> LimitOrder.incomplete()
    |> LimitOrder.by_command(command)
    |> Repo.all()
  end

  def get_limit_orders_by_id_list(ids) do
    LimitOrder
    |> LimitOrder.id_in(ids)
    |> Repo.all()
    |> matching_engine(ids)
  end

  defp matching_engine(orders, ids) do
    Enum.each(orders, fn order ->
      order = get_order(order.id)

      if order do
        add_same_price(order, ids)
      end
    end)

    Enum.each(orders, fn order ->
      order = get_order(order.id)

      if order do
        sell_vs_buy(order, ids)
      end
    end)

    get_incomplete_orders(ids)
  end

  defp add_same_price(order, ids) do
    filtered_order_book = get_incomplete_orders(ids, order.command)

    same_price_orders =
      filtered_order_book
      |> Enum.filter(fn x -> Decimal.cmp(x.price, order.price) == :eq and x.id != order.id end)

    summed_order =
      Enum.reduce(same_price_orders, order, fn x, acc ->
        amount_sum = Decimal.add(x.amount, acc.amount)

        LimitOrder.changeset_update_amount_completed(x, %{completed: true, amount: x.amount})
        |> Repo.update()

        Map.put(acc, :amount, amount_sum)
      end)

    LimitOrder.changeset_update_amount_completed(order, %{
      completed: summed_order.completed,
      amount: summed_order.amount
    })
    |> Repo.update()
  end

  defp sell_vs_buy(order, ids) do
    if order.command == "buy" do
      buy(order, ids)
    end
  end

  defp buy(order, ids) do
    filtered_order_book = get_incomplete_orders(ids, "sell")

    possible_sells =
      filtered_order_book
      |> Enum.filter(fn x ->
        Decimal.cmp(x.price, order.price) == :lt or Decimal.cmp(x.price, order.price) == :eq
      end)

    summed_order =
      Enum.reduce(possible_sells, order, fn x, acc ->
        if Decimal.cmp(acc.amount, Decimal.new(0)) == :gt do
          case Decimal.cmp(x.amount, acc.amount) do
            :eq ->
              LimitOrder.changeset_update_amount_completed(x, %{completed: true, amount: x.amount})
              |> Repo.update()

              Map.put(acc, :completed, true)

            :lt ->
              new_acc_amount = Decimal.sub(acc.amount, x.amount)

              LimitOrder.changeset_update_amount_completed(x, %{completed: true, amount: x.amount})
              |> Repo.update()

              Map.put(acc, :amount, new_acc_amount)

            :gt ->
              new_x_amount = Decimal.sub(x.amount, acc.amount)

              LimitOrder.changeset_update_amount_completed(x, %{
                completed: x.completed,
                amount: new_x_amount
              })
              |> Repo.update()

              Map.put(acc, :completed, true)
          end
        end
      end)

    LimitOrder.changeset_update_amount_completed(order, %{
      completed: summed_order.completed,
      amount: summed_order.amount
    })
    |> Repo.update()
  end
end
