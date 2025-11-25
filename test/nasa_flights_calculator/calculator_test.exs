defmodule NasaFlightsCalculator.CalculatorTest do
  use ExUnit.Case, async: true

  alias NasaFlightsCalculator.{Calculator, Mission, FlightLeg, Planet}

  describe "calculate_mission/1" do
    test "Apollo 11 Mission: Earth → Moon → Earth" do
      # Equipment mass: 28801 kg
      # Expected total fuel: 51898 kg
      mission = %Mission{
        spacecraft_mass: 28801,
        legs: [
          FlightLeg.new(Planet.earth(), Planet.moon()),
          FlightLeg.new(Planet.moon(), Planet.earth())
        ]
      }

      result = Calculator.calculate_mission(mission)

      assert Mission.total_fuel(result) == 51_898
      assert length(result.legs) == 2

      # Verify individual legs
      [leg1, leg2] = result.legs

      # Leg 1: Earth → Moon
      assert leg1.from.id == :earth
      assert leg1.to.id == :moon
      assert leg1.launch_action.fuel_for_action == 32_988
      assert leg1.land_action.fuel_for_action == 2_462
      assert FlightLeg.total_fuel(leg1) == 35_450

      # Leg 2: Moon → Earth
      assert leg2.from.id == :moon
      assert leg2.to.id == :earth
      assert leg2.launch_action.fuel_for_action == 3_001
      assert leg2.land_action.fuel_for_action == 13_447
      assert FlightLeg.total_fuel(leg2) == 16_448
    end

    test "Mars Mission: Earth → Mars → Earth" do
      # Equipment mass: 14606 kg
      # Expected total fuel: 33388 kg
      mission = %Mission{
        spacecraft_mass: 14_606,
        legs: [
          FlightLeg.new(Planet.earth(), Planet.mars()),
          FlightLeg.new(Planet.mars(), Planet.earth())
        ]
      }

      result = Calculator.calculate_mission(mission)

      assert Mission.total_fuel(result) == 33_388
    end

    test "Passenger Ship Mission: Earth → Moon → Mars → Earth" do
      # Equipment mass: 75432 kg
      # Expected total fuel: 212161 kg
      mission = %Mission{
        spacecraft_mass: 75_432,
        legs: [
          FlightLeg.new(Planet.earth(), Planet.moon()),
          FlightLeg.new(Planet.moon(), Planet.mars()),
          FlightLeg.new(Planet.mars(), Planet.earth())
        ]
      }

      result = Calculator.calculate_mission(mission)

      assert Mission.total_fuel(result) == 212_161
      assert length(result.legs) == 3
    end

    test "Empty legs returns zero fuel" do
      mission = %Mission{
        spacecraft_mass: 1000,
        legs: []
      }

      result = Calculator.calculate_mission(mission)

      assert Mission.total_fuel(result) == 0
      assert result.legs == []
    end

    test "Zero spacecraft mass returns zero fuel" do
      mission = %Mission{
        spacecraft_mass: 0,
        legs: [
          FlightLeg.new(Planet.earth(), Planet.moon())
        ]
      }

      result = Calculator.calculate_mission(mission)

      assert Mission.total_fuel(result) == 0
    end
  end

  describe "backwards calculation verification" do
    test "Apollo 11: verify detailed action breakdown matches test.md" do
      mission = %Mission{
        spacecraft_mass: 28_801,
        legs: [
          FlightLeg.new(Planet.earth(), Planet.moon()),
          FlightLeg.new(Planet.moon(), Planet.earth())
        ]
      }

      result = Calculator.calculate_mission(mission)
      [leg1, leg2] = result.legs

      # Action 1: Launch from Earth (calculated LAST, carries all fuel)
      assert leg1.launch_action.spacecraft_mass == 28_801
      assert leg1.launch_action.additional_mass == 18_910
      assert leg1.launch_action.subtotal_mass == 47_711
      assert leg1.launch_action.fuel_for_action == 32_988
      assert leg1.launch_action.total_fuel == 51_898
      assert leg1.launch_action.total_mass == 80_699

      # Action 2: Land on Moon
      assert leg1.land_action.spacecraft_mass == 28_801
      assert leg1.land_action.additional_mass == 16_448
      assert leg1.land_action.subtotal_mass == 45_249
      assert leg1.land_action.fuel_for_action == 2_462
      assert leg1.land_action.total_fuel == 18_910
      assert leg1.land_action.total_mass == 47_711

      # Action 3: Launch from Moon
      assert leg2.launch_action.spacecraft_mass == 28_801
      assert leg2.launch_action.additional_mass == 13_447
      assert leg2.launch_action.subtotal_mass == 42_248
      assert leg2.launch_action.fuel_for_action == 3_001
      assert leg2.launch_action.total_fuel == 16_448
      assert leg2.launch_action.total_mass == 45_249

      # Action 4: Land on Earth (calculated FIRST, no additional fuel)
      assert leg2.land_action.spacecraft_mass == 28_801
      assert leg2.land_action.additional_mass == 0
      assert leg2.land_action.subtotal_mass == 28_801
      assert leg2.land_action.fuel_for_action == 13_447
      assert leg2.land_action.total_fuel == 13_447
      assert leg2.land_action.total_mass == 42_248
    end
  end
end
