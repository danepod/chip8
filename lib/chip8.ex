defmodule Chip8 do
  def run(filename \\ "blinky") do
    binary = load_file(filename)

    binary =
      for <<byte1::8, byte2::8 <- binary>> do
        <<byte1, byte2>>
      end

    # Initialize registers
    {:ok, vm_pid} = VM.start()

    # Initialize memory, load game
    {:ok, mem_pid} = Memory.start(binary)

    {:ok, vm_pid, mem_pid}
  end

  def disassemble(filename \\ "blinky") do
    binary = load_file(filename)

    binary |> IO.inspect(base: :hex)

    disasm =
      Enum.with_index(
        for <<byte1::8, byte2::8 <- binary>> do
          VM.decode(<<byte1, byte2>>)
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
end
