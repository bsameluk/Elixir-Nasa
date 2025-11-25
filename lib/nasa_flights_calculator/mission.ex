defmodule NasaFlightsCalculator.Mission do
  @moduledoc """
  Represents a complete space mission with spacecraft mass and flight path.

  A mission consists of:
  - spacecraft_mass: the base mass of the spacecraft (without fuel)
  - legs: list of flight legs (from planet to planet)

  Total fuel is calculated via getter from the first action's total_fuel.
  """

  alias NasaFlightsCalculator.FlightLeg

  defstruct spacecraft_mass: 0, legs: []

  @type t :: %__MODULE__{
          spacecraft_mass: non_neg_integer(),
          legs: [FlightLeg.t()]
        }

  @doc """
  Creates a new mission with the given spacecraft mass.
  """
  @spec new(non_neg_integer()) :: t()
  def new(spacecraft_mass) do
    %__MODULE__{spacecraft_mass: spacecraft_mass, legs: []}
  end

  @doc """
  Calculates total fuel for the mission.

  Returns the first action's total_fuel (which carries all mission fuel
  due to backwards calculation algorithm).
  """
  @spec total_fuel(t()) :: non_neg_integer()
  def total_fuel(%__MODULE__{legs: []}), do: 0

  def total_fuel(%__MODULE__{legs: legs}) do
    case List.first(legs) do
      %{launch_action: %{total_fuel: total}} -> total
      _ -> 0
    end
  end
end
