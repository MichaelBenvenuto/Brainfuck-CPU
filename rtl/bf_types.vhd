library IEEE;
use IEEE.std_logic_1164.all;

package bf_types is

    type adder_src is (VALUE, POINTER);
    type adder_dst is (VALUE, POINTER, NONE);
    type adder_op  is (ADD, SUB);

    type loopstack_op is (PUSH, POP, NONE);

end package bf_types;