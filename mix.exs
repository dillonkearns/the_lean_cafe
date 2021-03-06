defmodule TheLeanCafe.Mixfile do
  use Mix.Project

  def project do
    [app: :the_lean_cafe,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {TheLeanCafe, []},
     applications: app_list(Mix.env)]
  end

  def app_list(:test) do
    [:hound | default_app_list]
  end

  def app_list(_) do
    default_app_list
  end

  def default_app_list do
    [:ex_machina, :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                   :phoenix_ecto, :postgrex, :ueberauth_github, :timex]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:ex_unit_notifier, "~> 0.1", only: :test},
     {:ueberauth_github, "~> 0.4"},
     {:ex_machina, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:hound, "~> 1.0", only: :test},
     {:cowboy, "~> 1.0"},
     {:timex, "~> 3.0"},
     {:timex_ecto, "~> 3.0"},
     {:hashids, "~> 2.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
