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
    |> split_buy_and_sell()
  end

  defp split_buy_and_sell(limit_orders) do
    buy =
      Enum.filter(limit_orders, fn x -> x.command == "buy" end)
      |> sum_same_prices()
      |> Enum.sort(&(Decimal.cmp(&1.price, &2.price) != :lt))

    sell =
      Enum.filter(limit_orders, fn x -> x.command == "sell" end)
      |> sum_same_prices()
      |> Enum.sort(&(Decimal.cmp(&1.price, &2.price) != :gt))

    %{buy: buy, sell: sell}
  end

  defp sum_same_prices(limit_orders) do
    for order <- limit_orders do
      Enum.reduce(
        limit_orders,
        order,
        fn x, y ->
          cond do
            Decimal.cmp(x.price, y.price) == :eq and x.id != y.id ->
              new_amount = Decimal.add(x.amount, y.amount)
              Map.put(y, :amount, new_amount)

            true ->
              y
          end
        end
      )
    end
    |> Enum.uniq_by(fn x -> x.price end)
  end
end
