defmodule OmisePhoenixWeb.LimitOrderView do
  use OmisePhoenixWeb, :view
  alias OmisePhoenixWeb.LimitOrderView

  def render("limit_orders.json", %{limit_orders: limit_orders}) do
    buy =
      Enum.filter(limit_orders, fn x -> x.command == "buy" end)
      |> render_many(LimitOrderView, "limit_order.json")

    sell =
      Enum.filter(limit_orders, fn x -> x.command == "sell" end)
      |> render_many(LimitOrderView, "limit_order.json")

    %{buy: buy, sell: sell}
  end

  def render("limit_order.json", %{limit_order: limit_order}) do
    %{
      id: limit_order.id,
      command: limit_order.command,
      amount: limit_order.amount,
      price: limit_order.price
    }
  end
end
