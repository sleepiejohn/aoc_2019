defmodule DayOne do
  @doc """
  Calculate the fuel needed for a given mass.
  """
  def fuel(mass), do: div(mass, 3) - 2

  @spec modules_fuel_requirement(list) :: integer
  def modules_fuel_requirement(module_masses) do
    module_masses
    |> Enum.map(&fuel/1)
    |> Enum.sum()
  end

  @spec spaceship_fuel(list) :: integer
  def spaceship_fuel(masses) do
    masses
    |> Enum.map(&fuel_of_fuel/1)
    |> Enum.sum()
  end

  def fuel_of_fuel(fuel_mass) do
    case fuel(fuel_mass) do
      needed when needed > 0 -> needed + fuel_of_fuel(needed)
      _ -> 0
    end
  end
end

ExUnit.start()

defmodule DayOneTests do
  use ExUnit.Case

  test "fuel requirement for a given mass" do
    subjects = [{12, 2}, {14, 2}, {1969, 654}, {100_756, 33_583}]

    for {mass, expectation} <- subjects do
      assert expectation == DayOne.fuel(mass)
    end
  end

  test "calculate fuel needed to power the fuel of a module" do
    subject = [{[1969], 966}, {[100_756], 50346}]

    for {module_masses, expectation} <- subject do
      assert expectation == DayOne.spaceship_fuel(module_masses)
    end
  end
end
