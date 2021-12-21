defmodule TwentyOne do
  def part_one(input) do
    {a, b} = parse(input)

    1..100
    |> Stream.cycle()
    |> Stream.chunk_every(3)
    |> Stream.with_index()
    |> Enum.reduce_while({{a, 0}, {b, 0}}, fn
      {_, i}, {{_, a_score}, {_, b_score}} when a_score >= 1000 or b_score >= 1000 ->
        {:halt, {a_score, b_score, i * 3}}
      {rolls, i}, {a, b} when rem(i, 2) == 0 ->
        {:cont, {adv(a, Enum.sum(rolls)), b}}
      {rolls, _}, {a, b} ->
        {:cont, {a, adv(b, Enum.sum(rolls))}}
    end)
    |> then(fn {a_score, b_score, n_rolls} -> min(a_score, b_score) * n_rolls end)
  end

  # this actually ran after I closed my browsers for more memory
  # this solution is perfect and eternal (and requires 16GB of RAM)
  def part_two(input) do
    {a, b} = parse(input)

    dirac(a, b)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> List.last()
      |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  defp adv({pos, score}, n) do
    new_pos =
      case rem(pos + n, 10) do
        0 -> 10
        r -> r
      end
    {new_pos, score + new_pos}
  end

  defp dirac(a_pos, b_pos), do: dirac([{a_pos, 0}], 1, 0, [{b_pos, 0}], 1, 0, 0)
  defp dirac([], _, a_wins, _, _, b_wins, _), do: {a_wins, b_wins}
  defp dirac(_, _, a_wins, [], _, b_wins, _), do: {a_wins, b_wins}
  defp dirac(a, a_n, a_wins, b, _b_n, b_wins, rolls) when rem(rolls + 3, 6) == 0 do
    {b_next, b_won} = dirac_step(b)
    b_next_l = length(b_next)
    b_won_l = length(b_won)
    new_b_n = div(a_n * b_next_l * 27, b_next_l + b_won_l)
    new_b_wins = b_wins + div(a_n * b_won_l * 27, b_next_l + b_won_l)
    dirac(a, a_n, a_wins, b_next, new_b_n, new_b_wins, rolls + 3)
  end
  defp dirac(a, _a_n, a_wins, b, b_n, b_wins, rolls) do
    {a_next, a_won} = dirac_step(a)
    a_next_l = length(a_next)
    a_won_l = length(a_won)
    new_a_n = div(b_n * a_next_l * 27, a_next_l + a_won_l)
    new_a_wins = a_wins + div(b_n * a_won_l * 27, a_next_l + a_won_l)
    dirac(a_next, new_a_n, new_a_wins, b, b_n, b_wins, rolls + 3)
  end

  defp dirac_step(verses) do
    verses
    |> Enum.map(fn {pos, score} ->
      for n <- 1..3,
          o <- 1..3,
          p <- 1..3 do
        n + o + p
      end
      |> Enum.map(fn n ->
        case rem(pos + n, 10) do
          0 -> {10, score + 10}
          r -> {r, score + r}
        end
      end)
    end)
    |> List.flatten()
    |> Enum.split_with(fn {_, score} -> score < 21 end)
  end
end

input = File.read!("input/21.txt")

input |> TwentyOne.part_one() |> IO.inspect(label: "part 1")
input |> TwentyOne.part_two() |> IO.inspect(label: "part 2")
