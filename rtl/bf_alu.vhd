library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.bf_types.all;

entity bf_alu is
    port(
        i_data : in std_logic_vector(15 downto 0);

        i_op : in adder_op;

        o_res : out std_logic_vector(15 downto 0)
    );
end bf_alu;

architecture arch of bf_alu is
    signal carry : std_logic_vector(15 downto 0);
    signal op_add : std_logic;
begin
    op_add <= '1' when (i_op = ADD) else '0';
    carry(0) <= i_data(0) xor not op_add;
    o_res(0) <= not i_data(0);
    GEN_CARRIES : for i in 1 to 15 generate
        o_res(i) <= i_data(i) xor carry(i - 1);
        carry(i) <= ((not op_add xor i_data(i)) and carry(i - 1));
    end generate GEN_CARRIES;
end arch;