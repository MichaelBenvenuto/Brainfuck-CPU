library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.bf_types.all;

entity bf_cpu is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic
    );
end bf_cpu;

architecture arch of bf_cpu is
    signal pcu : std_logic_vector(15 downto 0);
    signal instr : std_logic_vector(7 downto 0);

    signal pcu_fetch : std_logic_vector(15 downto 0);

    signal e_adder_src : adder_src;
    signal e_adder_dst : adder_dst;
    signal e_adder_op : adder_op;
    signal e_loopstack_op : loopstack_op;
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
        o_read_data => instr,

        o_pcu => pcu_fetch
    );

    CONTROLLER : entity work.bf_control
    port map(
        i_instr => instr,

        o_adder_src => e_adder_src,
        o_adder_dst => e_adder_dst,
        o_adder_op => e_adder_op,
        o_loopstack_op => e_loopstack_op
    );

end arch;