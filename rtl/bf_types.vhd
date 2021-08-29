library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package bf_types is

    type system_t is record
        clk : std_logic;
        rst : std_logic;
        halt : std_logic;
    end record system_t;

    type programmer_t is record
        en : std_logic;
        addr : pcu_t;
        data : instr_t;
    end record programmer_t;

    type decode_t is record
        rf_wb : std_logic;
        pcu : pcu_t;
        data : data_t;
        alu_op : alu_op_t;
        stack_op : stack_op_t;
        pcu_op : pcu_op_t;
        inc_op : inc_op_t;
        uart_op : uart_op_t;
    end record decode_t;

    subtype pcu_t is unsigned(12 downto 0);
    subtype data_t is std_logic_vector(7 downto 0);
    subtype instr_t is std_logic_vector(7 downto 0);

    type alu_op_t is (ADD, SUB, NONE);
    type stack_op_t is (PUSH, POP, NONE);
    type pcu_op_t is (INCR, JUMP);
    type inc_op_t is (INCR, DECR, NONE);
    type uart_op_t is (WRITE, READ, NONE);

    type instr_mem_t is array(0 to 2**pcu_t'length) of instr_t;
    type reg_mem_t is array(natural range <>) of data_t;
    type stack_mem_t is array(natural range <>) of pcu_t;

end package bf_types;