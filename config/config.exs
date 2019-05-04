# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :omise_phoenix,
  ecto_repos: [OmisePhoenix.Repo]

# Configures the endpoint
config :omise_phoenix, OmisePhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SKa9y61uOrN+JU1C5UpfHvnz26SIpfTu/nlv4HZHtDs7VfApCQdxyvfLt8+Wu9+B",
  render_errors: [view: OmisePhoenixWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: OmisePhoenix.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
