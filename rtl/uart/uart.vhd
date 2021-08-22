library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity uart is
    generic(
        BASE_CLOCK : integer := 100e6;
        UART_BAUD : integer := 115200
    );
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_en : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_data : out std_logic_vector(7 downto 0)
    );
end uart;

architecture arch of uart is
    signal txd : std_logic;
begin
    UART_TX : entity work.uart_tx
    generic map(
        BASE_CLOCK => BASE_CLOCK,
        UART_BAUD => UART_BAUD
    )
    port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_en => i_en,
        i_data => i_data,

        o_intf_txd => txd
    );

    UART_RX : entity work.uart_rx
    generic map(
        BASE_CLOCK => BASE_CLOCK,
        UART_BAUD => UART_BAUD
    )
    port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_intf_rxd => txd,

        o_data => o_data
    );
end arch;