# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :the_lean_cafe,
  ecto_repos: [TheLeanCafe.Repo]

# Configures the endpoint
config :the_lean_cafe, TheLeanCafe.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iid/ad7MrQ8H8vOisYcNl1E0SvAhCtWUW2VFgo+IZjgKz1GAGP32n1NAcFeYtCx3",
  render_errors: [view: TheLeanCafe.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TheLeanCafe.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
