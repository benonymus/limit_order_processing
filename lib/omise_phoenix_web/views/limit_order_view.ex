defmodule OmisePhoenixWeb.LimitOrderView do
  use OmisePhoenixWeb, :view
  alias OmisePhoenixWeb.LimitOrderView

  def render("limit_orders.json", %{limit_orders: limit_orders}) do
    buy =
      Enum.filter(limit_orders, fn x -> x.command == "buy" end)
      |> render_many(LimitOrderView, "limit_order.json")
      |> Enum.sort(&(Decimal.cmp(&1.price, &2.price) != :lt))

    sell =
      Enum.filter(limit_orders, fn x -> x.command == "sell" end)
      |> render_many(LimitOrderView, "limit_order.json")
      |> Enum.sort(&(Decimal.cmp(&1.price, &2.price) != :gt))

    %{buy: buy, sell: sell}
  end

  def render("limit_order.json", %{limit_order: limit_order}) do
    %{
      price: limit_order.price,
      volume: limit_order.amount
    }
  end
end
