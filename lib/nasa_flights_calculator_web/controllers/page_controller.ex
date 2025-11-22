defmodule NasaFlightsCalculatorWeb.PageController do
  use NasaFlightsCalculatorWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
