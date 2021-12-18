defmodule Eighteen do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce(fn x, acc -> add(acc, x) |> reduce() end)
    |> magnitude()
  end

  def part_two(input) do
    snail_numbers = parse(input)

    for a <- snail_numbers,
        b <- snail_numbers -- [a] do
      {a, b}
    end
    |> Enum.map(fn {a, b} -> add(a, b) |> reduce() |> magnitude() end)
    |> Enum.max()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Stream.map(&String.graphemes/1)
    |> Enum.map(&parse_line/1)
  end

  # assuming input has no multi digit numbers
  defp parse_line(line, parsed \\ [], depth \\ 0)
  defp parse_line([], parsed, 0), do: Enum.reverse(parsed)
  defp parse_line(["[" | rest], parsed, d), do: parse_line(rest, parsed, d + 1)
  defp parse_line(["]" | rest], parsed, d), do: parse_line(rest, parsed, d - 1)
  defp parse_line(["," | rest], parsed, d), do: parse_line(rest, parsed, d)
  defp parse_line([n | rest], parsed, d),
    do: parse_line(rest, [{String.to_integer(n), d} | parsed], d)

  defp add(a, b), do: Enum.map(a ++ b, fn {n, d} -> {n, d + 1} end)

  defp reduce(snail_n) do
    li = Enum.with_index(snail_n)

    with nil <- Enum.find_value(li, &to_explode/1),
         nil <- Enum.find_value(li, &to_split/1) do
      snail_n
    else
      {:explode, i} -> snail_n |> explode(i) |> reduce()
      {:split, i} -> snail_n |> split(i) |> reduce()
    end
  end

  defp to_explode({{_n, d}, i}) when d > 4, do: {:explode, i}
  defp to_explode(_), do: false

  defp to_split({{n, _d}, i}) when n > 9, do: {:split, i}
  defp to_split(_), do: false

  defp explode(snail_n, i) do
    {a, d} = Enum.at(snail_n, i)
    {b, ^d} = Enum.at(snail_n, i + 1)

    snail_n
    |> then(fn list ->
      if i == 0 do
        list
      else
        List.update_at(list, i - 1, fn {n, d} -> {n + a, d} end)
      end
    end)
    |> List.update_at(i + 2, fn {n, d} -> {n + b, d} end)
    |> List.replace_at(i, {0, d - 1})
    |> List.delete_at(i + 1)
  end

  defp split(snail_n, i) do
    {n, d} = Enum.at(snail_n, i)

    snail_n
    |> List.replace_at(i, {ceil(n / 2), d + 1})
    |> List.insert_at(i, {floor(n / 2), d + 1})
  end

  defp magnitude(snail_n, past \\ [])
  defp magnitude([{n, 0}], _), do: n
  defp magnitude([{a, d}, {b, d} | rest], past),
    do: magnitude(past ++ [{(a * 3) + (b * 2), d - 1}] ++ rest)
  defp magnitude([ad | rest], past), do: magnitude(rest, past ++ [ad])
end

input = File.read!("input/18.txt")

input |> Eighteen.part_one() |> IO.inspect(label: "part 1")
input |> Eighteen.part_two() |> IO.inspect(label: "part 2")
