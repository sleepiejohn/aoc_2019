defmodule Solution do
  def part(part, solver) do
    result = solver.()
    IO.puts("Part #{part}: #{inspect(result)}")
  end
end
