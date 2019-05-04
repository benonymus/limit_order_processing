defmodule OmisePhoenixWeb.LimitOrderControllerTest do
  use OmisePhoenixWeb.ConnCase

  alias OmisePhoenix.Orders
  alias OmisePhoenix.Orders.LimitOrder

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:limit_order) do
    {:ok, limit_order} = Orders.create_limit_order(@create_attrs)
    limit_order
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all limit_orders", %{conn: conn} do
      conn = get(conn, Routes.limit_order_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create limit_order" do
    test "renders limit_order when data is valid", %{conn: conn} do
      conn = post(conn, Routes.limit_order_path(conn, :create), limit_order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.limit_order_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.limit_order_path(conn, :create), limit_order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update limit_order" do
    setup [:create_limit_order]

    test "renders limit_order when data is valid", %{conn: conn, limit_order: %LimitOrder{id: id} = limit_order} do
      conn = put(conn, Routes.limit_order_path(conn, :update, limit_order), limit_order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.limit_order_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, limit_order: limit_order} do
      conn = put(conn, Routes.limit_order_path(conn, :update, limit_order), limit_order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete limit_order" do
    setup [:create_limit_order]

    test "deletes chosen limit_order", %{conn: conn, limit_order: limit_order} do
      conn = delete(conn, Routes.limit_order_path(conn, :delete, limit_order))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.limit_order_path(conn, :show, limit_order))
      end
    end
  end

  defp create_limit_order(_) do
    limit_order = fixture(:limit_order)
    {:ok, limit_order: limit_order}
  end
end
