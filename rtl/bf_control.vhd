library IEEE;
use IEEE.std_logic_1164.all;
use work.bf_types.all;

entity bf_control is
    port(
        i_instr : in std_logic_vector(7 downto 0);

        i_skip : in std_logic;

        o_adder_src : out adder_src;
        o_adder_dst : out adder_dst;
        o_adder_op  : out adder_op;
        o_loopstack_op : out loopstack_op;

        o_uart_en : out std_logic;
        o_uart_wr : out std_logic
    );
end bf_control;

architecture arch of bf_control is
begin
    process(i_instr, i_skip) begin
        o_adder_src <= VALUE;
        o_adder_dst <= NONE;
        o_loopstack_op <= NONE;
        o_adder_op <= ADD;
        o_uart_en <= '0';
        o_uart_wr <= '0';
        if i_skip = '0' then
            case i_instr(7 downto 4) is
                when x"3" =>
                    if i_instr(3 downto 0) = x"c" then
                        o_adder_src <= POINTER;
                        o_adder_dst <= POINTER;
                        o_adder_op <= SUB;
                    elsif i_instr(3 downto 0) = x"e" then
                        o_adder_src <= POINTER;
                        o_adder_dst <= POINTER;
                        o_adder_op <= ADD;
                    end if;
                when x"2" =>
                    if i_instr(3 downto 0) = x"b" then
                        o_adder_dst <= VALUE;
                    elsif i_instr(3 downto 0) = x"c" then
                        o_uart_en <= '1';
                        o_uart_wr <= '0';
                    elsif i_instr(3 downto 0) = x"d" then
                        o_adder_op <= SUB;
                        o_adder_dst <= VALUE;
                    elsif i_instr(3 downto 0) = x"e" then
                        o_uart_en <= '1';
                        o_uart_wr <= '1';
                    end if;
                when x"5" =>
                    if i_instr(3 downto 0) = x"b" then
                        o_loopstack_op <= PUSH;
                    elsif i_instr(3 downto 0) = x"d" then
                        o_loopstack_op <= POP;
                    end if;
                when others =>
                    o_adder_src <= VALUE;
                    o_adder_dst <= NONE;
                    o_loopstack_op <= NONE;
                    o_adder_op <= ADD;
            end case;
        end if;
    end process;
end arch;
