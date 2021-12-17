defmodule Seventeen do
  def part_one(input) do
    {x_min..x_max, _y} = ranges = parse(input)

    dx_min =
      Stream.iterate(1, &(&1 + 1))
      |> Enum.reduce_while(0, fn x, acc ->
        if x + acc in x_min..x_max do
          {:halt, x}
        else
          {:cont, acc + x}
        end
      end)

    dx_min..x_max
    |> Enum.map(&highest(&1, ranges))
    |> Enum.reject(&is_nil(&1))
    |> Enum.max()
  end

  def part_two(input) do
    {x_min..x_max, _y} = ranges = parse(input)

    dx_min =
      Stream.iterate(1, &(&1 + 1))
      |> Enum.reduce_while(0, fn x, acc ->
        if x + acc in x_min..x_max do
          {:halt, x}
        else
          {:cont, acc + x}
        end
      end)

    dx_min..x_max
    |> Enum.map(&count(&1, ranges))
    |> Enum.sum()
  end

  defp parse(text) do
    Regex.scan(~r/[-\d]+/, text)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x_min, x_max, y_min, y_max] -> {x_min..x_max,  y_min..y_max} end)
  end

  defp highest(dx, ranges) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn dy -> fly({dx, dy}, ranges) end)
    |> Stream.take_while(fn result -> elem(result, 0) == :cont end)
    |> Enum.reject(fn {_, h} -> is_nil(h) end)
    |> then(fn
      [] -> nil
      heights ->
        Enum.max_by(heights, fn {_, h} -> h end)
        |> elem(1)
    end)
  end

  defp fly(v, ranges, pos \\ {0, 0}, max_h \\ 0)
  defp fly({_, dy}, {_, y_min.._}, _, _) when dy > abs(y_min), do: {:halt, nil}
  defp fly(_, {x_min..x_max, y_min..y_max}, {x, y}, max_h)
    when x >= x_min and x <= x_max and y >= y_min and y <= y_max, do: {:cont, max_h}
  defp fly(_, {_..x_max, _}, {x, _}, _) when x > x_max, do: {:halt, nil}
  defp fly({0, _}, {x_min.._, _}, {x, _}, _) when x < x_min, do: {:cont, nil}
  defp fly(_, {_, y_min.._}, {_, y}, _) when y < y_min, do: {:cont, nil}
  defp fly({dx, dy}, ranges, {x, y}, max_h) do
    new_dx =
      cond do
        dx > 0 -> dx - 1
        dx < 0 -> dx + 1
        dx == 0 -> 0
      end
    fly({new_dx, dy - 1}, ranges, {x + dx, y + dy}, max(max_h, y + dy))
  end

  defp count(dx, {_, y_min.._} = ranges) do
    Stream.iterate(y_min, &(&1 + 1))
    |> Stream.map(fn dy -> fly({dx, dy}, ranges) end)
    |> Stream.take_while(fn result -> elem(result, 0) == :cont end)
    |> Enum.reject(fn {_, h} -> is_nil(h) end)
    |> Enum.count()
  end
end

input = File.read!("input/17.txt")

input |> Seventeen.part_one() |> IO.inspect(label: "part 1")
input |> Seventeen.part_two() |> IO.inspect(label: "part 2")
