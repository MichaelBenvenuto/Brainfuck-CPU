library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.bf_types.all;

entity bf_cpu is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        o_data : out std_logic_vector(7 downto 0)
    );
end bf_cpu;

architecture arch of bf_cpu is
    signal pcu : std_logic_vector(15 downto 0);
    signal instr : std_logic_vector(7 downto 0);

    signal f_pcu : std_logic_vector(15 downto 0);
    signal e_loopback_ptr : std_logic_vector(15 downto 0);

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

    signal e_skip : std_logic;
    signal e_skip_addr : std_logic_vector(15 downto 0);

    signal e_loopback : std_logic;

    signal stack_en, stack_push : std_logic;
    signal uart_en, uart_wr : std_logic;
begin

    e_loopback <= '1' when (e_loopstack_op = POP and e_data /= x"00") else '0';
    PROG_COUNTER : entity work.bf_pcu
    port map (
        i_clk => i_clk,
        i_rst => i_rst,

        i_loopback => e_loopback,
        i_loopback_ptr => e_loopback_ptr,

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

        i_skip => e_skip,

        o_adder_src => e_adder_src,
        o_adder_dst => e_adder_dst,
        o_adder_op => e_adder_op,
        o_loopstack_op => e_loopstack_op,

        o_uart_en => uart_en,
        o_uart_wr => uart_wr
    );

    ALU : entity work.bf_alu
    port map(
        i_data => e_alu_input,
        i_op => e_adder_op,
        o_res => e_alu_out
    );

    stack_en <= '1' when (e_loopstack_op /= NONE and (e_loopstack_op /= POP or e_data = x"00")) else '0';
    stack_push <= '1' when (e_loopstack_op = PUSH) else '0';
    STACK : entity work.bf_stack
    port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_en => stack_en,
        i_push => stack_push,
        
        i_push_data => pcu,
        o_pop_data => e_loopback_ptr
    );

    e_alu_input <= (x"00" & e_data) when (e_adder_src = VALUE) else d_regfile_addr;

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                d_regfile_addr <= (others => '0');
                e_regfile_addr <= (others => '0');
                e_skip_addr <= (others => '0');
                e_skip <= '0';
            else
                e_regfile_addr <= d_regfile_addr;
                d_regfile_addr <= regfile_read_addr;

                if e_skip_addr = e_loopback_ptr and e_loopstack_op = POP then
                    e_skip <= '0';
                end if;

                if e_data = x"00" and e_loopstack_op = PUSH then
                    e_skip <= '1';
                    e_skip_addr <= e_loopback_ptr;
                end if;
            end if;
        end if;
    end process;

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_data <= (others => '0');
            else
                if (uart_en and uart_wr) = '1' then
                    o_data <= e_data;
                end if;
            end if;
        end if;
    end process;

end arch;