defmodule Two do
  def part_one(input) do
    {x, y} =
      input
      |> parse()
      |> Enum.reduce({0, 0}, fn
        {"up", n}, {x, y} -> {x, y - n}
        {"down", n}, {x, y} -> {x, y + n}
        {"forward", n}, {x, y} -> {x + n, y}
      end)
    x * y
  end

  def part_two(input) do
    {{x, y}, _aim} =
      input
      |> parse()
      |> Enum.reduce({{0, 0}, 0}, fn
        {"up", n}, {{x, y}, aim} -> {{x, y}, aim - n}
        {"down", n}, {{x, y}, aim} -> {{x, y}, aim + n}
        {"forward", n}, {{x, y}, aim} -> {{x + n, y + (aim * n)}, aim}
      end)
    x * y
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [d, n] -> {d, String.to_integer(n)} end)
  end
end

input = File.read!("input/02.txt")

input
|> Two.part_one()
|> IO.inspect(label: "part 1")

input
|> Two.part_two()
|> IO.inspect(label: "part 2")
