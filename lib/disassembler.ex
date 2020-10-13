defmodule Disassembler do
  def disassemble(<<0, 0, 0xE, 0>>), do: "disp_clear()"
  def disassemble(<<0, 0, 0xE, 0xE>>), do: "return"
  def disassemble(<<1, n1, n2, n3>>), do: "goto #{print(<<n1::4>>, <<n2::4>>, <<n3::4>>)}"
  def disassemble(<<2, n1, n2, n3>>), do: "*(0x#{print(<<n1::4>>, <<n2::4>>, <<n3::4>>)})()"
  def disassemble(<<3, x, n1, n2>>), do: "if (V#{x} == #{print(<<n1::4>>, <<n2::4>>)})"
  def disassemble(<<4, x, n1, n2>>), do: "if (V#{x} != #{print(<<n1::4>>, <<n2::4>>)})"
  def disassemble(<<5, x, y, 0>>), do: "if (V#{x} == V#{y})"
  def disassemble(<<6, x, n1, n2>>), do: "V#{x} = #{print(<<n1::4>>, <<n2::4>>)}"
  def disassemble(<<7, x, n1, n2>>), do: "V#{x} += #{print(<<n1::4>>, <<n2::4>>)}"
  def disassemble(<<8, x, y, 0>>), do: "V#{x} = V#{y}"
  def disassemble(<<8, x, y, 1>>), do: "V#{x} = V#{x} | V#{y}"
  def disassemble(<<8, x, y, 2>>), do: "V#{x} = V#{x} & V#{y}"
  def disassemble(<<8, x, y, 3>>), do: "V#{x} = V#{x} ^ V#{y}"
  def disassemble(<<8, x, y, 4>>), do: "V#{x} += V#{y}"
  def disassemble(<<8, x, y, 5>>), do: "V#{x} -= V#{y}"
  def disassemble(<<8, x, _y, 6>>), do: "V#{x} >>= 1"
  def disassemble(<<8, x, y, 7>>), do: "V#{x} = V#{y} - V#{x}"
  def disassemble(<<8, x, _y, 0xE>>), do: "V#{x} <<= 1"
  def disassemble(<<9, x, y, 0>>), do: "if(V#{x} != V#{y})"
  def disassemble(<<0xA, n1, n2, n3>>), do: "I = #{print(<<n1::4>>, <<n2::4>>, <<n3::4>>)}"
  def disassemble(<<0xB, n1, n2, n3>>), do: "PC = V0 + #{print(<<n1::4>>, <<n2::4>>, <<n3::4>>)}"
  def disassemble(<<0xC, x, n1, n2>>), do: "V#{x} = rand() && #{print(<<n1::4>>, <<n2::4>>)}"
  def disassemble(<<0xD, x, y, n>>), do: "draw(V#{x}, V#{y}, #{n})"
  def disassemble(<<0xE, x, 9, 0xE>>), do: "if(key() == V#{x})"
  def disassemble(<<0xE, x, 0xA, 1>>), do: "if(key() != V#{x})"
  def disassemble(<<0xF, x, 0, 7>>), do: "V#{x} = get_delay()"
  def disassemble(<<0xF, x, 0, 0xA>>), do: "V#{x} = get_key()"
  def disassemble(<<0xF, x, 1, 5>>), do: "delay_timer(V#{x})"
  def disassemble(<<0xF, x, 1, 8>>), do: "sound_timer(V#{x})"
  def disassemble(<<0xF, x, 1, 0xE>>), do: "I += V#{x}"
  def disassemble(<<0xF, x, 2, 9>>), do: "I = sprite_addr[V#{x}]"

  def disassemble(<<0xF, x, 3, 3>>),
    do: "set_BCD(V#{x}); *(I+0) = BCD(3); *(I+1) = BCD(2); *(I+2) = BCD(1);"

  def disassemble(<<0xF, x, 5, 5>>), do: "reg_dump(V#{x}, &I)"
  def disassemble(<<0xF, x, 6, 5>>), do: "reg_load(V#{x}, &I)"

  def disassemble(<<n1, n2, n3, n4>>),
    do: "NOT IMPLEMENTED: #{print(<<n1::4>>, <<n2::4>>, <<n3::4>>, <<n4::4>>)}"

  defp print(<<nibble1::4>>, <<nibble2::4>>), do: "#{print_char(nibble1)}#{print_char(nibble2)}"

  defp print(<<nibble1::4>>, <<nibble2::4>>, <<nibble3::4>>),
    do: "#{print_char(nibble1)}#{print_char(nibble2)}#{print_char(nibble3)}"

  defp print(<<nibble1::4>>, <<nibble2::4>>, <<nibble3::4>>, <<nibble4::4>>),
    do: "#{print_char(nibble1)}#{print_char(nibble2)}#{print_char(nibble3)}#{print_char(nibble4)}"

  defp print_char(nibble) do
    case nibble do
      0 -> "0"
      1 -> "1"
      2 -> "2"
      3 -> "3"
      4 -> "4"
      5 -> "5"
      6 -> "6"
      7 -> "7"
      8 -> "8"
      9 -> "9"
      10 -> "A"
      11 -> "B"
      12 -> "C"
      13 -> "D"
      14 -> "E"
      15 -> "F"
    end
  end
end
