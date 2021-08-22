library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity uart_div is
    generic(
        DIVIDER_VAL : integer := 16
    );
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_en : in std_logic;

        o_clk_en : out std_logic
    );
end uart_div;

architecture arch of uart_div is

    constant DIVIDER_CLOCK_WIDTH : integer := integer(ceil(log2(real(DIVIDER_VAL - 1))));

    signal clock_val : std_logic_vector(DIVIDER_CLOCK_WIDTH - 1 downto 0);

    constant DIVIDER_VAL_VECTOR  : std_logic_vector := std_logic_vector(to_unsigned(DIVIDER_VAL - 1, clock_val'length));
begin

    o_clk_en <= i_en when (clock_val = DIVIDER_VAL_VECTOR) else '0';

    process(i_clk)
    begin
        if falling_edge(i_clk) then
            if (i_rst or not i_en) = '1' then
                clock_val <= (others => '0');
            else
                clock_val <= clock_val + '1';
                if clock_val = DIVIDER_VAL_VECTOR then
                    clock_val <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end arch;