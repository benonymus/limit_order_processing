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

  def get_limit_orders_by_id_list(ids) do
    LimitOrder
    |> LimitOrder.id_in(ids)
    |> Repo.all()
  end

  def get_incomplete_orders(ids, command \\ nil) do
    LimitOrder
    |> LimitOrder.id_in(ids)
    |> LimitOrder.incomplete()
    |> LimitOrder.by_command(command)
    |> Repo.all()
  end

  defp get_order(id) do
    LimitOrder
    |> LimitOrder.incomplete()
    |> Repo.get_by(id: id)
  end

  def add_matching_prices(orders, ids) do
    Enum.map(orders, fn order ->
      order = get_order(order.id)

      {result, _} = add_same_price(order, ids)

      result
    end)
    |> Enum.all?(fn x -> x == :ok end)
  end

  defp add_same_price(order, _ids) when is_nil(order), do: {:ok, nil}

  defp add_same_price(order, ids) do
    filtered_order_book = get_incomplete_orders(ids, order.command)

    same_price_orders =
      filtered_order_book
      |> Enum.filter(fn x -> Decimal.cmp(x.price, order.price) == :eq and x.id != order.id end)

    %{order: summed_order, multi: multi} =
      Enum.reduce(same_price_orders, %{order: order, multi: Multi.new()}, fn x, acc ->
        amount_sum = Decimal.add(x.amount, acc.order.amount)

        changeset =
          LimitOrder.changeset_update_amount_completed(x, %{
            completed: true,
            amount: x.amount
          })

        %{
          order: Map.put(acc.order, :amount, amount_sum),
          multi: Multi.update(acc.multi, x.id, changeset)
        }
      end)

    multi
    |> Multi.update(
      summed_order.id,
      LimitOrder.changeset_update_amount_completed(order, %{
        completed: summed_order.completed,
        amount: summed_order.amount
      })
    )
    |> Repo.transaction()
  end

  def matching_engine(orders, ids) do
    Enum.each(orders, fn order ->
      order = get_order(order.id)

      if order && order.command == "buy" do
        buy(order, ids)
      end
    end)
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
