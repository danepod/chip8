defmodule DisassemblerTest do
  use ExUnit.Case

  test "disp_clear()" do
    assert Disassembler.disassemble(<<0, 0, 0xE, 0>>) == "disp_clear()"
  end
end
