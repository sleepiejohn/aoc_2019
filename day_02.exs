Code.require_file("solution.exs")

defmodule Intcode do
  alias __MODULE__

  defstruct opcode: nil, pivot: 0, instructions: []

  def find_configuration(instructions, search) do
    find_pair(instructions, 1, 0, search)
  end

  defp find_pair(insutructions, n, 100, search) do
    find_pair(insutructions, n + 1, 0, search)
  end

  defp find_pair(instructions, n, v, search) do
    result =
      instructions
      |> List.update_at(1, fn _ -> n end)
      |> List.update_at(2, fn _ -> v end)
      |> Intcode.compute()
      |> Enum.at(0)

    if result == search do
      100 * n + v
    else
      find_pair(instructions, n, v + 1, search)
    end
  end

  def compute(instruction_set) when is_list(instruction_set) do
    state = %Intcode{instructions: instruction_set}
    loop(state)
  end

  defp seek(%Intcode{instructions: instructions}, position) do
    Enum.at(instructions, Enum.at(instructions, position))
  end

  defp replace(%Intcode{instructions: instructions, pivot: pivot} = state, new_value) do
    position = pivot + 3
    instruction = Enum.at(instructions, position)
    updated_instructions = List.update_at(instructions, instruction, fn _ -> new_value end)
    %Intcode{state | instructions: updated_instructions}
  end

  defp op(state, operation) do
    pivot = state.pivot
    operation.(seek(state, pivot + 1), seek(state, pivot + 2))
  end

  defp move(state) do
    %Intcode{state | pivot: state.pivot + 4}
  end

  defp replace_then_move(intcode, operation) do
    intcode
    |> replace(op(intcode, operation))
    |> move()
  end

  defp loop(intcode) do
    case Enum.at(intcode.instructions, intcode.pivot) do
      1 ->
        intcode
        |> replace_then_move(&Kernel.+/2)
        |> loop()

      2 ->
        intcode
        |> replace_then_move(&Kernel.*/2)
        |> loop()

      99 ->
        intcode.instructions
    end
  end
end

ExUnit.start()

defmodule IntcodeTests do
  use ExUnit.Case

  test "intcode machine implementation" do
    subjects = [
      {[1, 0, 0, 0, 99], [2, 0, 0, 0, 99]},
      {[2, 3, 0, 3, 99], [2, 3, 0, 6, 99]},
      {[2, 4, 4, 5, 99, 0], [2, 4, 4, 5, 99, 9801]},
      {[1, 1, 1, 4, 99, 5, 6, 0, 99], [30, 1, 1, 4, 2, 5, 6, 0, 99]}
    ]

    for {input, output} <- subjects do
      assert Intcode.compute(input) == output
    end
  end
end

Solution.part(1, fn ->
  instructions =
    File.read!("inputs/2.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

  instructions
  |> List.update_at(1, fn _ -> 12 end)
  |> List.update_at(2, fn _ -> 2 end)
  |> Intcode.compute()
  |> Enum.at(0)
end)

Solution.part(2, fn ->
  result =
    File.read!("inputs/2.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Intcode.find_configuration(19_690_720)

  IO.inspect("Two hours later: #{result}")
end)
