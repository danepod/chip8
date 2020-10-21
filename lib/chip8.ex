defmodule Chip8 do
  def run(filename \\ "blinky") do
    binary = load_file(filename)

    binary =
      for <<byte1::8, byte2::8 <- binary>> do
        <<byte1, byte2>>
      end

    {:ok, pid} = GenServer.start(Memory, binary)

    pid
  end

  def disassemble(filename \\ "blinky") do
    binary = load_file(filename)

    binary |> IO.inspect(base: :hex)

    disasm =
      Enum.with_index(
        for <<byte1::8, byte2::8 <- binary>> do
          tick(byte1, byte2)
        end
      )
      |> Enum.map(fn {disasm, pc} ->
        IO.inspect("#{inspect(0x200 + pc * 2, base: :hex)}    #{disasm}")
      end)
      |> Enum.join("\n")

    File.write(filename <> ".disasm", disasm)

    :ok
  end

  defp load_file(filename) do
    {:ok, binary} = File.read(filename <> ".ch8")

    binary
  end

  defp tick(byte1, byte2) do
    hi1 = Bitwise.>>>(byte1, 4)
    lo1 = Bitwise.&&&(byte1, 0x0F)

    # hi1 |> IO.inspect()
    # lo1 |> IO.inspect()

    hi2 = Bitwise.>>>(byte2, 4)
    lo2 = Bitwise.&&&(byte2, 0x0F)

    # hi2 |> IO.inspect()
    # lo2 |> IO.inspect()

    Disassembler.disassemble(<<hi1, lo1, hi2, lo2>>)
  end
end
