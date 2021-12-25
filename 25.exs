defmodule TwentyFive do
  def part_one(input) do
    input
    |> parse()
    |> count_steps()
  end

  def part_two(input) do
    input
    |> parse()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> then(fn lines ->
      h = length(lines)
      w = lines |> List.first() |> String.length()
      for {row, y} <- Enum.with_index(lines),
          {c, x} <- Enum.with_index(String.graphemes(row)),
          c != ".",
          into: %{} do
        {{x, y}, c}
      end
      |> then(fn map -> {map, w, h} end)
    end)
  end

  defp count_steps(map, steps \\ 0) do
    map
    |> move(">")
    |> move("v")
    |> then(fn new_map ->
      if map == new_map, do: steps + 1, else: count_steps(new_map, steps + 1)
    end)
  end

  defp move({grid, w, h} = map, c) do
    Enum.map(grid, fn
      {{x, y}, ^c} ->
        if next_blocked?(map, {x, y}, c) do
          {{x, y}, c}
        else
          {next_pos(map, {x, y}, c), c}
        end
      not_moving -> not_moving
    end)
    |> Enum.into(%{})
    |> then(fn g -> {g, w, h} end)
  end

  defp next_blocked?({grid, _w, _h} = map, {x, y}, c) do
    Map.has_key?(grid, next_pos(map, {x, y}, c))
  end

  defp next_pos({_grid, w, _h}, {x, y}, ">") when x + 1 == w, do: {0, y}
  defp next_pos({_grid, _w, _h}, {x, y}, ">"), do: {x + 1, y}
  defp next_pos({_grid, _w, h}, {x, y}, "v") when y + 1 == h, do: {x, 0}
  defp next_pos({_grid, _w, _h}, {x, y}, "v"), do: {x, y + 1}

end

input = File.read!("input/25.txt")

input |> TwentyFive.part_one() |> IO.inspect(label: "part 1")
