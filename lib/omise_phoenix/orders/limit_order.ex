defmodule OmisePhoenix.Orders.LimitOrder do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @command_types ["sell", "buy"]

  schema "limit_orders" do
    field :command, :string
    field :price, :decimal
    field :amount, :decimal

    timestamps()
  end

  @doc false
  def changeset(limit_order, attrs) do
    limit_order
    |> cast(attrs, [:command, :price, :amount])
    |> validate_required([:command, :price, :amount])
    |> validate_inclusion(:command, @command_types)
  end

  # queries

  def id_in(query, ids) do
    from(lo in query, where: lo.id in ^ids)
  end
end
