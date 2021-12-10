defmodule Ten do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&first_illegal/1)
    |> Enum.reject(&is_list/1)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def part_two(input) do
    scores =
      input
      |> parse()
      |> Enum.map(&first_illegal/1)
      |> Enum.reject(&is_binary/1)
      |> Enum.map(&autocomplete_score/1)
      |> Enum.sort()

    Enum.at(scores, div(length(scores), 2))
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.graphemes/1)
  end

  defp first_illegal(list, seen \\ [])
  defp first_illegal([], seen), do: seen
  defp first_illegal([c | rest], seen) when c in ~w/( [ { </ do
    first_illegal(rest, [c | seen])
  end
  defp first_illegal([c | rest], [d | seen]) do
    if {c, d} in [{")", "("}, {"]", "["}, {"}", "{"}, {">", "<"}] do
      first_illegal(rest, seen)
    else
      c
    end
  end

  defp score(")"), do: 3
  defp score("]"), do: 57
  defp score("}"), do: 1197
  defp score(">"), do: 25137

  defp autocomplete_score(list) do
    Enum.reduce(list, 0, fn c, acc ->
      (acc * 5) + point(c)
    end)
  end

  defp point("("), do: 1
  defp point("["), do: 2
  defp point("{"), do: 3
  defp point("<"), do: 4
end

input = File.read!("input/10.txt")

input |> Ten.part_one() |> IO.inspect(label: "part 1")
input |> Ten.part_two() |> IO.inspect(label: "part 2")
