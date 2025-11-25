defmodule NasaFlightsCalculator.Action do
  @moduledoc """
  Represents a single action (launch or land) in a flight path.

  Structure matches test.md calculation breakdown:
  - spacecraft_mass: base mass of the spacecraft (constant)
  - additional_mass: fuel needed for all subsequent actions
  - subtotal_mass: spacecraft_mass + additional_mass
  - fuel_for_action: fuel required for THIS action (calculated recursively)
  - total_fuel: additional_mass + fuel_for_action
  - total_mass: subtotal_mass + fuel_for_action
  """

  alias NasaFlightsCalculator.Planet

  @enforce_keys [:type, :planet]
  defstruct [
    :type,
    :planet,
    spacecraft_mass: 0,
    additional_mass: 0,
    subtotal_mass: 0,
    fuel_for_action: 0,
    total_fuel: 0,
    total_mass: 0
  ]

  @type t :: %__MODULE__{
          type: :launch | :land,
          planet: Planet.t(),
          spacecraft_mass: non_neg_integer(),
          additional_mass: non_neg_integer(),
          subtotal_mass: non_neg_integer(),
          fuel_for_action: non_neg_integer(),
          total_fuel: non_neg_integer(),
          total_mass: non_neg_integer()
        }
end
