defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.count(fn [a, b] -> b > a end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.count(fn [a, b] -> b > a end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.to_integer/1)
  end
end

input = File.read!("input/01.txt")

input
|> One.part_one()
|> IO.inspect(label: "part 1")

input
|> One.part_two()
|> IO.inspect(label: "part 2")
