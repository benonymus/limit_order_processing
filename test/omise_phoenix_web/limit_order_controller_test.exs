defmodule OmisePhoenixWeb.LimitOrderControllerTest do
  use OmisePhoenixWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create limit_order" do
    test "successful transactions for example 1", %{conn: conn} do
      orders = %{
        "orders" => [
          %{"command" => "sell", "price" => 100.003, "amount" => 2.4},
          %{"command" => "buy", "price" => 90.394, "amount" => 3.445}
        ]
      }

      conn =
        conn
        |> post("/api/limit-orders/", orders)

      order_book = json_response(conn, 200)

      result = %{
        "buy" => [
          %{
            "price" => "90.394",
            "volume" => "3.445"
          }
        ],
        "sell" => [
          %{
            "price" => "100.003",
            "volume" => "2.4"
          }
        ]
      }

      assert order_book == result
    end

    test "successful transactions for example 2", %{conn: conn} do
      orders = %{
        "orders" => [
          %{"command" => "sell", "price" => 100.003, "amount" => 2.4},
          %{"command" => "buy", "price" => 90.394, "amount" => 3.445},
          %{"command" => "buy", "price" => 89.394, "amount" => 4.3},
          %{"command" => "sell", "price" => 100.013, "amount" => 2.2},
          %{"command" => "buy", "price" => 90.15, "amount" => 1.305},
          %{"command" => "buy", "price" => 90.394, "amount" => 1.0}
        ]
      }

      conn =
        conn
        |> post("/api/limit-orders/", orders)

      order_book = json_response(conn, 200)

      result = %{
        "buy" => [
          %{
            "price" => "90.394",
            "volume" => "4.445"
          },
          %{
            "price" => "90.15",
            "volume" => "1.305"
          },
          %{
            "price" => "89.394",
            "volume" => "4.3"
          }
        ],
        "sell" => [
          %{
            "price" => "100.003",
            "volume" => "2.4"
          },
          %{
            "price" => "100.013",
            "volume" => "2.2"
          }
        ]
      }

      assert order_book == result
    end

    test "successful transactions for example 3", %{conn: conn} do
      orders = %{
        "orders" => [
          %{"command" => "sell", "price" => 100.003, "amount" => 2.4},
          %{"command" => "buy", "price" => 90.394, "amount" => 3.445},
          %{"command" => "buy", "price" => 89.394, "amount" => 4.3},
          %{"command" => "sell", "price" => 100.013, "amount" => 2.2},
          %{"command" => "buy", "price" => 90.15, "amount" => 1.305},
          %{"command" => "buy", "price" => 90.394, "amount" => 1.0},
          %{"command" => "sell", "price" => 90.394, "amount" => 2.2}
        ]
      }

      conn =
        conn
        |> post("/api/limit-orders/", orders)

      order_book = json_response(conn, 200)

      result = %{
        "buy" => [
          %{
            "price" => "90.394",
            "volume" => "2.245"
          },
          %{
            "price" => "90.15",
            "volume" => "1.305"
          },
          %{
            "price" => "89.394",
            "volume" => "4.3"
          }
        ],
        "sell" => [
          %{
            "price" => "100.003",
            "volume" => "2.4"
          },
          %{
            "price" => "100.013",
            "volume" => "2.2"
          }
        ]
      }

      assert order_book == result
    end

    test "successful transactions for example 4", %{conn: conn} do
      orders = %{
        "orders" => [
          %{"command" => "sell", "price" => 100.003, "amount" => 2.4},
          %{"command" => "buy", "price" => 90.394, "amount" => 3.445},
          %{"command" => "buy", "price" => 89.394, "amount" => 4.3},
          %{"command" => "sell", "price" => 100.013, "amount" => 2.2},
          %{"command" => "buy", "price" => 90.15, "amount" => 1.305},
          %{"command" => "buy", "price" => 90.394, "amount" => 1.0},
          %{"command" => "sell", "price" => 90.394, "amount" => 2.2},
          %{"command" => "sell", "price" => 90.15, "amount" => 3.4},
          %{"command" => "buy", "price" => 91.33, "amount" => 1.8},
          %{"command" => "buy", "price" => 100.01, "amount" => 4.0},
          %{"command" => "sell", "price" => 100.15, "amount" => 3.8}
        ]
      }

      conn =
        conn
        |> post("/api/limit-orders/", orders)

      order_book = json_response(conn, 200)

      result = %{
        "buy" => [
          %{
            "price" => "100.01",
            "volume" => "1.6"
          },
          %{
            "price" => "91.33",
            "volume" => "1.8"
          },
          %{
            "price" => "90.15",
            "volume" => "0.15"
          },
          %{
            "price" => "89.394",
            "volume" => "4.3"
          }
        ],
        "sell" => [
          %{
            "price" => "100.013",
            "volume" => "2.2"
          },
          %{
            "price" => "100.15",
            "volume" => "3.8"
          }
        ]
      }

      assert order_book == result
    end
  end
end
