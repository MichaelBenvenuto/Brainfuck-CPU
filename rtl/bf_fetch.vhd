library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bf_types.all;

entity bf_fetch is
    port(
        --System-Level Inputs
        i_sys : in system_t;
        i_program : in programmer_t;

        --Jump Related Inputs
        i_jump : in pcu_t;
        i_pcu_op : in pcu_op_t;

        --Register-File Control
        i_rf_inc : in inc_op_t;

        --Register-File Writeback
        i_rf_wb : in std_logic;
        i_rf_wb_data : in data_t;

        --Decode Stage Outputs
        d_pcu : out pcu_t;
        d_data : out data_t;
        d_instr : out instr_t
    );
end bf_fetch;

architecture arch of bf_fetch is
    --PCU Signals------------------------------------
    signal pcu, pcu_x : pcu_t;

    --Instruction Memory Block RAM-------------------
    signal instr_mem : instr_mem_t;

    --Register-File Memory Block RAM-----------------
    signal reg_mem_addr, reg_mem_addr_x : unsigned(0 to 14);
    signal reg_mem : reg_mem_t(0 to 2**reg_mem_addr'length);
begin

    -- Instruction Memory is a "no-change" single port BRAM instance (Implied MUX on addr)
    INSTR_MEMORY_PROC: process(i_sys.clk)
    begin
        if rising_edge(i_sys.clk) then
            if i_program.en = '1' then
                instr_mem(to_integer(i_program.addr)) <= i_program.data;
            else
                d_instr <= instr_mem(to_integer(pcu_x));
            end if;
        end if;
    end process;

    -- Register-File is a "write-first" single port BRAM instance
    reg_mem_addr_x <= 
            (reg_mem_addr + 1) when (i_rf_inc = INCR) else
            (reg_mem_addr - 1) when (i_rf_inc = DECR) else reg_mem_addr;
    REGISTER_FILE_MEM_PROC: process(i_sys.clk)
    begin
        if rising_edge(i_sys.clk) then
            if i_rf_wb = '1' then -- Should be enabled on instrs +,- in stage EX, reg_mem_addr_x should be reg_mem_addr on those instrs
                reg_mem(to_integer(reg_mem_addr_x)) <= i_rf_wb_data;
                d_data <= i_rf_wb_data;
            else
                d_data <= reg_mem(to_integer(reg_mem_addr_x));
            end if;
        end if;
    end process REGISTER_FILE_MEM_PROC;

    pcu_x <= i_jump when (i_pcu_op = JUMP) else pcu;
    process(i_sys.clk)
    begin
        if rising_edge(i_sys.clk) then
            if i_sys.rst = '1' then
                pcu <= (others => '0');
                d_pcu <= (others => '0');
                reg_mem_addr <= (others => '0');
            elsif i_sys.halt = '0' then
                pcu <= pcu_x + 1;
                e_pcu <= pcu;
                reg_mem_addr <= reg_mem_addr_x;
            end if;
        end if;
    end process;
end arch;