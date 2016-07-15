# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :pickems,
  ecto_repos: [Pickems.Repo]

# Configures the endpoint
config :pickems, Pickems.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "kzofrno1GMIPWm0w+VM4QSyp7CiMemyV2cJtzgMw1kGp+Ty5P5TlXNsi4/0UrlLz",
  render_errors: [accepts: ~w(json)],
  pubsub: [name: Pickems.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :format_encoders,
  "json-api": Poison

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Pickems",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: "shNyrTciR33ly+qhZsgyFaOcarKUBFcgSsdNht2zz4Ha/VsywvdKgZnLQpwn3R1Q",
  serializer: Pickems.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
