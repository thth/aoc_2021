defmodule Twelve do
  def part_one(input) do
    input
    |> parse()
    |> make_paths()
    |> Enum.count()
  end

  def part_two(input) do
    input
    |> parse()
    |> make_scenic_paths()
    |> Enum.count()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn [a, b], acc ->
      acc
      |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
      |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
    end)
  end

  defp make_paths(map), do: make_paths(map, [["start"]], [])
  defp make_paths(_map, [], paths), do: paths
  defp make_paths(map, [[curr | prevs] = path | rest], paths) do
    small_prevs = prevs |> Enum.reject(&(String.upcase(&1) == &1)) |> MapSet.new()
    nexts =
      map
      |> Map.fetch!(curr)
      |> MapSet.difference(small_prevs)
    next_paths =
      nexts
      |> MapSet.delete("end")
      |> Enum.map(fn next -> [next | path] end)
    new_paths = if "end" in nexts, do: [Enum.reverse(["end" | path]) | paths], else: paths

    make_paths(map, next_paths ++ rest, new_paths)
  end

  defp make_scenic_paths(map), do: make_scenic_paths(map, [["start"]], [])
  defp make_scenic_paths(_map, [], paths), do: paths
  defp make_scenic_paths(map, [[curr | prevs] = path | rest], paths) do
    visited_enough =
      if visited_two_smalls?(path) do
        prevs |> Enum.reject(&(String.upcase(&1) == &1)) |> MapSet.new()
      else
        MapSet.new(["start"])
      end
    nexts =
      map
      |> Map.fetch!(curr)
      |> MapSet.difference(visited_enough)
    next_paths =
      nexts
      |> MapSet.delete("end")
      |> Enum.map(fn next -> [next | path] end)
    new_paths = if "end" in nexts, do: [Enum.reverse(["end" | path]) | paths], else: paths

    make_scenic_paths(map, next_paths ++ rest, new_paths)
  end

  defp visited_two_smalls?(path) do
    path
    |> Enum.reject(&(String.upcase(&1) == &1))
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.max()
    |> Kernel.==(2)
  end
end

input = File.read!("input/12.txt")

input |> Twelve.part_one() |> IO.inspect(label: "part 1")
input |> Twelve.part_two() |> IO.inspect(label: "part 2")
