defmodule NasaFlightsCalculatorWeb.Router do
  use NasaFlightsCalculatorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NasaFlightsCalculatorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NasaFlightsCalculatorWeb do
    pipe_through :browser

    live "/", MissionLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", NasaFlightsCalculatorWeb do
  #   pipe_through :api
  # end
end
