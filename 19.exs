defmodule Nineteen do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn objs -> Enum.reject(objs, &(elem(&1, 0) == :scanner)) end)
    |> map_objs()
    |> MapSet.size()
  end

  def part_two(input) do
    input
    |> parse()
    |> map_objs()
    |> Enum.filter(&(elem(&1, 0) == :scanner))
    |> then(fn scanners ->
      for {:scanner, a, b, c} = s <- scanners,
          {:scanner, x, y, z} <- scanners -- [s] do
        abs(x - a) + abs(y - b) + abs(z - c)
      end
    end)
    |> Enum.max()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.map(fn section ->
      section
      |> String.split(~r/\R/)
      |> List.delete_at(0)
      |> Enum.map(fn beacon_str ->
        beacon_str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.map(fn [a, b, c] -> {:beacon, a, b, c} end)
      |> List.insert_at(0, {:scanner, 0, 0, 0})
    end)
  end

  defp map_objs([first | rest]) do
    base = MapSet.new(first)
    permutations =
      rest
      |> Enum.map(fn beacons ->
        beacons
        |> Enum.map(fn beacon ->
          beacon
          |> turn()
          |> Enum.map(&rotate/1)
          |> List.flatten()
        end)
        |> Enum.zip()
        |> Enum.map(&Tuple.to_list/1)
      end)
    map(permutations, [], base)
  end

  defp turn({t, a, b, c}) do
    [
      {t, a, b, c},
      {t, -b, a, c},
      {t, -a, -b, c},
      {t, b, -a, c}
    ]
  end

  defp rotate({t, a, b, c}) do
    [
      {t, a, b, c},
      {t, -a, b, -c},
      {t, -c, b, a},
      {t, c, b, -a},
      {t, a, -c, b},
      {t, a, c, -b}
    ]
  end

  defp map([], [], set), do: set
  defp map([], past, set), do: map(past, [], set)
  defp map([perms | rest], past, set) do
    case Enum.find_value(perms, &fit(set, &1)) do
      nil -> map(rest, [perms | past], set)
      aligned_beacons ->
        new_set =
          aligned_beacons
          |> MapSet.new()
          |> MapSet.union(set)
        map(rest, past, new_set)
    end
  end

  defp fit(set, perm) do
    for {_, p, q, r} <- set,
        {_, a, b, c} <- perm do
      perm
      |> Enum.map(fn {t, x, y, z} -> {t, x + p - a, y + q - b, z + r - c} end)
      |> MapSet.new()
    end
    |> Enum.find(fn transformed ->
      MapSet.intersection(set, transformed)
      |> MapSet.size()
      |> then(&(&1 >= 12))
    end)
  end
end

input = File.read!("input/19.txt")

input |> Nineteen.part_one() |> IO.inspect(label: "part 1")
input |> Nineteen.part_two() |> IO.inspect(label: "part 2")
