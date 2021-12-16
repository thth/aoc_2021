defmodule Sixteen do
  defmodule Packet do
    @enforce_keys [:version, :type]
    defstruct version: nil, type: nil, value: nil
  end

  def part_one(input) do
    {packet, _rest_bits} = parse(input)
    sum_versions(packet)
  end

  def part_two(input) do
    {packet, _rest_bits} = parse(input)
    calc(packet)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> hex_to_binary()
    |> decode()
  end

  defp hex_to_binary(string) do
    string
    |> String.graphemes()
    |> Enum.map(fn hex ->
      hex
      |> Integer.parse(16)
      |> elem(0)
      |> Integer.to_string(2)
      |> String.pad_leading(4, "0")
    end)
    |> Enum.join()
  end

  defp decode(string) when is_binary(string) do
    string |> String.graphemes() |> Enum.map(&String.to_integer/1) |> decode(:type)
  end

  defp decode([v1, v2, v3, 1, 0, 0 | rest], :type) do
    version = [v1, v2, v3] |> Integer.undigits(2)
    packet = %Packet{version: version, type: 4}
    decode(rest, :literal, packet, [])
  end

  defp decode([v1, v2, v3, t1, t2, t3 | rest], :type) do
    version = Integer.undigits([v1, v2, v3], 2)
    type = Integer.undigits([t1, t2, t3], 2)
    packet = %Packet{version: version, type: type}
    decode(rest, :operator, packet)
  end

  defp decode([1, b1, b2, b3, b4 | rest], :literal, packet, parsed) do
    decode(rest, :literal, packet, parsed ++ [b1, b2, b3, b4])
  end

  defp decode([0, b1, b2, b3, b4 | rest], :literal, packet, parsed) do
    value = Integer.undigits(parsed ++ [b1, b2, b3, b4], 2)
    {%Packet{packet | value: value}, rest}
  end

  defp decode([0 | rest], :operator, packet) do
    {bits, tail} = Enum.split(rest, 15)
    length = Integer.undigits(bits, 2)
    {sub_bits, new_rest} = Enum.split(tail, length)
    sub_packets = decode_until_empty(sub_bits)
    {%Packet{packet | value: sub_packets}, new_rest}
  end

  defp decode([1 | rest], :operator, packet) do
    {bits, tail} = Enum.split(rest, 11)
    n_sub = Integer.undigits(bits, 2)
    {sub_packets, new_rest} = decode_n_packets(tail, n_sub)
    {%Packet{packet | value: sub_packets}, new_rest}
  end

  defp decode_until_empty(bits, packets \\ [])
  defp decode_until_empty([], packets), do: packets
  defp decode_until_empty(bits, packets) do
    {packet, rest} = decode(bits, :type)
    decode_until_empty(rest, packets ++ [packet])
  end

  defp decode_n_packets(bits, n, packets \\ [])
  defp decode_n_packets(bits, 0, packets), do: {packets, bits}
  defp decode_n_packets(bits, n, packets) do
    {packet, rest} = decode(bits, :type)
    decode_n_packets(rest, n - 1, packets ++ [packet])
  end

  defp sum_versions(%Packet{value: list, version: n}) when is_list(list) do
    list
    |> Enum.map(&sum_versions/1)
    |> Enum.sum()
    |> Kernel.+(n)
  end
  defp sum_versions(%Packet{version: n}), do: n

  defp calc(%Packet{type: 0, value: packets}), do: packets |> Enum.map(&calc/1) |> Enum.sum()
  defp calc(%Packet{type: 1, value: packets}), do: packets |> Enum.map(&calc/1) |> Enum.product()
  defp calc(%Packet{type: 2, value: packets}), do: packets |> Enum.map(&calc/1) |> Enum.min()
  defp calc(%Packet{type: 3, value: packets}), do: packets |> Enum.map(&calc/1) |> Enum.max()
  defp calc(%Packet{type: 4, value: n}), do: n
  defp calc(%Packet{type: 5, value: [p1, p2]}), do: if calc(p1) > calc(p2), do: 1, else: 0
  defp calc(%Packet{type: 6, value: [p1, p2]}), do: if calc(p1) < calc(p2), do: 1, else: 0
  defp calc(%Packet{type: 7, value: [p1, p2]}), do: if calc(p1) == calc(p2), do: 1, else: 0
end

input = File.read!("input/16.txt")

input |> Sixteen.part_one() |> IO.inspect(label: "part 1")
input |> Sixteen.part_two() |> IO.inspect(label: "part 2")
