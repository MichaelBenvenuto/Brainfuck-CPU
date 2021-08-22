library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity uart_rx is
    generic(
        BASE_CLOCK : integer := 100e6;
        UART_BAUD : integer := 115200
    );
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_intf_rxd : in std_logic;

        o_data_r : out std_logic;
        o_data : out std_logic_vector(7 downto 0)
    );
end uart_rx;

architecture arch of uart_rx is

    constant SAMPLE_DIV_VAL : integer := integer(real(BASE_CLOCK)/real(16*UART_BAUD));

    signal sample_ctr : std_logic_vector(3 downto 0);
    signal bit_ctr, bit_ctr_x : std_logic_vector(2 downto 0);

    signal en_sample : std_logic;
    signal div_en, div_en_x : std_logic;
    signal rxd_state, rxd_state_x, o_data_r_x : std_logic;

    signal rxd_shift_reg, rxd_shift_reg_x, o_data_x : std_logic_vector(7 downto 0);

    signal sample, sample_x : std_logic_vector(3 downto 0);

    type UART_RX_STATE is (IDLE, START, DATA, STOP);
    signal state, state_x : UART_RX_STATE;
begin

    SAMPLE_DIV_CLK : entity work.uart_div
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
                sample_ctr <= (others => '0');
                bit_ctr <= (others => '0');
                rxd_state <= '1';
                rxd_shift_reg <= (others => '0');
                state <= IDLE;
                sample <= (others => '0');
                o_data <= (others => '0');
                o_data_r <= '0';
            else
                if en_sample = '1' then
                    sample_ctr <= sample_ctr + '1';
                    if sample_ctr = x"F" then
                        sample_ctr <= (others => '0');
                    end if;
                end if;
                
                rxd_state <= rxd_state_x;

                div_en <= div_en_x;
                rxd_shift_reg <= rxd_shift_reg_x;
                sample <= sample_x;
                state <= state_x;
                bit_ctr <= bit_ctr_x;
                o_data_r <= o_data_r_x;
                o_data <= o_data_x;
            end if;
        end if;
    end process;

    process(state, i_intf_rxd, sample_ctr, bit_ctr, rxd_state, sample, rxd_shift_reg, div_en)
    begin
        rxd_state_x <= i_intf_rxd;
        rxd_shift_reg_x <= rxd_shift_reg;
        bit_ctr_x <= bit_ctr;
        sample_x <= sample;
        state_x <= state;
        o_data_x <= (others => '0');
        o_data_r_x <= '0';
        div_en_x <= div_en;

        if en_sample = '1' then
            sample_x <= sample + i_intf_rxd;
        end if;

        case state is
            when IDLE =>
                div_en_x <= '0';
                if i_intf_rxd /= rxd_state then
                    state_x <= START;
                    sample_x <= (others => '0');
                    div_en_x <= '1';
                end if;
            when START =>
                if sample_ctr = x"F" and en_sample = '1' then
                    if sample(3 downto 2) = "00" then
                        sample_x <= (others => '0');
                        bit_ctr_x <= (others => '0');
                        state_x <= DATA;
                    end if;
                end if;
            when DATA =>
                if sample_ctr = x"F" and en_sample = '1' then
                    rxd_shift_reg_x <= sample(3) & rxd_shift_reg(7 downto 1);
                    bit_ctr_x <= bit_ctr + '1';
                    sample_x <= (others => '0');
                    if bit_ctr = x"7" then
                        bit_ctr_x <= (others => '0');
                        state_x <= STOP;
                    end if;
                end if;
            when STOP =>
                if sample_ctr = x"F" and en_sample = '1' then
                    if sample = x"F" then
                        o_data_x <= rxd_shift_reg;
                        o_data_r_x <= '1';
                    end if;
                    state_x <= IDLE;
                end if;
        end case;
    end process;

end arch;