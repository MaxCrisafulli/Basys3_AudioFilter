library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lib_clock_divider;

entity clock_controller_pll is
    generic(
        M_S_RATIO : integer := 8;
        M_L_RATIO : integer := 512
    );
    port(
        CLK_100M : in  std_logic;       -- Master Clock, runs at 512x SCLK or MCLK (24.576 Mhz). Comes from PLL
        nRst     : in  std_logic;       -- Active Low Asynchronous Reset
        MCLK     : out std_logic;       -- Master clock, runs at 24.576MHz
        SCLK     : out std_logic;       -- Serial clock, runs at MCLK/8 (3.072 MHz)
        LRCK     : out std_logic        -- Word clock, runs at sampling rate (48kHz) or MCLK/512

    );
end entity clock_controller_pll;

architecture sim of clock_controller_pll is
    signal SCLK_BUF : std_logic;
    signal LCLK_BUF : std_logic;
    signal MCLK_BUF : std_logic := '0';

    constant MCLK_T : time := 1e6 us / (24.576e6);

begin

    MCLK_BUF <= not MCLK_BUF after MCLK_T / 2;

    SCLK_DIVIDER : entity lib_clock_divider.clock_divider
        generic map(
            DIV_RATIO => M_S_RATIO
        )
        port map(
            clk_in  => MCLK_BUF,
            nRst    => nRst,
            clk_out => SCLK_BUF
        );

    LCLK_DIVIDER : entity lib_clock_divider.clock_divider
        generic map(
            DIV_RATIO => M_L_RATIO
        )
        port map(
            clk_in  => MCLK_BUF,
            nRst    => nRst,
            clk_out => LCLK_BUF
        );

    CLK_OUT_BUFFER : process(SCLK_BUF, LCLK_BUF, MCLK_BUF, nRst)
    begin
        if (nRst = '0') then
            MCLK <= '0';
            SCLK <= '0';
            LRCK <= '0';
        else
            SCLK <= SCLK_BUF;
            LRCK <= LCLK_BUF;
            MCLK <= MCLK_BUF;
        end if;
    end process;

end architecture sim;
