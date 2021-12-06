defmodule Six do
  @days_one 80
  @days_two 256

  def part_one(input) do
    input
    |> parse()
    |> simulate(@days_one)
    |> Enum.count()
  end

  def part_two(input) do
    input
    |> parse()
    |> simulate_count(@days_two)
    |> Enum.reduce(0, fn {_, n}, acc -> acc + n end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp simulate(fish, 0), do: fish
  defp simulate(fish, days) do
    n_new = Enum.count(fish, &(&1 == 0))
    new_fish = Enum.map(fish, fn
      0 -> 6
      n -> n - 1
    end) ++ List.duplicate(8, n_new)
    simulate(new_fish, days - 1)
  end

  defp simulate_count(fish, days) do
    fish
    |> Enum.frequencies()
    |> Enum.into(Map.new(0..8, &({&1, 0})))
    |> Enum.to_list()
    |> count_loop(days)
  end

  defp count_loop(fish, 0), do: fish
  defp count_loop(fish, days) do
    n_0 = fish |> List.keyfind(0, 0) |> elem(1)

    fish
    |> Enum.map(fn
      {0, n} -> {8, n}
      {7, n} -> {6, n + n_0}
      {d, n} -> {d - 1, n}
    end)
    |> count_loop(days - 1)
  end
end

input = File.read!("input/06.txt")

input
|> Six.part_one()
|> IO.inspect(label: "part 1")

input
|> Six.part_two()
|> IO.inspect(label: "part 2")
