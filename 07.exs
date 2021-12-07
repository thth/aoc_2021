defmodule Seven do
  def part_one(input) do
    crabs = parse(input)

    Enum.min(crabs)..Enum.max(crabs)
    |> Enum.map(&calc_fuel(&1, crabs))
    |> Enum.min()
  end

  def part_two(input) do
    crabs = parse(input)

    Enum.min(crabs)..Enum.max(crabs)
    |> Enum.map(&triangle_fuel(&1, crabs))
    |> Enum.min()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/,/)
    |> Enum.map(&String.to_integer/1)
  end

  defp calc_fuel(n, crabs) do
    crabs
    |> Enum.map(fn x -> abs(x - n) end)
    |> Enum.sum()
  end

  defp triangle_fuel(n, crabs) do
    crabs
    |> Enum.map(fn x -> abs(x - n) end)
    |> Enum.map(&triangle/1)
    |> Enum.sum()
  end

  defp triangle(n) do
    div(n * (n + 1), 2)
  end
end

input = File.read!("input/07.txt")

input
|> Seven.part_one()
|> IO.inspect(label: "part 1")

input
|> Seven.part_two()
|> IO.inspect(label: "part 2")
