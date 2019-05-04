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
    for id <- limit_order_ids do
      get_limit_order_by_id(id)
    end
  end

  defp get_limit_order_by_id(id) do
    LimitOrder
    |> Repo.get_by(id: id)
  end
end
