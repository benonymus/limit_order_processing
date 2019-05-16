defmodule OmisePhoenix.Orders.LimitOrder do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @command_types ["sell", "buy"]

  schema "limit_orders" do
    field :command, :string
    field :price, :decimal
    field :amount, :decimal
    field :completed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(limit_order, attrs) do
    limit_order
    |> cast(attrs, [:command, :price, :amount])
    |> validate_required([:command, :price, :amount])
    |> validate_inclusion(:command, @command_types)
  end

  def changeset_update_amount_completed(limit_order, attrs) do
    limit_order
    |> cast(attrs, [:completed, :amount])
  end

  # queries

  def id_in(query, ids) do
    from(lo in query, where: lo.id in ^ids)
  end

  def incomplete(query) do
    from(lo in query, where: lo.completed == false)
  end

  def by_command(query, command) when is_nil(command), do: query

  def by_command(query, command) do
    from(lo in query, where: lo.command == ^command)
  end
end
