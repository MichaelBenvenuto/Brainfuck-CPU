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

    signal f_pcu : std_logic_vector(15 downto 0);

    signal d_regfile_addr : std_logic_vector(15 downto 0);
    signal e_regfile_addr : std_logic_vector(15 downto 0);
    signal regfile_read_addr : std_logic_vector(15 downto 0);

    signal e_adder_src : adder_src;
    signal e_adder_dst : adder_dst;
    signal e_adder_op : adder_op;
    signal e_loopstack_op : loopstack_op;

    signal regfile_wr : std_logic;

    signal e_data : std_logic_vector(7 downto 0);

    signal e_alu_input : std_logic_vector(15 downto 0);
    signal e_alu_out : std_logic_vector(15 downto 0);
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

        o_pcu => f_pcu
    );

    regfile_wr <= '1' when (e_adder_dst = VALUE) else '0';
    regfile_read_addr <= e_alu_out when (e_adder_dst = POINTER) else d_regfile_addr;
    REGISTER_FILE : entity work.bf_regfile
    port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_wr => regfile_wr, -- write triggered from execute stage
        i_wr_addr => d_regfile_addr,
        i_wr_data => e_alu_out(7 downto 0),

        i_rd_addr => regfile_read_addr,
        o_rd_data => e_data
    );

    CONTROLLER : entity work.bf_control
    port map(
        i_instr => instr,

        o_adder_src => e_adder_src,
        o_adder_dst => e_adder_dst,
        o_adder_op => e_adder_op,
        o_loopstack_op => e_loopstack_op
    );

    ALU : entity work.bf_alu
    port map(
        i_data => e_alu_input,
        i_op => e_adder_op,
        o_res => e_alu_out
    );

    e_alu_input <= (x"00" & e_data) when (e_adder_src = VALUE) else e_regfile_addr;

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                d_regfile_addr <= (others => '0');
                e_regfile_addr <= (others => '0');
            else
                e_regfile_addr <= d_regfile_addr;
                d_regfile_addr <= regfile_read_addr;
            end if;
        end if;
    end process;

end arch;