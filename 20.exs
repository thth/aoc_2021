# solution assumes # at start of algorithm, doesn't work on example
defmodule Twenty do
  def part_one(input) do
    {alg, map} = parse(input)

    map
    |> run_times(alg, 2)
    |> Enum.filter(fn {_, v} -> v == 1 end)
    |> length()
  end

  def part_two(input) do
    {alg, map} = parse(input)

    map
    |> run_times(alg, 50)
    |> Enum.filter(fn {_, v} -> v == 1 end)
    |> length()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [alg_str, map_str] ->
      alg =
        alg_str
        |> String.graphemes()
        |> Enum.map(fn
          "#" -> true
          "." -> false
        end)
      map =
        map_str
        |> String.split(~r/\R/)
        |> Enum.with_index()
        |> Enum.map(fn {row, y} ->
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn
            {"#", x} -> {{x, y}, 1}
            {".", x} -> {{x, y}, 0}
          end)
        end)
        |> List.flatten()
        |> Enum.into(%{})
      {alg, map}
    end)
  end

  defp run_times(map, alg, times_run \\ 0, target_times)
  defp run_times(map, _alg, target_times, target_times), do: map
  defp run_times(map, alg, times_run, target_times) do
    map
    |> run(alg, times_run)
    |> run_times(alg, times_run + 1, target_times)
  end

  defp run(map, alg, times_run) do
    coords = Map.keys(map)
    {{x_min, _}, {x_max, _}} = Enum.min_max(coords)
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(coords, fn {_x, y} -> y end)

    for x <- (x_min - 1)..(x_max + 1),
        y <- (y_min - 1)..(y_max + 1),
        into: %{} do
      if lit?({x, y}, map, alg, times_run), do: {{x, y}, 1}, else: {{x, y}, 0}
    end
  end

  defp lit?({x, y}, map, alg, times_run) do
    for b <- (y - 1)..(y + 1),
        a <- (x - 1)..(x + 1) do
      if rem(times_run, 2) == 0 do
        Map.get(map, {a, b}, 0)
      else
        Map.get(map, {a, b}, 1)
      end
    end
    |> Integer.undigits(2)
    |> then(&Enum.at(alg, &1))
  end

  defp print(map) do
    {{x_min, _}, {x_max, _}} = Enum.min_max(map)
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(map, fn {_x, y} -> y end)
    Enum.each(y_min..y_max, fn y ->
      Enum.each(x_min..x_max, fn x ->
        if MapSet.member?(map, {x, y}), do: IO.write("#"), else: IO.write(".")
      end)
      IO.write("\n")
    end)
  end
end

input = File.read!("input/20.txt")

input |> Twenty.part_one() |> IO.inspect(label: "part 1")
input |> Twenty.part_two() |> IO.inspect(label: "part 2")
