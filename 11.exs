defmodule Eleven do
  @steps 100

  def part_one(input) do
    input
    |> parse()
    |> simulate(@steps)
  end

  def part_two(input) do
    input
    |> parse()
    |> synchronize()
  end

  defp parse(text) do
    lines = text |> String.trim() |> String.split(~r/\R/)
    for {row, y} <- Enum.with_index(lines),
        {n, x} <- Enum.with_index(String.to_charlist(row)),
        into: %{} do
      {{x, y}, n - ?0}
    end
  end

  defp simulate(grid, steps, flashes \\ 0)
  defp simulate(_grid, 0, flashes), do: flashes
  defp simulate(grid, steps, flashes) do
    {new_grid, flashed} = grid |> increase() |> flash()
    simulate(new_grid, steps - 1, flashes + flashed)
  end

  defp synchronize(grid, steps \\ 0) do
    case grid |> increase() |> flash() do
      {_, 100} -> steps + 1
      {new_grid, _} -> synchronize(new_grid, steps + 1)
    end
  end

  defp increase(grid) do
    grid
    |> Enum.map(fn {pos, n} -> {pos, n + 1} end)
    |> Enum.into(%{})
  end

  defp flash(grid, flashed \\ 0) do
    case Enum.find(grid, fn {_pos, n} -> n > 9 end) do
      nil ->
        {grid, flashed}
      {to_flash, _} ->
        to_flash
        |> neighbours()
        |> Enum.reduce(grid, fn pos, acc ->
          case Map.get(acc, pos) do
            nil -> acc
            0 -> acc
            _ -> Map.update!(acc, pos, &(&1 + 1))
          end
        end)
        |> Map.put(to_flash, 0)
        |> flash(flashed + 1)
    end
  end

  defp neighbours({x, y}) do
    for a <- (x-1)..(x+1),
        b <- (y-1)..(y+1),
        {a, b} != {x, y} do
      {a, b}
    end
  end
end

input = File.read!("input/11.txt")

input |> Eleven.part_one() |> IO.inspect(label: "part 1")
input |> Eleven.part_two() |> IO.inspect(label: "part 2")
