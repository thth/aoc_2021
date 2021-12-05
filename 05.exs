defmodule Five do
  def part_one(input) do
    input
    |> parse()
    |> Enum.filter(fn {{x1, y1}, {x2, y2}} -> x1 == x2 or y1 == y2 end)
    |> map_ocean()
    |> Enum.count(fn {_, n} -> n >= 2 end)
  end

  def part_two(input) do
    input
    |> parse()
    |> map_ocean()
    |> Enum.count(fn {_, n} -> n >= 2 end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn str -> str |> String.split(",") |> Enum.map(&String.to_integer/1) end)
    end)
    |> Enum.map(fn [[x1, y1], [x2, y2]] -> {{x1, y1}, {x2, y2}} end)
  end

  defp map_ocean(lines) do
    Enum.reduce(lines, %{}, fn
      {{x, y1}, {x, y2}}, map ->
        y1..y2
        |> Enum.reduce(map, fn y, acc ->
          Map.update(acc, {x, y}, 1, &(&1 + 1))
        end)
      {{x1, y}, {x2, y}}, map ->
        x1..x2
        |> Enum.reduce(map, fn x, acc ->
          Map.update(acc, {x, y}, 1, &(&1 + 1))
        end)
      {{x1, y1}, {x2, y2}}, map ->
        0..abs(x2 - x1)
        |> Enum.reduce(map, fn n, acc ->
          Map.update(acc, {Enum.at(x1..x2, n), Enum.at(y1..y2, n)}, 1, &(&1 + 1))
        end)
    end)
  end
end

input = File.read!("input/05.txt")

input
|> Five.part_one()
|> IO.inspect(label: "part 1")

input
|> Five.part_two()
|> IO.inspect(label: "part 2")
