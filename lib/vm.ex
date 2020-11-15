defmodule VM do
  use GenServer
  use Bitwise

  def start, do: GenServer.start(__MODULE__, [], name: __MODULE__)

  def tick do
    # Fetch opcode
    pc = get_pc()

    opcode = Memory.read(pc)

    # Decode opcode
    instr = decode(opcode)
    IO.puts("#{inspect(pc, base: :hex)}: \t #{inspect(opcode, base: :hex)} | #{instr}")

    # Execute opcode
    execute(opcode)

    # TODO: Update timers in a separate process
    # Timers are decremented in a 60Hz interval. For the timers to be deterministic, they need to be aligned to the VMs
    # tickrate. What should be done is a separate process that takes care of the clock. In that process, the timers can
    # be updated depending on the ratio between VM and timer-decrement tick-rate.
    # Let's say VM will run with 120Hz, then the timers are supposed to be updated after every second VM tick.
    # This clock process then can also take care of handling breaks in execution, and still update the timers based on
    # the defined ratio.

    :ok
  end

  def decode(<<hi1::1*4, lo1::1*4, hi2::1*4, lo2::1*4>>),
    do: Disassembler.disassemble(<<hi1, lo1, hi2, lo2>>)

  def execute(opcode), do: GenServer.call(__MODULE__, opcode)

  def get_pc, do: GenServer.call(__MODULE__, :get_pc)

  def init([]) do
    {:ok,
     %{
       # program counter
       pc: 0x200,
       # 16-bit address register
       i: 0,
       # 8-bit registers
       v: Enum.into(0..0xF, %{}, &{&1, 0}),
       timer_cycles: 0,
       timer_sound: 0,
       timer_delay: 0
     }}
  end

  def handle_call(:get_pc, _from, state = %{pc: pc}), do: {:reply, pc, state}

  # goto NNN
  def handle_call(<<0x1::1*4, nnn::1*12>>, _from, state) do
    state = %{state | pc: nnn}

    {:reply, state, state}
  end

  # Vx = NN
  def handle_call(<<0x6::1*4, x::1*4, nn::1*8>>, _from, state = %{v: v, pc: pc}) do
    v = Map.put(v, x, nn)

    state = %{state | v: v, pc: pc + 2}

    {:reply, state, state}
  end

  # Vx = Vx ^ Vy
  def handle_call(<<0x8::1*4, x::1*4, y::1*4, 0x3::1*4>>, _from, state = %{v: v, pc: pc}) do
    vx = Map.get(v, x)
    vy = Map.get(v, y)

    state = %{state | v: Map.put(v, x, vx ^^^ vy), pc: pc + 2}

    {:reply, state, state}
  end

  # I = NNN
  def handle_call(<<0xA::1*4, nnn::1*12>>, _from, state = %{pc: pc}) do
    state = %{state | i: nnn, pc: pc + 2}

    {:reply, state, state}
  end

  # reg_dump(Vx, &I)
  def handle_call(<<0xF::1*4, x::1*4, 0x5::1*4, 0x5::1*4>>, _from, state = %{v: v, i: i, pc: pc}) do
    0..x
    |> Enum.map(&Map.get(v, &1))
    |> Enum.reduce(i, fn byte, addr ->
      Memory.write(addr, byte, :byte)
      addr + 2
    end)

    state = %{state | pc: pc + 2}

    {:reply, state, state}
  end

  # Fail soft, so we don't have to restart the app all the time during debugging
  def handle_call(cmd, _from, state), do: {:reply, {:error, {:not_implemented, cmd}}, state}
end
