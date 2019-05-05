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

  def get_limit_orders_by_id_list(limit_order_ids) do
    LimitOrder
    |> LimitOrder.id_in(limit_order_ids)
    |> Repo.all()
    |> transactions()
  end

  defp transactions(limit_orders) do
    for order <- limit_orders do
      Enum.reduce(
        limit_orders,
        order,
        fn x, y ->
          cond do
            Decimal.cmp(x.price, y.price) == :eq and x.id != y.id and x.command == y.command ->
              new_amount = Decimal.add(x.amount, y.amount)
              Map.put(y, :amount, new_amount)

            Decimal.cmp(x.price, y.price) == :eq and x.command != y.command ->
              case Decimal.cmp(x.amount, y.amount) do
                :gt ->
                  new_amount = Decimal.sub(x.amount, y.amount)
                  Map.put(x, :amount, new_amount)

                :lt ->
                  new_amount = Decimal.sub(y.amount, x.amount)
                  Map.put(y, :amount, new_amount)

                :eq ->
                  nil
              end

            true ->
              y
          end
        end
      )
    end
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.uniq_by(fn x -> x.price end)
  end
end
