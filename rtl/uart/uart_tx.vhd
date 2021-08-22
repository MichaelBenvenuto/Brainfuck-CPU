library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity uart_tx is
    generic(
        BASE_CLOCK : integer := 100e6;
        UART_BAUD : integer := 115200
    );
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_en : in std_logic;
        i_data : in std_logic_vector(7 downto 0);

        o_intf_txd : out std_logic;

        o_busy : out std_logic
    );
end uart_tx;

architecture arch of uart_tx is
    constant SAMPLE_DIV_VAL : integer := integer(real(BASE_CLOCK)/real(16*UART_BAUD));

    signal val_reg, val_reg_x : std_logic_vector(7 downto 0);

    signal en_sample : std_logic;

    signal sample_ctr : std_logic_vector(3 downto 0);
    signal bit_ctr, bit_ctr_x : std_logic_vector(2 downto 0);

    type UART_TX_STATE is (IDLE, START, DATA, STOP);
    signal state, state_x : UART_TX_STATE;

    signal div_en : std_logic;
begin

    SAMPLE_CLK_DIV : entity work.uart_div
    generic map(
        DIVIDER_VAL => SAMPLE_DIV_VAL
    )
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_en => div_en,

        o_clk_en => en_sample
    );

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                val_reg <= (others => '0');
                sample_ctr <= (others => '0');
                bit_ctr <= (others => '0');
                state <= IDLE;
            else
                if en_sample = '1' then
                    sample_ctr <= sample_ctr + '1';
                    if sample_ctr = x"F" then
                        sample_ctr <= (others => '0');
                    end if;
                end if;

                val_reg <= val_reg_x;
                state <= state_x;
                bit_ctr <= bit_ctr_x;
            end if;
        end if;
    end process;

    process(state, i_en, i_data, en_sample, sample_ctr, bit_ctr, val_reg)
    begin
        o_intf_txd <= val_reg(0);
        div_en <= '1';
        o_busy <= '1';
        val_reg_x <= val_reg;
        state_x <= state;
        bit_ctr_x <= bit_ctr;
        case state is
            when IDLE =>
                div_en <= i_en;
                o_busy <= '0';
                o_intf_txd <= '1';
                if i_en = '1' then
                    val_reg_x <= i_data;
                    o_intf_txd <= '0';
                    state_x <= START;
                end if;
            when START =>
                o_intf_txd <= '0';
                if sample_ctr = x"F" and en_sample = '1' then
                    state_x <= DATA;
                    bit_ctr_x <= (others => '0');
                end if;
            when DATA =>
                if sample_ctr = x"F" and en_sample = '1' then
                    val_reg_x <= '0' & val_reg(7 downto 1);
                    if bit_ctr = x"7" then
                        bit_ctr_x <= (others => '0');
                        state_x <= STOP;
                    else
                        bit_ctr_x <= bit_ctr + '1';
                    end if;
                end if;
            when STOP =>
                o_intf_txd <= '1';
                if sample_ctr = x"F" and en_sample = '1' then
                    state_x <= IDLE;
                end if;
        end case;
    end process;

end arch;