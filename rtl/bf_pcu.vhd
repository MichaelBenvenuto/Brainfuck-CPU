library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- inputs:
-- i_clk : system hw clock
-- i_rst : system hw reset
-- i_loopback : conditional representing whether or not the hw loop should be executed
--      * also pops the loopback pointer off the stack if condition is not met
--      * condition: (*data != 0 and *o_pcu == instr_opcode(']'))
-- i_loopback_ptr : the hardware loop to the start of the loop

-- outputs:
-- o_pcu : the counter pointing to the next instruction

entity bf_pcu is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_loopback : in std_logic;
        i_loopback_ptr : in std_logic_vector(9 downto 0);

        o_pcu : out std_logic_vector(9 downto 0)
    );
end bf_pcu;

architecture arch of bf_pcu is
    signal pcu : std_logic_vector(9 downto 0) := (others => '0');
    signal pcu_x : std_logic_vector(9 downto 0);
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                pcu <= (others => '0');
            else
                pcu <= pcu_x + '1';
            end if;
        end if;
    end process;

    pcu_x <= i_loopback_ptr when i_loopback = '1' else pcu;
    o_pcu <= pcu_x;
end arch;