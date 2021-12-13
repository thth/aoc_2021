defmodule Thirteen do
  def part_one(input) do
    {dots, [fold | _rest]} = parse(input)

    step(dots, fold)
    |> Enum.count()
  end

  def part_two(input) do
    {dots, folds} = parse(input)
    code = fold(dots, folds)

    {{min_x, _}, {max_x, _}} = Enum.min_max_by(code, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(code, fn {_, y} -> y end)

    min_y..max_y
    |> Enum.each(fn y ->
      IO.write("\n")
      Enum.each(min_x..max_x, fn x ->
        if {x, y} in code, do: IO.write("#"), else: IO.write(".")
      end)
    end)
  end

  defp parse(text) do
    [nums, ins] =
      text
      |> String.trim()
      |> String.split(~r/\R\R/)
    dots =
      nums
      |> String.split(~r/[^\d]/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)
    folds =
      ins
      |> String.split(~r/\R/)
      |> Enum.map(&(&1 |> String.split([" ", "="]) |> Enum.take(-2)))
      |> Enum.map(fn [l, n] -> {l, String.to_integer(n)} end)
    {dots, folds}
  end

  defp fold(dots, []), do: dots
  defp fold(dots, [ins | rest]), do: dots |> step(ins) |> fold(rest)

  defp step(dots, ins), do: step(dots, [], ins)
  defp step([], folded, _), do: Enum.uniq(folded)
  defp step([{dx, dy} | rest], folded, {"x", x}) when dx < x, do: step(rest, [{dx, dy} | folded], {"x", x})
  defp step([{x, _dy} | rest], folded, {"x", x}), do: step(rest, folded, {"x", x})
  defp step([{dx, dy} | rest], folded, {"x", x}), do: step(rest, [{2 * x - dx, dy} | folded], {"x", x})
  defp step([{dx, dy} | rest], folded, {"y", y}) when dy < y, do: step(rest, [{dx, dy} | folded], {"y", y})
  defp step([{_dx, y} | rest], folded, {"y", y}), do: step(rest, folded, {"y", y})
  defp step([{dx, dy} | rest], folded, {"y", y}), do: step(rest, [{dx, 2 * y - dy} | folded], {"y", y})
end

input = File.read!("input/13.txt")

input |> Thirteen.part_one() |> IO.inspect(label: "part 1")
input |> Thirteen.part_two()
