defmodule Memory do
  use GenServer

  def init(rom) do
    rom = Enum.zip(512..(length(rom) + 512), rom) |> Map.new()

    {:ok, rom}
  end

  # read
  def handle_call(addr, _from, state) when is_integer(addr) and addr >= 0 and addr <= 0xEA0 do
    result = Map.get(state, addr, <<0::1*8>>)

    {:reply, result, state}
  end

  def handle_call(addr, _from, state) when is_integer(addr), do: {:reply, :error, state}

  # write
  def handle_call({addr, <<value::1*8>>}, _from, state)
      when is_integer(addr) and addr >= 0 and addr <= 0xEA0 do
    state = Map.put(state, addr, value)

    {:reply, state, state}
  end

  def handle_call(_, _from, state), do: {:reply, :error, state}
end
