defmodule Three do
  def part_one(input) do
    gamma =
      input
      |> parse()
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.frequencies/1)
      |> Enum.map(&Enum.to_list/1)
      |> Enum.map(fn
        [{"0", n0}, {"1", n1}] when n0 > n1 -> "0"
        _ -> "1"
      end)
      |> Enum.join()

    epsilon =
      gamma
      |> String.graphemes()
      |> Enum.map(fn
        "0" -> "1"
        "1" -> "0"
      end)
      |> Enum.join()

    String.to_integer(gamma, 2) * String.to_integer(epsilon, 2)
  end

  def part_two(input) do
    oxygen =
      input
      |> parse()
      |> find_o2()

    co2 =
      input
      |> parse()
      |> find_co2()

    oxygen * co2
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.graphemes/1)
  end

  defp find_o2(list, i \\ 0)
  defp find_o2([binary], _) do
    binary
    |> Enum.join()
    |> String.to_integer(2)
  end
  defp find_o2(list, i) do
    %{"0" => n0, "1" => n1} =
      list
      |> Enum.zip()
      |> Enum.at(i)
      |> Tuple.to_list()
      |> Enum.frequencies()
    if n0 > n1 do
      list
      |> Enum.filter(fn binary -> Enum.at(binary, i) == "0" end)
      |> find_o2(i + 1)
    else
      list
      |> Enum.filter(fn binary -> Enum.at(binary, i) == "1" end)
      |> find_o2(i + 1)
    end
  end

  defp find_co2(list, i \\ 0)
  defp find_co2([binary], _) do
    binary
    |> Enum.join()
    |> String.to_integer(2)
  end
  defp find_co2(list, i) do
    %{"0" => n0, "1" => n1} =
      list
      |> Enum.zip()
      |> Enum.at(i)
      |> Tuple.to_list()
      |> Enum.frequencies()

    if n0 <= n1 do
      list
      |> Enum.filter(fn binary -> Enum.at(binary, i) == "0" end)
      |> find_co2(i + 1)
    else
      list
      |> Enum.filter(fn binary -> Enum.at(binary, i) == "1" end)
      |> find_co2(i + 1)
    end
  end
end

input = File.read!("input/03.txt")

input
|> Three.part_one()
|> IO.inspect(label: "part 1")

input
|> Three.part_two()
|> IO.inspect(label: "part 2")
