defmodule OmisePhoenix.Repo do
  use Ecto.Repo,
    otp_app: :omise_phoenix,
    adapter: Ecto.Adapters.Postgres
end
