defmodule OmisePhoenixWeb.LimitOrderView do
  use OmisePhoenixWeb, :view
  alias OmisePhoenixWeb.LimitOrderView

  def render("limit_orders.json", %{limit_orders: limit_orders}) do
    buy =
      limit_orders.buy
      |> render_many(LimitOrderView, "limit_order.json")

    sell =
      limit_orders.sell
      |> render_many(LimitOrderView, "limit_order.json")

    %{buy: buy, sell: sell}
  end

  def render("limit_order.json", %{limit_order: limit_order}) do
    %{
      price: limit_order.price,
      volume: limit_order.amount
    }
  end
end
