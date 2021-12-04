defmodule Four do
  def part_one(input) do
    {nums, boards} = parse(input)

    boards_and_lines = Enum.map(boards, &add_lines/1)
    {winning_board, last_n} = bingo(boards_and_lines, nums)

    sequence_i = nums |> Enum.find_index(&(&1 == last_n))
    sequence = nums |> Enum.slice(0..sequence_i) |> MapSet.new()

    unmarked_nums = winning_board |> List.flatten() |> MapSet.new() |> MapSet.difference(sequence)

    Enum.sum(unmarked_nums) * last_n
  end

  def part_two(input) do
    {nums, boards} = parse(input)

    boards_and_lines = Enum.map(boards, &add_lines/1)
    {losing_board, last_n} = last_bingo(boards_and_lines, nums)

    sequence_i = nums |> Enum.find_index(&(&1 == last_n))
    sequence = nums |> Enum.slice(0..sequence_i) |> MapSet.new()

    unmarked_nums = losing_board |> List.flatten() |> MapSet.new() |> MapSet.difference(sequence)

    Enum.sum(unmarked_nums) * last_n
  end

  defp parse(text) do
    [n_str | boards_str] =
      text
      |> String.trim()
      |> String.split(~r/\R\R/)
    # |> Enum.map(fn line ->
    #   line
    # end)
    nums =
      n_str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    boards =
      boards_str
      |> Enum.map(fn board_str ->
        board_str
        |> String.split(~r/\R/)
        |> Enum.map(fn row ->
          String.split(row)
          |> Enum.map(&String.to_integer/1)
        end)
      end)

      {nums, boards}
  end

  defp add_lines(board) do
    lines =
      board
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Kernel.++(board)
    {board, lines}
  end

  defp bingo(boards_and_lines, [num | rest]) do
    new_boards_and_lines =
      boards_and_lines
      |> Enum.map(fn {boards, lines} ->
        new_lines =
          lines
          |> Enum.map(fn line ->
            List.delete(line, num)
          end)
        {boards, new_lines}
      end)

    case Enum.find(new_boards_and_lines, &has_full_line?/1) do
      {board, _} -> {board, num}
      nil -> bingo(new_boards_and_lines, rest)
    end
  end

  defp has_full_line?({_board, lines}) do
    Enum.any?(lines, &(&1 == []))
  end

  defp last_bingo(boards_and_lines, [num | rest]) do
    new_boards_and_lines =
      boards_and_lines
      |> Enum.map(fn {boards, lines} ->
        new_lines =
          lines
          |> Enum.map(fn line ->
            List.delete(line, num)
          end)
        {boards, new_lines}
      end)
      |> Enum.reject(&has_full_line?/1)

    if new_boards_and_lines == [] do
      [{board, _}] = boards_and_lines
      {board, num}
    else
      last_bingo(new_boards_and_lines, rest)
    end
  end
end

input = File.read!("input/04.txt")

input
|> Four.part_one()
|> IO.inspect(label: "part 1")

input
|> Four.part_two()
|> IO.inspect(label: "part 2")
