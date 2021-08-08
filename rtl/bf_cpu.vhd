library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity bf_cpu is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic
    );
end bf_cpu;

architecture arch of bf_cpu is
    signal pcu : std_logic_vector(15 downto 0);
    signal instr : std_logic_vector(7 downto 0);
begin

    PROG_COUNTER : entity work.bf_pcu
    port map (
        i_clk => i_clk,
        i_rst => i_rst,

        i_loopback => '0',
        i_loopback_ptr => (others => '0'),

        o_pcu => pcu
    );

    INSTR_MEM : entity work.bf_imem
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_prg => '0',

        i_prg_addr => (others => '0'),
        i_prg_data => (others => '0'),
        
        i_read_addr => pcu,
        o_read_data => instr
    );

end arch;