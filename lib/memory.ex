defmodule Memory do
  use GenServer

  import Integer, only: [is_even: 1]

  def start(binary), do: GenServer.start(__MODULE__, binary, name: __MODULE__)

  @doc """
  Fetches data at the given address from memory.

  Can be used to either fetch a 16-bit word (default), or a byte. When given an uneven address, only a single byte can
  be fetched.
  """
  def read(addr, mode \\ :word)

  def read(addr, :word) when is_even(addr), do: GenServer.call(__MODULE__, addr)

  def read(addr, :byte) when is_even(addr) do
    <<byte1::8, _byte2::8>> = GenServer.call(__MODULE__, addr)

    byte1
  end

  def read(addr, :byte) do
    <<_byte1::8, byte2::8>> = GenServer.call(__MODULE__, addr - 1)

    byte2
  end

  @doc """
  Writes data to the given address in memory.

  Can either write a 16-bit word at once (default), or a byte. Words can only be written starting at even addresses.
  """
  def write(addr, data, mode \\ :word)

  def write(addr, word, :word) when is_even(addr),
    do: GenServer.call(__MODULE__, {addr, <<word::16>>})

  def write(addr, byte, :byte) when is_even(addr) do
    <<_byte1::8, byte2::8>> = GenServer.call(__MODULE__, addr)

    GenServer.call(__MODULE__, {addr, <<byte::8, byte2::8>>})
  end

  def write(addr, byte, :byte) do
    <<byte1::8, _byte2::8>> = GenServer.call(__MODULE__, addr - 1)

    GenServer.call(__MODULE__, {addr - 1, <<byte1, byte>>})
  end

  @doc """
  Prints the contents of the memory around the given address.

  A range can be passed as the second argument (must be even, default: 10)
  """
  def peek(addr, range \\ 10) when is_even(addr) and is_even(range) do
    addresses = (addr - range)..(addr + range) |> Enum.take_every(2)

    Enum.each(addresses, fn addr ->
      data = Memory.read(addr)

      IO.puts("#{inspect(addr, base: :hex)}: #{inspect(data, base: :hex)}")
    end)
  end

  def init(rom) do
    addresses = Enum.take_every(0x200..(length(rom) * 2 + 0x200), 2)
    rom = Enum.zip(addresses, rom) |> Map.new()

    {:ok, rom}
  end

  # read
  def handle_call(addr, _from, state) when is_integer(addr) and addr >= 0 and addr <= 0xEA0 do
    result = Map.get(state, addr, <<0::1*8, 0::1*8>>)

    {:reply, result, state}
  end

  def handle_call(addr, _from, state) when is_integer(addr), do: {:reply, :error, state}

  # write
  def handle_call({addr, <<value::16>>}, _from, state)
      when is_even(addr) and addr >= 0 and addr <= 0xEA0 do
    state = Map.put(state, addr, <<value::16>>)

    {:reply, state, state}
  end

  # Fail soft, so we don't have to restart the app all the time during debugging
  def handle_call(cmd, _from, state), do: {:reply, {:error, {:not_implemented, cmd}}, state}
end
