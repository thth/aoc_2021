defmodule Fourteen do
  def part_one(input) do
    {template, reactions} = parse(input)

    template
    |> run(reactions, 10)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.min_max()
    |> then(fn {min, max} -> max - min end)
  end

  def part_two(input) do
    {template, reactions} = parse(input)

    half_counts =
      reactions
      |> Enum.map(fn {{a, b}, _} = reaction ->
        {[a, b], count(reaction, reactions, 20)}
      end)
      |> Enum.into(%{})

    template
    |> run(reactions, 20)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn pair -> Map.get(half_counts, pair, %{}) end)
    |> Enum.reduce(%{List.first(template) => 1}, fn sums, acc ->
      Map.merge(sums, acc, fn _k, v, w -> v + w end)
    end)
    |> Map.values()
    |> Enum.min_max()
    |> then(fn {min, max} -> max - min end)
  end

  defp parse(text) do
    [template, rest] =
      text
      |> String.trim()
      |> String.split(~r/\R\R/)
    reactions =
      Regex.scan(~r/\w/, rest)
      |> List.flatten()
      |> Enum.chunk_every(3)
      |> Enum.map(fn [x, y, z] -> {{x, y}, z} end)
      |> Enum.into(%{})
    {String.graphemes(template), reactions}
  end

  defp run(list, _reactions, 0), do: list
  defp run(list, reactions, times) do
    new_list = step(list, reactions)
    run(new_list, reactions, times - 1)
  end

  defp step(list, reactions, out \\ [])
  defp step([a], _reactions, out), do: Enum.reverse([a | out])
  defp step([a, b | rest], reactions, out) do
    case Map.get(reactions, {a, b}) do
      nil ->
        step([b | rest], reactions, [a | out])
      c ->
        step([b | rest], reactions, [c, a | out])
    end
  end

  defp count({{a, b}, _}, reactions, times) do
    run([a, b], reactions, times)
    |> Enum.drop(1)
    |> Enum.frequencies()
  end
end

input = File.read!("input/14.txt")

input |> Fourteen.part_one() |> IO.inspect(label: "part 1")
input |> Fourteen.part_two() |> IO.inspect(label: "part 2")
