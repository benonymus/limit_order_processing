defmodule OmisePhoenixWeb.LimitOrderController do
  use OmisePhoenixWeb, :controller

  alias OmisePhoenix.Orders
  alias OmisePhoenix.Orders.LimitOrder
  alias OmisePhoenixWeb.LimitOrderView

  action_fallback OmisePhoenixWeb.FallbackController

  def limit_order(conn, %{"orders" => orders}) when is_list(orders) do
    with(
      {:ok, limit_orders} <- Orders.create_limit_orders(orders),
      limit_order_ids =
        Map.to_list(limit_orders)
        |> Enum.map(fn {_, x} -> x.id end),
      limit_orders = Orders.get_limit_orders_by_id_list(limit_order_ids)
    ) do
      conn
      |> put_status(200)
      |> put_view(LimitOrderView)
      |> render("limit_orders.json",
        limit_orders: limit_orders
      )
    end
  end
end