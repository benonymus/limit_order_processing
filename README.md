


# OmisePhoenix

To start the container:
  * Clone the repo
  * Go into omise_phoenix folder
  * run: docker-compose run --rm --service-ports omise /bin/bash
  * only for the first time:
  * ---
  * mix deps.get
  * mix ecto.create
  * mix ecto.migrate
  * ---
  * mix phx.server

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Start the container by:

docker-compose run --rm --service-ports omise /bin/bash
only for the first time:
mix ecto.create
mix ecto.migrate
and then mix phx.server
