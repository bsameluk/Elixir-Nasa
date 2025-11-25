defmodule NasaFlightsCalculator.Planet do
  @moduledoc """
  Represents a celestial body with gravitational characteristics.

  Pre-created instances for Earth, Moon, and Mars are available as module constants.
  """

  defstruct [:id, :name, :gravity]

  @type t :: %__MODULE__{
          id: atom(),
          name: String.t(),
          gravity: float()
        }

  # Note: Due to Elixir compilation order, we can't use struct literals in module attributes
  # when defining the struct in the same module. Using functions with inline structs instead.
  # These are still optimized by the compiler and effectively act as constants.

  @doc """
  Returns Earth planet instance.
  """
  @spec earth() :: t()
  def earth, do: %__MODULE__{id: :earth, name: "Earth", gravity: 9.807}

  @doc """
  Returns Moon planet instance.
  """
  @spec moon() :: t()
  def moon, do: %__MODULE__{id: :moon, name: "Moon", gravity: 1.62}

  @doc """
  Returns Mars planet instance.
  """
  @spec mars() :: t()
  def mars, do: %__MODULE__{id: :mars, name: "Mars", gravity: 3.711}

  @doc """
  Returns all available planets.
  """
  @spec all() :: [t()]
  def all, do: [earth(), moon(), mars()]

  @doc """
  Finds a planet by its ID.

  ## Examples

      iex> Planet.find(:earth)
      %Planet{id: :earth, name: "Earth", gravity: 9.807}

      iex> Planet.find(:invalid)
      nil
  """
  @spec find(atom()) :: t() | nil
  def find(planet_id) do
    Enum.find(all(), &(&1.id == planet_id))
  end
end
