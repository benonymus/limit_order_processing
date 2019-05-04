defmodule OmisePhoenix.OrdersTest do
  use OmisePhoenix.DataCase

  alias OmisePhoenix.Orders

  describe "limit_orders" do
    alias OmisePhoenix.Orders.LimitOrder

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def limit_order_fixture(attrs \\ %{}) do
      {:ok, limit_order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_limit_order()

      limit_order
    end

    test "list_limit_orders/0 returns all limit_orders" do
      limit_order = limit_order_fixture()
      assert Orders.list_limit_orders() == [limit_order]
    end

    test "get_limit_order!/1 returns the limit_order with given id" do
      limit_order = limit_order_fixture()
      assert Orders.get_limit_order!(limit_order.id) == limit_order
    end

    test "create_limit_order/1 with valid data creates a limit_order" do
      assert {:ok, %LimitOrder{} = limit_order} = Orders.create_limit_order(@valid_attrs)
      assert limit_order.name == "some name"
    end

    test "create_limit_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_limit_order(@invalid_attrs)
    end

    test "update_limit_order/2 with valid data updates the limit_order" do
      limit_order = limit_order_fixture()
      assert {:ok, %LimitOrder{} = limit_order} = Orders.update_limit_order(limit_order, @update_attrs)
      assert limit_order.name == "some updated name"
    end

    test "update_limit_order/2 with invalid data returns error changeset" do
      limit_order = limit_order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_limit_order(limit_order, @invalid_attrs)
      assert limit_order == Orders.get_limit_order!(limit_order.id)
    end

    test "delete_limit_order/1 deletes the limit_order" do
      limit_order = limit_order_fixture()
      assert {:ok, %LimitOrder{}} = Orders.delete_limit_order(limit_order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_limit_order!(limit_order.id) end
    end

    test "change_limit_order/1 returns a limit_order changeset" do
      limit_order = limit_order_fixture()
      assert %Ecto.Changeset{} = Orders.change_limit_order(limit_order)
    end
  end
end
