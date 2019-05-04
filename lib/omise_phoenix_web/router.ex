defmodule OmisePhoenixWeb.Router do
  use OmisePhoenixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OmisePhoenixWeb do
    pipe_through :api
    post("/limit-order", LimitOrderController, :limit_order)
  end
end
