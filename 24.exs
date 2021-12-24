defmodule TwentyFour do
  # cursed edition
  def part_one(input) do
    instructions = parse(input)

    Stream.repeatedly(fn -> for _ <- 1..14, do: Enum.random(1..9) end)
    |> Enum.find_value(fn model_n ->
      %{z: z} = run({%{w: 0, x: 0, y: 0, z: 0}, model_n}, instructions)
      if z == 0, do: model_n, else: false
    end)
    # found a z=0 but stopped your code? feed it here!
    # [9, 6, 2, 6, 2, 4, 1, 3, 9, 9, 9, 3, 4, 1]
    |> Stream.iterate(&send_help(&1, instructions, fn l -> Enum.max(l) end))
    |> Enum.reduce_while(nil, fn
      prev, prev -> {:halt, prev}
      new, _prev ->
        IO.inspect(new)
        {:cont, new}
    end)
    |> Integer.undigits()
  end

  # seeing my cursed solution also be applicable to part 2 made me so happy
  def part_two(input) do
    instructions = parse(input)

    Stream.repeatedly(fn -> for _ <- 1..14, do: Enum.random(1..9) end)
    |> Enum.find_value(fn model_n ->
      %{z: z} = run({%{w: 0, x: 0, y: 0, z: 0}, model_n}, instructions)
      if z == 0, do: model_n, else: false
    end)
    # [9, 6, 2, 6, 2, 4, 1, 3, 9, 9, 9, 3, 4, 1]
    |> Stream.iterate(&send_help(&1, instructions, fn l -> Enum.min(l) end))
    |> Enum.reduce_while(nil, fn
      prev, prev -> {:halt, prev}
      new, _prev ->
        IO.inspect(new)
        {:cont, new}
    end)
    |> Integer.undigits()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> then(fn
        ["inp", v] -> {:inp, String.to_atom(v)}
        [ins, v, w] ->
          {String.to_atom(ins), String.to_atom(v),
            (if w =~ ~r/\d/, do: String.to_integer(w), else: String.to_atom(w))}
      end)
    end)
  end

  defp run({vars, _}, []), do: vars
  defp run(state, [ins | rest]) do
    state
    |> step(ins)
    |> run(rest)
  end

  defp step({vars, [inp | rest]}, {:inp, v}), do: {Map.put(vars, v, inp), rest}
  defp step({vars, inps}, {:add, v, b}) when is_atom(b), do: {Map.update!(vars, v, &(&1 + vars[b])), inps}
  defp step({vars, inps}, {:add, v, b}) when is_integer(b), do: {Map.update!(vars, v, &(&1 + b)), inps}
  defp step({vars, inps}, {:mul, v, b}) when is_atom(b), do: {Map.update!(vars, v, &(&1 * vars[b])), inps}
  defp step({vars, inps}, {:mul, v, b}) when is_integer(b), do: {Map.update!(vars, v, &(&1 * b)), inps}
  defp step({vars, inps}, {:div, v, b}) when is_atom(b), do: {Map.update!(vars, v, &div(&1, vars[b])), inps}
  defp step({vars, inps}, {:div, v, b}) when is_integer(b), do: {Map.update!(vars, v, &div(&1, b)), inps}
  defp step({vars, inps}, {:mod, v, b}) when is_atom(b), do: {Map.update!(vars, v, &rem(&1, vars[b])), inps}
  defp step({vars, inps}, {:mod, v, b}) when is_integer(b), do: {Map.update!(vars, v, &rem(&1, b)), inps}
  defp step({vars, inps}, {:eql, v, b}) when is_atom(b),
    do: {Map.put(vars, v, (if vars[v] == vars[b], do: 1, else: 0)), inps}
  defp step({vars, inps}, {:eql, v, b}) when is_integer(b),
    do: {Map.put(vars, v, (if vars[v] == b, do: 1, else: 0)), inps}

  defp send_help(model_n, instructions, sort) do
    # lazy for comprehension because I ran out of memory w/ 4 replacements
    Stream.flat_map(13..0, fn i1 ->
      Stream.flat_map(13..0, fn i2 ->
        Stream.flat_map(13..0, fn i3 ->
          # Stream.flat_map(13..0, fn i4 ->
            Stream.flat_map(9..1, fn n1 ->
              Stream.flat_map(9..1, fn n2 ->
                Stream.flat_map(9..1, fn n3 ->
                  # Stream.flat_map(9..1, fn n4 ->
                    [
                      model_n
                      |> List.replace_at(i1, n1)
                      |> List.replace_at(i2, n2)
                      |> List.replace_at(i3, n3)
                      # |> List.replace_at(i4, n4)
                    ]
                  # end)
                end)
              end)
            end)
          # end)
        end)
      end)
    end)
    |> Stream.map(&({run({%{w: 0, x: 0, y: 0, z: 0}, &1}, instructions), &1}))
    |> Stream.filter(fn {vars, _} -> vars[:z] == 0 end)
    |> Stream.map(&elem(&1, 1))
    |> sort.()
  end
end

input = File.read!("input/24.txt")

input |> TwentyFour.part_one() |> IO.inspect(label: "part 1")
input |> TwentyFour.part_two() |> IO.inspect(label: "part 2")
