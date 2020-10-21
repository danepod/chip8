defmodule VM do
  use GenServer

  def init([]) do
    {:ok,
     %{
       pc: 0x200,
       i: 0,
       v: Enum.into(0..15, %{}, &{&1, 0}),
       timer_cycles: 0,
       timer_sound: 0,
       timer_delay: 0
     }}
  end

  def handle_call(<<6::1*4, x::1*4, nn::1*8>>, _from, state = %{v: v}) do
    v = Map.put(v, x, nn)

    state = %{state | v: v}

    {:reply, state, state}
  end
end
