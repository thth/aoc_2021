defmodule Nine do
  def part_one(input) do
    map = parse(input)

    map
    |> Enum.filter(&low_point?(map, &1))
    |> Enum.map(fn {_pos, h} -> h + 1 end)
    |> Enum.sum()
  end

  def part_two(input) do
    map = parse(input)

    map
    |> Enum.filter(&low_point?(map, &1))
    |> Enum.map(&basin_size(map, &1))
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, y}, list ->
      Enum.reduce(row, list, fn {n, x}, acc -> [{{x, y}, n} | acc] end)
    end)
    |> Enum.into(%{})
  end

  defp low_point?(map, {pos, n}) do
    pos
    |> neighbours()
    |> Enum.all?(fn pos ->
      Map.get(map, pos) > n
    end)
  end

  defp basin_size(map, {pos, _h}) do
    to_check = neighbour_points(pos, map)
    basin_size(map, to_check, [], MapSet.new([pos]), MapSet.new([pos]))
  end

  defp basin_size(_map, [], [], _seen, size), do: MapSet.size(size)
  defp basin_size(map, [], next, seen, size),
    do: basin_size(map, next, [], seen, size)
  defp basin_size(map, [{pos, 9} | rest], next, seen, size),
    do: basin_size(map, rest, next, MapSet.put(seen, pos), size)
  defp basin_size(map, [{pos, _h} | rest], next, seen, size) do
    new_points =
      pos
      |> neighbour_points(map)
      |> Enum.reject(fn {p, _} -> MapSet.member?(seen, p) end)
    new_seen =
      new_points
      |> Enum.map(fn {p, _} -> p end)
      |> MapSet.new()
      |> MapSet.union(seen)
    new_next = new_points ++ next
    basin_size(map, rest, new_next, new_seen, MapSet.put(size, pos))
  end

  defp neighbours({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

  defp neighbour_points(pos, map) do
    pos
    |> neighbours()
    |> Enum.map(fn pos -> {pos, Map.get(map, pos)} end)
    |> Enum.reject(fn {_, h} -> is_nil(h) end)
  end
end

input = File.read!("input/09.txt")

input |> Nine.part_one() |> IO.inspect(label: "part 1")
input |> Nine.part_two() |> IO.inspect(label: "part 2")
