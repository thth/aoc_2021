defmodule Eight do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn {_, out} -> out end)
    |> List.flatten()
    |> Enum.count(&(MapSet.size(&1) in [2, 3, 4, 7]))
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&decode/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split([" ", "|"], trim: true)
      |> Stream.map(&String.graphemes/1)
      |> Stream.map(&MapSet.new/1)
      |> Enum.split(-4)
    end)
  end

  defp decode({signals, outputs}) do
    signal_map = solve_digits(signals)

    outputs
    |> Enum.map(&(signal_map[&1]))
    |> Enum.join()
    |> String.to_integer()
  end

  defp solve_digits(digits) do
    d1 = Enum.find(digits, &(MapSet.size(&1) == 2))
    d4 = Enum.find(digits, &(MapSet.size(&1) == 4))
    d7 = Enum.find(digits, &(MapSet.size(&1) == 3))
    d8 = Enum.find(digits, &(MapSet.size(&1) == 7))
    d3 = digits |> Enum.filter(&(MapSet.size(&1) == 5)) |> Enum.find(&(MapSet.subset?(d1, &1)))
    d6 = digits |> Enum.filter(&(MapSet.size(&1) == 6)) |> Enum.find(&(MapSet.union(&1, d1) == d8))
    d9 = MapSet.union(d3, d4)
    [d0] = digits |> Enum.filter(&(MapSet.size(&1) == 6)) |> Kernel.--([d6, d9])
    d5 = digits |> Enum.filter(&(MapSet.size(&1) == 5)) |> Enum.find(&(MapSet.union(&1, d1) == d9))
    [d2] = digits |> Enum.filter(&(MapSet.size(&1) == 5)) |> Kernel.--([d3, d5])

    %{d0 => 0, d1 => 1, d2 => 2, d3 => 3, d4 => 4, d5 => 5, d6 => 6, d7 => 7, d8 => 8, d9 => 9}
  end
end

input = File.read!("input/08.txt")

input
|> Eight.part_one()
|> IO.inspect(label: "part 1")

input
|> Eight.part_two()
|> IO.inspect(label: "part 2")
