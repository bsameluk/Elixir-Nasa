defmodule NasaFlightsCalculator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NasaFlightsCalculatorWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:nasa_flights_calculator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NasaFlightsCalculator.PubSub},
      # Start a worker by calling: NasaFlightsCalculator.Worker.start_link(arg)
      # {NasaFlightsCalculator.Worker, arg},
      # Start to serve requests, typically the last entry
      NasaFlightsCalculatorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NasaFlightsCalculator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NasaFlightsCalculatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
