defmodule NasaFlightsCalculator.Calculator do
  @moduledoc """
  Calculates fuel requirements for interplanetary missions.

  The algorithm works BACKWARDS (from last action to first) because each
  earlier action must carry fuel for all subsequent actions.
  """

  alias NasaFlightsCalculator.{Mission, FlightLeg, Action}

  # Formula constants
  @launch_multiplier 0.042
  @launch_offset 33
  @land_multiplier 0.033
  @land_offset 42

  @doc """
  Calculates fuel for the entire mission.

  ## Examples

      iex> mission = %Mission{
      ...>   spacecraft_mass: 28801,
      ...>   legs: [
      ...>     FlightLeg.new(Planet.earth(), Planet.moon()),
      ...>     FlightLeg.new(Planet.moon(), Planet.earth())
      ...>   ]
      ...> }
      iex> result = Calculator.calculate_mission(mission)
      iex> Mission.total_fuel(result)
      51898
  """
  @spec calculate_mission(Mission.t()) :: Mission.t()
  def calculate_mission(%Mission{legs: []} = mission) do
    # Empty legs - no fuel needed
    mission
  end

  def calculate_mission(%Mission{spacecraft_mass: mass, legs: legs}) do
    calculated_legs = calculate_legs_backwards(legs, mass)
    %Mission{spacecraft_mass: mass, legs: calculated_legs}
  end

  # Calculates legs in REVERSE order using map_reduce.
  # Each iteration has access to the previously calculated action.
  defp calculate_legs_backwards(legs, spacecraft_mass) do
    legs
    |> Enum.reverse()
    |> Enum.map_reduce(nil, fn leg, prev_action ->
      # prev_action = previously calculated action (or nil for last leg)
      calculated_leg = calculate_leg(leg, spacecraft_mass, prev_action)

      # Return: {calculated_leg, launch_action}
      # Launch action becomes prev_action for next iteration
      {calculated_leg, calculated_leg.launch_action}
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  # Calculates one leg with both actions (land THEN launch, backwards order).
  defp calculate_leg(%FlightLeg{from: from, to: to}, spacecraft_mass, prev_action) do
    # Get fuel from previous action (or 0 if last leg)
    fuel_from_prev = if prev_action, do: prev_action.total_fuel, else: 0

    # === LAND ACTION (calculated first when going backwards) ===
    mass_at_land = spacecraft_mass + fuel_from_prev
    land_fuel = calculate_fuel(mass_at_land, :land, to.gravity)

    land_action = %Action{
      type: :land,
      planet: to,
      spacecraft_mass: spacecraft_mass,
      additional_mass: fuel_from_prev,
      subtotal_mass: mass_at_land,
      fuel_for_action: land_fuel,
      total_fuel: fuel_from_prev + land_fuel,
      total_mass: mass_at_land + land_fuel
    }

    # === LAUNCH ACTION (calculated second, carries land fuel) ===
    mass_at_launch = spacecraft_mass + land_action.total_fuel
    launch_fuel = calculate_fuel(mass_at_launch, :launch, from.gravity)

    launch_action = %Action{
      type: :launch,
      planet: from,
      spacecraft_mass: spacecraft_mass,
      additional_mass: land_action.total_fuel,
      subtotal_mass: mass_at_launch,
      fuel_for_action: launch_fuel,
      total_fuel: land_action.total_fuel + launch_fuel,
      total_mass: mass_at_launch + launch_fuel
    }

    %FlightLeg{
      from: from,
      to: to,
      launch_action: launch_action,
      land_action: land_action
    }
  end

  # Calculates fuel with recursive "fuel for fuel" logic using guards.
  defp calculate_fuel(mass, _type, _gravity) when mass <= 0, do: 0

  defp calculate_fuel(mass, type, gravity) do
    fuel = calculate_single_action(mass, type, gravity)
    fuel + calculate_fuel(fuel, type, gravity)
  end

  # Calculates fuel for a single action WITHOUT recursion.
  #
  # Formulas:
  # - Launch: mass * gravity * 0.042 - 33 (rounded down)
  # - Land: mass * gravity * 0.033 - 42 (rounded down)
  # - Minimum: 0 (negative fuel = 0)
  defp calculate_single_action(mass, :launch, gravity) do
    (mass * gravity * @launch_multiplier - @launch_offset)
    |> floor()
    |> max(0)
  end

  defp calculate_single_action(mass, :land, gravity) do
    (mass * gravity * @land_multiplier - @land_offset)
    |> floor()
    |> max(0)
  end
end
