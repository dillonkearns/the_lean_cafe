use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :the_lean_cafe, TheLeanCafe.Endpoint,
  http: [port: 4001],
  server: true

config :the_lean_cafe, sql_sandbox: true

config :hound, driver: System.get_env("WEBDRIVER") || "chrome_driver"

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :the_lean_cafe, TheLeanCafe.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  database: "the_lean_cafe_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
