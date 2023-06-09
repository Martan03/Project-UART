-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    -- Defining counters
    signal cnt4 : std_logic_vector(3 downto 0);
    signal cnt3  : std_logic_vector(2 downto 0);
    -- Outputs from FSM
    signal rx_cnt3 : std_logic;
    signal rx_cnt4 : std_logic;
    signal rx_end : std_logic;
    signal rx_clr : std_logic;
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CNT4 => cnt4,
        CNT3 => cnt3,
        RX_CNT3 => rx_cnt3,
        RX_CNT4 => rx_cnt4,
        RX_END => rx_end,
        RX_VLD => DOUT_VLD,
        RX_CLR => rx_clr
    );

    
    process(CLK, RST) begin
        -- Reset
        if RST = '1' then
            cnt3 <= (others => '0');
            cnt4 <= (others => '0');
            DOUT <= (others => '0');
            -- Detect rising edge only
        elsif rising_edge(CLK) then
            cnt4 <= (others => '0');

            -- 16 ticks for reading
            if rx_cnt4 = '1' or cnt3 = "111" then
                cnt4 <= cnt4 + 1;
            end if;

            -- Clears output and 4-bit counter
            if rx_clr = '1' then
                DOUT <= (others => '0');
                cnt4 <= (others => '0');
            end if;

            -- 8 ticks offset
            if rx_cnt3 = '1' then
                cnt3 <= cnt3 + 1;
            end if;

            -- Sets output to DIN after 16 ticks
            if cnt4 = "1111" and rx_end = '0' then
                cnt3 <= cnt3 + 1;
                DOUT(to_integer(unsigned(cnt3))) <= DIN;
            end if;
        end if;
    end process;

end architecture;
