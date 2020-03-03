# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :app,
  ecto_repos: [App.Repo]

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Mb1pN9FGZsKX9mLjaSig4hMfnPu8NWBMqunKG3Tgr298jjfpk+cV/MaUR36uhjAp",
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: App.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "Q9eKnlQM"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :fields, Fields.AES,
  keys:
    System.get_env("ENCRYPTION_KEYS")
    # remove single-quotes around key list in .env
    |> String.replace("'", "")
    # split the CSV list of keys
    |> String.split(",")
    # decode the key.
    |> Enum.map(fn key -> :base64.decode(key) end)

config :fields, Fields, secret_key_base: System.get_env("SECRET_KEY_BASE")

# https://hexdocs.pm/joken/introduction.html#usage
config :joken, default_signer: System.get_env("SECRET_KEY_BASE")
