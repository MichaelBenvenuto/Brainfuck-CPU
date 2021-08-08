library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

-- inputs:
-- i_clk : system hw clock
-- i_rst : system hw reset
-- i_prg : system programming signal
-- i_read_addr : instruction read address (PCU)
-- i_prg_addr : programming write address
-- i_prg_data : programming data

-- outputs:
-- o_hold : signal for halting CPU pipeline
-- o_read_data : instruction read from imem

entity bf_imem is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_prg : in std_logic;
        o_hold : out std_logic;

        i_read_addr : in std_logic_vector(15 downto 0);
        o_read_data : out std_logic_vector(7 downto 0);

        i_prg_addr : in std_logic_vector(15 downto 0);
        i_prg_data : in std_logic_vector(7 downto 0)
    );
end bf_imem;

architecture arch of bf_imem is
    type memory_t is array(0 to 65535) of std_logic_vector(7 downto 0);

    impure function init_ram_hex(dir : in string) return memory_t is
        file text_file : text open read_mode is dir;
        variable text_line : line;
        variable ram_content : memory_t;
    begin
        for i in memory_t'range loop
            readline(text_file, text_line);
            hread(text_line, ram_content(i));
        end loop;
        return ram_content;
    end function;

    signal memory : memory_t := init_ram_hex("test.hex");
begin
    process(i_clk)
    begin

    if (i_rst or i_prg) = '1' then
        o_read_data <= (others => '0');
        if i_prg = '1' then
            memory(to_integer(unsigned(i_prg_addr))) <= i_prg_data;
        end if;
    else
        o_read_data <= memory(to_integer(unsigned(i_read_addr)));
    end if;

    end process;
end arch;