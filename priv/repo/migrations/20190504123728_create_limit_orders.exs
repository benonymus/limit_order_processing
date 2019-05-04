defmodule OmisePhoenix.Repo.Migrations.CreateLimitOrders do
  use Ecto.Migration

  def change do
    create table(:limit_orders) do
      add :command, :string
      add :price, :decimal
      add :amount, :decimal

      timestamps()
    end

  end
end
