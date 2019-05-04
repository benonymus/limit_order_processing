defmodule OmisePhoenixWeb.Router do
  use OmisePhoenixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OmisePhoenixWeb do
    pipe_through :api
  end
end
