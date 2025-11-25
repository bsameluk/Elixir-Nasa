defmodule NasaFlightsCalculatorWeb.MissionLive do
  use NasaFlightsCalculatorWeb, :live_view

  alias NasaFlightsCalculator.{Calculator, Mission, FlightLeg, Planet}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        mission: %Mission{spacecraft_mass: 0, legs: []},
        mass_error: nil,
        available_planets: Planet.all(),
        expanded_legs: MapSet.new()
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 py-8 px-4">
      <div class="container mx-auto max-w-6xl">
        <%!-- Header --%>
        <div class="text-center mb-8">
          <h1 class="text-4xl md:text-5xl font-bold text-white mb-2">
            🚀 NASA Flights Calculator
          </h1>
          <p class="text-slate-400">Interplanetary Mission Fuel Planning</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          <%!-- Spacecraft Mass Input --%>
          <div class="lg:col-span-1">
            <div class="card bg-slate-800/50 backdrop-blur border border-slate-700 shadow-xl h-full">
              <div class="card-body p-6">
                <h2 class="text-2xl font-semibold text-slate-200 mb-2">Spacecraft Mass</h2>
                <form phx-change="update_mass" phx-submit="prevent_submit">
                  <input
                    type="number"
                    name="mass"
                    value={@mission.spacecraft_mass}
                    phx-debounce="300"
                    class="input bg-slate-900 border-slate-600 text-white text-2xl font-mono w-full focus:border-blue-500 focus:ring-2 focus:ring-blue-500/50"
                    min="0"
                    placeholder="0"
                  />
                  <div class="text-sm text-slate-500 mt-2">kilograms</div>
                  <%= if @mass_error do %>
                    <div class="mt-2">
                      <span class="text-sm text-red-400">{@mass_error}</span>
                    </div>
                  <% end %>
                </form>

                <%!-- Preset Buttons --%>
                <div class="mt-4 flex gap-2">
                  <button
                    class="btn btn-sm btn-outline border-slate-600 text-slate-300 hover:bg-slate-700"
                    phx-click="set_preset_mass"
                    phx-value-mass="28801"
                  >
                    Apollo 11
                  </button>
                  <button
                    class="btn btn-sm btn-outline border-slate-600 text-slate-300 hover:bg-slate-700"
                    phx-click="set_preset_mass"
                    phx-value-mass="32658"
                  >
                    Artemis I
                  </button>
                </div>
              </div>
            </div>
          </div>

          <%!-- Total Fuel Display --%>
          <div class="lg:col-span-2">
            <div class="card bg-gradient-to-br from-blue-600 to-purple-600 shadow-2xl border border-blue-500/30 h-full">
              <div class="card-body p-6 flex flex-col justify-center">
                <h1 class="text-2xl font-semibold text-blue-100 mb-2">Total Fuel Required</h1>
                <p class="text-5xl md:text-6xl font-bold text-white font-mono tracking-tight flex items-center">
                  <span>
                    {format_number(Mission.total_fuel(@mission))}
                    <span class="text-2xl font-normal text-blue-100">kg</span>
                  </span>
                </p>
              </div>
            </div>
          </div>
        </div>

        <%!-- Flight Legs Configuration --%>
        <div class="card bg-slate-800/50 backdrop-blur border border-slate-700 shadow-xl mb-8">
          <div class="card-body">
            <div class="flex items-center justify-between mb-4">
              <h2 class="card-title text-xl text-slate-200">Flight Path</h2>
              <button class="btn btn-sm btn-primary" phx-click="add_leg">
                + Add Leg
              </button>
            </div>

            <%= if @mission.legs == [] do %>
              <div class="text-center py-12 text-slate-400">
                <div class="text-5xl mb-3">🛸</div>
                <p>Add flight legs to build your mission path</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for {leg, index} <- Enum.with_index(@mission.legs) do %>
                  <div class="bg-slate-900/50 border border-slate-700 rounded-lg p-4 hover:border-slate-600 transition">
                    <div class="flex items-center gap-3 flex-wrap">
                      <span class="text-lg font-bold text-slate-400 w-8">#{index + 1}</span>

                      <%!-- From Select/Badge --%>
                      <div class="flex items-center gap-2">
                        <span class="text-sm text-slate-500">From:</span>
                        <%= if index == 0 do %>
                          <form phx-change="update_from">
                            <input type="hidden" name="index" value={index} />
                            <select
                              name="planet_id"
                              class="select select-sm bg-slate-800 border-slate-600 text-white"
                            >
                              <%= for planet <- @available_planets do %>
                                <option value={planet.id} selected={leg.from.id == planet.id}>
                                  {planet_emoji(planet)} {planet.name}
                                </option>
                              <% end %>
                            </select>
                          </form>
                        <% else %>
                          <span class="badge badge-lg bg-slate-700 border-slate-600 text-white">
                            {planet_emoji(leg.from)} {leg.from.name}
                          </span>
                        <% end %>
                      </div>

                      <span class="text-xl text-slate-600">→</span>

                      <%!-- To Select --%>
                      <div class="flex items-center gap-2">
                        <span class="text-sm text-slate-500">To:</span>
                        <form phx-change="update_to">
                          <input type="hidden" name="index" value={index} />
                          <select
                            name="planet_id"
                            class="select select-sm bg-slate-800 border-slate-600 text-white"
                          >
                            <%= for planet <- @available_planets do %>
                              <option value={planet.id} selected={leg.to.id == planet.id}>
                                {planet_emoji(planet)} {planet.name}
                              </option>
                            <% end %>
                          </select>
                        </form>
                      </div>

                      <div class="flex-1"></div>

                      <%!-- Details Toggle --%>
                      <button
                        class="btn btn-sm btn-ghost text-slate-400 hover:text-white"
                        phx-click="toggle_details"
                        phx-value-index={index}
                      >
                        <%= if MapSet.member?(@expanded_legs, index) do %>
                          ▲ Hide
                        <% else %>
                          ▼ Details
                        <% end %>
                      </button>

                      <%!-- Remove Button --%>
                      <button
                        class="btn btn-sm btn-error btn-outline"
                        phx-click="remove_leg"
                        phx-value-index={index}
                      >
                        ✕
                      </button>
                    </div>

                    <%!-- Collapsible Details --%>
                    <%= if MapSet.member?(@expanded_legs, index) do %>
                      <div class="mt-4 pt-4 border-t border-slate-700">
                        <div class="grid grid-cols-2 gap-4">
                          <%= if leg.launch_action do %>
                            <div class="bg-orange-500/10 border border-orange-500/30 rounded-lg p-3">
                              <div class="text-sm font-semibold text-orange-400 mb-3">
                                🚀 Launch from {leg.from.name}
                              </div>
                              <div class="text-xs text-slate-400 space-y-1.5">
                                <div class="flex justify-between">
                                  <span>Additional Fuel:</span>
                                  <span class="text-white font-mono">
                                    {format_number(leg.launch_action.additional_mass)} kg
                                  </span>
                                </div>
                                <div class="flex justify-between">
                                  <span>Fuel for Launch:</span>
                                  <span class="text-white font-mono">
                                    {format_number(leg.launch_action.fuel_for_action)} kg
                                  </span>
                                </div>
                                <div class="flex justify-between border-t border-orange-500/20 pt-1.5">
                                  <span class="font-semibold">Total Fuel:</span>
                                  <span class="text-white font-mono font-semibold">
                                    {format_number(leg.launch_action.total_fuel)} kg
                                  </span>
                                </div>
                                <div class="flex justify-between">
                                  <span>Total Mass:</span>
                                  <span class="text-white font-mono">
                                    {format_number(leg.launch_action.total_mass)} kg
                                  </span>
                                </div>
                              </div>
                            </div>
                          <% end %>
                          <%= if leg.land_action do %>
                            <div class="bg-green-500/10 border border-green-500/30 rounded-lg p-3">
                              <div class="text-sm font-semibold text-green-400 mb-3">
                                🛬 Land on {leg.to.name}
                              </div>
                              <div class="text-xs text-slate-400 space-y-1.5">
                                <div class="flex justify-between">
                                  <span>Additional Fuel:</span>
                                  <span class="text-white font-mono">
                                    {format_number(leg.land_action.additional_mass)} kg
                                  </span>
                                </div>
                                <div class="flex justify-between">
                                  <span>Fuel for Landing:</span>
                                  <span class="text-white font-mono">
                                    {format_number(leg.land_action.fuel_for_action)} kg
                                  </span>
                                </div>
                                <div class="flex justify-between border-t border-green-500/20 pt-1.5">
                                  <span class="font-semibold">Total Fuel:</span>
                                  <span class="text-white font-mono font-semibold">
                                    {format_number(leg.land_action.total_fuel)} kg
                                  </span>
                                </div>
                                <div class="flex justify-between">
                                  <span>Total Mass:</span>
                                  <span class="text-white font-mono">
                                    {format_number(leg.land_action.total_mass)} kg
                                  </span>
                                </div>
                              </div>
                            </div>
                          <% end %>
                        </div>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Journey Timeline Visualization --%>
        <%= if @mission.legs != [] do %>
          <div class="card bg-slate-800/50 backdrop-blur border border-slate-700 shadow-xl mb-8">
            <div class="card-body">
              <h2 class="card-title text-xl text-slate-200 mb-6">Journey Visualization</h2>

              <div class="relative py-6">
                <div class="flex items-center justify-between">
                  <%!-- Render planets and connections --%>
                  <%= for {planet, planet_index} <- get_journey_planets(@mission.legs) |> Enum.with_index() do %>
                    <%!-- Planet Point --%>
                    <div class="relative z-10 flex flex-col items-center group">
                      <div class="text-5xl hover:scale-110 transition-transform duration-200 cursor-default mb-2">
                        {planet_emoji(planet)}
                      </div>
                      <div class="text-sm font-semibold text-white bg-slate-700 px-3 py-1 rounded-full">
                        {planet.name}
                      </div>
                    </div>

                    <%!-- Connection Line (if not last planet) --%>
                    <%= if planet_index < length(get_journey_planets(@mission.legs)) - 1 do %>
                      <div class="flex-1 relative px-4 group">
                        <%!-- Get corresponding leg --%>
                        <% leg = Enum.at(@mission.legs, planet_index) %>

                        <%!-- Connection Line with Fuel Info --%>
                        <div class="relative">
                          <%!-- Line --%>
                          <div class="h-1 bg-gradient-to-r from-blue-500 via-purple-500 to-blue-500 rounded-full">
                          </div>

                          <%!-- Fuel Label (always visible) --%>
                          <div class="absolute top-3 left-1/2 transform -translate-x-1/2">
                            <div class="bg-slate-800 border border-slate-600 rounded-lg px-3 py-1 text-center whitespace-nowrap">
                              <div class="text-xs text-slate-400">Leg {planet_index + 1}</div>
                              <div class="font-mono text-sm text-white font-bold">
                                {format_number(FlightLeg.total_fuel(leg))} kg
                              </div>
                            </div>
                          </div>

                          <%!-- Hover Tooltip --%>
                          <div class="absolute hidden group-hover:block top-16 left-1/2 transform -translate-x-1/2 z-20">
                            <div class="bg-slate-900 border border-slate-600 rounded-lg shadow-2xl p-4 w-64">
                              <div class="text-sm font-semibold text-slate-200 mb-3">
                                {planet_emoji(leg.from)} {leg.from.name} → {planet_emoji(leg.to)} {leg.to.name}
                              </div>

                              <%= if leg.launch_action do %>
                                <div class="mb-2 pb-2 border-b border-slate-700">
                                  <div class="text-xs text-orange-400 mb-1">🚀 Launch</div>
                                  <div class="flex justify-between text-xs">
                                    <span class="text-slate-400">Fuel:</span>
                                    <span class="text-white font-mono">
                                      {format_number(leg.launch_action.fuel_for_action)} kg
                                    </span>
                                  </div>
                                  <div class="flex justify-between text-xs">
                                    <span class="text-slate-400">Mass:</span>
                                    <span class="text-white font-mono">
                                      {format_number(leg.launch_action.subtotal_mass)} kg
                                    </span>
                                  </div>
                                </div>
                              <% end %>

                              <%= if leg.land_action do %>
                                <div>
                                  <div class="text-xs text-green-400 mb-1">🛬 Landing</div>
                                  <div class="flex justify-between text-xs">
                                    <span class="text-slate-400">Fuel:</span>
                                    <span class="text-white font-mono">
                                      {format_number(leg.land_action.fuel_for_action)} kg
                                    </span>
                                  </div>
                                  <div class="flex justify-between text-xs">
                                    <span class="text-slate-400">Mass:</span>
                                    <span class="text-white font-mono">
                                      {format_number(leg.land_action.subtotal_mass)} kg
                                    </span>
                                  </div>
                                </div>
                              <% end %>
                            </div>
                          </div>
                        </div>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update_mass", %{"mass" => mass_str}, socket) do
    case parse_mass(mass_str) do
      {:ok, mass} ->
        mission = %Mission{socket.assigns.mission | spacecraft_mass: mass}

        socket =
          socket
          |> assign(:mission, mission)
          |> assign(:mass_error, nil)
          |> recalculate_mission()

        {:noreply, socket}

      {:error, reason} ->
        socket = assign(socket, :mass_error, reason)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_leg", _params, socket) do
    mission = socket.assigns.mission

    # Determine from planet for new leg
    from_planet =
      case List.last(mission.legs) do
        nil ->
          # First leg - default to Earth
          Planet.earth()

        last_leg ->
          # Subsequent legs - from = previous leg's to
          last_leg.to
      end

    # Default to planet - next in sequence
    to_planet = get_next_default_planet(from_planet)

    new_leg = FlightLeg.new(from_planet, to_planet)

    updated_mission = %Mission{mission | legs: mission.legs ++ [new_leg]}

    socket =
      socket
      |> assign(:mission, updated_mission)
      |> recalculate_mission()

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_leg", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    mission = socket.assigns.mission

    updated_mission = %Mission{mission | legs: List.delete_at(mission.legs, index)}

    socket =
      socket
      |> assign(:mission, updated_mission)
      |> update(:expanded_legs, fn expanded ->
        # Remove from expanded set and adjust indices
        expanded
        |> MapSet.delete(index)
        |> Enum.map(fn i -> if i > index, do: i - 1, else: i end)
        |> MapSet.new()
      end)
      |> recalculate_mission()

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_from", %{"index" => index_str, "planet_id" => planet_id_str}, socket) do
    index = String.to_integer(index_str)
    planet_id = String.to_atom(planet_id_str)
    planet = Planet.find(planet_id)

    mission = socket.assigns.mission

    updated_legs =
      List.update_at(mission.legs, index, fn leg ->
        %FlightLeg{leg | from: planet}
      end)

    updated_mission = %Mission{mission | legs: updated_legs}

    socket =
      socket
      |> assign(:mission, updated_mission)
      |> recalculate_mission()

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_to", %{"index" => index_str, "planet_id" => planet_id_str}, socket) do
    index = String.to_integer(index_str)
    planet_id = String.to_atom(planet_id_str)
    planet = Planet.find(planet_id)

    mission = socket.assigns.mission

    # Update current leg's to
    updated_legs =
      List.update_at(mission.legs, index, fn leg ->
        %FlightLeg{leg | to: planet}
      end)

    # Update next leg's from (if exists)
    updated_legs =
      if index + 1 < length(updated_legs) do
        List.update_at(updated_legs, index + 1, fn leg ->
          %FlightLeg{leg | from: planet}
        end)
      else
        updated_legs
      end

    updated_mission = %Mission{mission | legs: updated_legs}

    socket =
      socket
      |> assign(:mission, updated_mission)
      |> recalculate_mission()

    {:noreply, socket}
  end

  @impl true
  def handle_event("prevent_submit", _params, socket) do
    # Do nothing - prevent form submission on Enter key
    {:noreply, socket}
  end

  @impl true
  def handle_event("set_preset_mass", %{"mass" => mass_str}, socket) do
    mass = String.to_integer(mass_str)
    mission = %Mission{socket.assigns.mission | spacecraft_mass: mass}

    socket =
      socket
      |> assign(:mission, mission)
      |> assign(:mass_error, nil)
      |> recalculate_mission()

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_details", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)

    socket =
      update(socket, :expanded_legs, fn expanded ->
        if MapSet.member?(expanded, index) do
          MapSet.delete(expanded, index)
        else
          MapSet.put(expanded, index)
        end
      end)

    {:noreply, socket}
  end

  # Recalculates the mission fuel based on current state
  defp recalculate_mission(socket) do
    calculated_mission = Calculator.calculate_mission(socket.assigns.mission)
    assign(socket, :mission, calculated_mission)
  end

  # Parses and validates spacecraft mass input
  defp parse_mass(mass_str) when mass_str == "" do
    {:ok, 0}
  end

  defp parse_mass(mass_str) do
    case Integer.parse(mass_str) do
      {mass, _} when mass >= 0 ->
        {:ok, mass}

      {_mass, _} ->
        {:error, "Mass must be a positive number"}

      :error ->
        {:error, "Please enter a valid number"}
    end
  end

  # Gets unique planets in journey order
  defp get_journey_planets([]), do: []

  defp get_journey_planets(legs) do
    # Start with first leg's from planet
    first_planet = List.first(legs).from

    # Add each leg's to planet
    journey = [first_planet | Enum.map(legs, & &1.to)]

    # Return unique planets in order (keep duplicates for visualization)
    journey
  end

  # Gets the next logical planet for default selection
  defp get_next_default_planet(%Planet{id: :earth}), do: Planet.moon()
  defp get_next_default_planet(%Planet{id: :moon}), do: Planet.mars()
  defp get_next_default_planet(%Planet{id: :mars}), do: Planet.earth()

  # Returns emoji for planet
  defp planet_emoji(%Planet{id: :earth}), do: "🌍"
  defp planet_emoji(%Planet{id: :moon}), do: "🌙"
  defp planet_emoji(%Planet{id: :mars}), do: "🔴"

  # Formats a number with thousand separators
  defp format_number(number) do
    number
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end
end
