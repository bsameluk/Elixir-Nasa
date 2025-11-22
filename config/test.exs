import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nasa_flights_calculator, NasaFlightsCalculatorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "x4qmmMn4gl/XjN2yayjsCyyiSXG+gP5PeOh4KU5JCM/Dn+4egJ+K1Ovre+fm/Zi/",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
