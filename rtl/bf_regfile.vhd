library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity bf_regfile is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_wr : in std_logic;
        i_wr_addr : in std_logic_vector(15 downto 0);
        i_wr_data : in std_logic_vector(7 downto 0);

        i_rd_addr : in std_logic_vector(15 downto 0);
        o_rd_data : out std_logic_vector(7 downto 0)
    );
end bf_regfile;

architecture arch of bf_regfile is
    type memory_t is array(0 to 65535) of std_logic_vector(7 downto 0);
begin
    process(i_clk)
        variable memory : memory_t := (others => x"00");
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_rd_data <= (others => '0');
            else
                if i_wr = '1' then
                    memory(to_integer(unsigned(i_wr_addr))) := i_wr_data;
                end if;

                o_rd_data <= memory(to_integer(unsigned(i_rd_addr)));
            end if;
        end if;
    end process;
end arch;