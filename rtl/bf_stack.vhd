library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity bf_stack is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_en : in std_logic;
        i_push : in std_logic;


        o_empty : out std_logic;
        o_full : out std_logic;

        i_push_data : in std_logic_vector(15 downto 0);
        o_pop_data : out std_logic_vector(15 downto 0)
    );
end bf_stack;

architecture arch of bf_stack is
    type memory_t is array(0 to 1023) of std_logic_vector(15 downto 0);
    signal memory : memory_t := (others => x"0000");
begin
    process(i_clk)
        variable pointer : std_logic_vector(9 downto 0);
        variable empty, full : std_logic;
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                pointer := (others => '0');
                o_pop_data <= (others => '0');
                pointer := (others => '0');
                empty := '0';
                full := '0';
                o_empty <= '0';
                o_full <= '0';
            else
                if i_en = '1' then
                    if i_push = '1' and full = '0' then
                        memory(to_integer(unsigned(pointer))) <= i_push_data;
                        o_pop_data <= i_push_data;
                        pointer := pointer + '1';
                        if pointer = x"FFFF" then
                            full := '1';
                            empty := '0';
                            o_pop_data <= (others => '0');
                        else
                            full := '0';
                            empty := '0';
                        end if;
                    elsif i_push = '0' and empty = '0' then
                        pointer := pointer - '1';
                        o_pop_data <= memory(to_integer(unsigned(pointer - '1')));
                        if pointer = x"0000" then
                            o_pop_data <= (others => '0');
                            full := '0';
                            empty := '1';
                        else
                            full := '0';
                            empty := '0';
                        end if;
                    else
                        o_pop_data <= (others => '0');
                    end if;
                end if;

                o_empty <= empty;
                o_full <= full;
            end if;
        end if;
    end process;
end arch;