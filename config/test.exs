use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :the_lean_cafe, TheLeanCafe.Endpoint,
  http: [port: 4001],
  server: true,
  sql_sandbox: true

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
