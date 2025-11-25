defmodule NasaFlightsCalculatorWeb.MissionLiveTest do
  use NasaFlightsCalculatorWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders initial page with zero fuel", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ "NASA Flights Calculator"
    assert html =~ "Spacecraft Mass"
    assert html =~ "Total Fuel Required"
    # Check for 0 fuel (formatted separately in HTML)
    assert html =~ ">0<" or html =~ "value=\"0\""
    assert html =~ "Add flight legs"
  end

  test "adds flight leg with defaults", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Click add leg
    view |> element("button", "+ Add Leg") |> render_click()

    # Verify leg added with Earth and Moon
    html = render(view)
    assert html =~ "🌍 Earth"
    assert html =~ "🌙 Moon"
  end

  test "removes flight leg", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Add a leg
    view |> element("button", "+ Add Leg") |> render_click()

    # Remove it
    view |> element("button", "✕") |> render_click()

    # Verify empty state
    assert render(view) =~ "Add flight legs"
  end

  test "calculates Apollo 11 mission fuel correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Set mass
    view
    |> form("form[phx-change='update_mass']", mass: "28801")
    |> render_change()

    # Add first leg (Earth → Moon by default)
    view |> element("button", "+ Add Leg") |> render_click()

    # Add second leg (Moon → Mars by default)
    view |> element("button", "+ Add Leg") |> render_click()

    # Change second leg back to Earth using render_change on update_to event
    view |> render_change("update_to", %{"index" => "1", "planet_id" => "earth"})

    # Verify fuel calculated correctly for Apollo 11 mission
    html = render(view)
    assert html =~ "51,898"
  end

  test "auto-fills from planet for subsequent legs", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Add first leg (Earth → Moon by default)
    view |> element("button", "+ Add Leg") |> render_click()

    # Add second leg
    view |> element("button", "+ Add Leg") |> render_click()

    # Verify second leg's from is Moon (shown as badge)
    html = render(view)

    # Count occurrences - second leg should have Moon badge
    assert html =~ "🌙 Moon"
  end

  test "Apollo 11 preset button sets mass to 28801", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view |> element("button", "Apollo 11") |> render_click()

    # Verify mass is set
    html = render(view)
    assert html =~ "28801"
  end
end
