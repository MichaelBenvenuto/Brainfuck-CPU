library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bf_types.all;

entity bf_decode is
    port(
        i_sys : in system_t;

        i_pcu : in pcu_t;
        i_data : in data_t;
        i_instr : in instr_t;

        e_decode : out decode_t
    );
end bf_decode;

architecture arch of bf_decode is
begin
    process(i_sys.clk)
    begin
        if rising_edge(i_sys.clk) then
            e_decode.rf_wb <= '0';
            e_decode.stack_op <= NONE;
            e_decode.pcu_op <= INCR;
            e_decode.inc_op <= NONE;
            e_decode.alu_op <= NONE;
            e_decode.uart_op <= NONE;
            if i_sys.rst = '1' then
                e_decode.pcu <= (others => '0');
                e_decode.data <= (others => '0');
            elsif i_sys.halt = '0' then
                e_decode.pcu <= i_pcu;
                e_decode.data <= i_data;
                case i_instr is
                    when x"2b" =>
                        e_decode.rf_wb <= '1';
                        e_decode.alu_op <= ADD;
                    when x"2d" =>
                        e_decode.rf_wb <= '1';
                        e_decode.alu_op <= SUB;
                    when x"3c" =>
                        e_decode.inc_op <= DECR;
                    when x"3e" =>
                        e_decode.inc_op <= INCR;
                    when x"5b" =>
                        e_decode.stack_op <= PUSH;
                    when x"5d" =>
                        e_decode.pcu_op <= JUMP;
                        e_decode.stack_op <= POP;
                    when x"2c" =>
                        e_decode.uart_op <= READ;
                    when x"2e" =>
                        e_decode.uart_op <= WRITE;
                    when others =>
                        e_decode.uart_op <= NONE;
                end case;
            end if;
        end if;
    end process;
end arch;