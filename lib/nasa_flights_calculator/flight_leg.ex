defmodule NasaFlightsCalculator.FlightLeg do
  @moduledoc """
  Represents one leg of a flight path (from one planet to another).

  A leg consists of two actions:
  - launch_action: launching from the source planet
  - land_action: landing on the destination planet

  Total fuel is calculated via getter from the actions.
  """

  alias NasaFlightsCalculator.{Planet, Action}

  @enforce_keys [:from, :to]
  defstruct [:from, :to, :launch_action, :land_action]

  @type t :: %__MODULE__{
          from: Planet.t(),
          to: Planet.t(),
          launch_action: Action.t() | nil,
          land_action: Action.t() | nil
        }

  @doc """
  Creates a new flight leg without calculated fuel.
  """
  @spec new(Planet.t(), Planet.t()) :: t()
  def new(from, to) do
    %__MODULE__{from: from, to: to}
  end

  @doc """
  Calculates total fuel for this leg from its actions.

  Returns sum of launch and landing fuel.
  """
  @spec total_fuel(t()) :: non_neg_integer()
  def total_fuel(%__MODULE__{launch_action: nil, land_action: nil}), do: 0

  def total_fuel(%__MODULE__{launch_action: launch, land_action: land}) do
    launch_fuel = if launch, do: launch.fuel_for_action, else: 0
    land_fuel = if land, do: land.fuel_for_action, else: 0
    launch_fuel + land_fuel
  end
end
