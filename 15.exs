defmodule Fifteen do
  defmodule Path do
    defstruct risk: 0, next: nil, progress: {0, 1}, pos: nil, path: []

    def pos(p), do: p.pos
    def inc(%Path{progress: {a, b}} = p), do: %Path{p | progress: {a + 1, b}}
  end

  # solution is horribly bugged and may result in output <=8 higher than answer :^)
  def part_one(input) do
    input
    |> parse()
    |> path_to_end()
    |> Map.fetch!(:risk)
  end

  def part_two(input) do
    input
    |> parse()
    |> extend()
    |> path_to_end()
    |> Map.fetch!(:risk)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
    |> then(fn lines ->
      for {row, y} <- Enum.with_index(lines),
          {n, x} <- Enum.with_index(row),
          into: %{} do
        {{x, y}, n}
      end
    end)
  end

  defp path_to_end(map) do
    {dest, _} = Enum.max(map)
    paths =
      next_paths(%Path{next: {0, 0}}, map, MapSet.new())
      |> Enum.map(&Map.put(&1, :risk, 0))
    step(paths, [], map, MapSet.new([{0, 1}, {1, 0}]), dest)
  end

  defp step([], next, map, seen, dest) do
    step(next, [], map, seen, dest)
  end
  defp step([%Path{next: dest} = p | _], _, map, _, dest), do: %Path{p | risk: p.risk + Map.fetch!(map, dest)}
  defp step([%Path{progress: {n, n}} = p | rest], next, map, seen, dest) do
    nexts = next_paths(p, map, seen)
    new_seen = p.next |> adjacent() |> MapSet.new() |> MapSet.union(seen)
    step(rest, nexts ++ next, map, new_seen, dest)
  end
  defp step([p | rest], next, map, seen, dest) do
    new_p = Path.inc(p)
    step(rest, [new_p | next], map, seen, dest)
  end

  defp next_paths(p, map, seen) do
    p.next
    |> adjacent()
    |> List.delete(Path.pos(p))
    |> Enum.reject(&MapSet.member?(seen, &1))
    |> Enum.filter(&Map.has_key?(map, &1))
    |> Enum.map(fn pos ->
      %Path{
        path: [{p.next, elem(p.progress, 1)} | p.path],
        pos: p.next,
        risk: p.risk + Map.fetch!(map, p.next),
        next: pos,
        progress: {0, Map.fetch!(map, pos)}
      }
    end)
  end

  defp adjacent({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp extend(map) do
    base_length = Enum.max(map) |> elem(0) |> elem(0) |> Kernel.+(1)
    length = base_length * 5
    for x <- 0..(length - 1),
        y <- 0..(length - 1),
        into: %{} do
      case Map.get(map, {x, y}) do
        nil ->
          m = manhattan({x, y}, base_length)
          n = Map.fetch!(map, {rem(x, base_length), rem(y, base_length)})
          risk = if m + n > 9, do: m + n - 9, else: m + n
          {{x, y}, risk}
        risk ->
          {{x, y}, risk}
      end
    end
  end

  defp manhattan({x, y}, base_length) do
    div(x, base_length) + div(y, base_length)
  end
end

input = File.read!("input/15.txt")

input |> Fifteen.part_one() |> IO.inspect(label: "part 1")
input |> Fifteen.part_two() |> IO.inspect(label: "part 2")
