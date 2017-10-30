library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity sram_controller is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        InputSW ：in std_logic_vector(WORD_WIDTH - 1 downto 0);
        OutputLED : out std_logic_vector(WORD_WIDTH - 1 downto 0);
        
        -- connect to sram1
        RAM1_ADDR: out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        RAM1_DQ: inout std_logic_vector(WORD_WIDTH - 1 downto 0);
        RAM1_nWE: out std_logic;
        RAM1_nOE: out std_logic;
        RAM1_EN: out std_logic;

        -- connect to sram2
        RAM2_ADDR: out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        RAM2_DQ: inout std_logic_vector(WORD_WIDTH - 1 downto 0);
        RAM2_nWE: out std_logic;
        RAM2_nOE: out std_logic;
        RAM2_EN: out std_logic;
        
    );
end;

architecture behavioral of sram_controller is
    type state_t is (st_init, st_get_addr, st_write1, st_read1_st, st_read1, st_write2, st_read2_st, st_read2);
    signal addr: std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal data: std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal current_state: state_t;
begin

    process(CLK, RST)
    begin
        if RST = '1' then
            current_state <= st_init;
            OutputLED <= x"0000";
            RAM1_EN <= '0';
            RAM2_EN <= '0';
        else
            if rising_edge(CLK) then
                case current_state is
                    when st_init =>
                        current_state <= st_get_addr;
                        addr <= "00" & InputSW;
                        OutputLED <= InputSW;
                    when st_get_addr =>
                        current_state <= st_write1;
                        RAM1_EN <= '1';
                        RAM1_DQ <= InputSW;
                        RAM1_ADDR <= addr;
                        RAM1_nWE <= '0';
                        RAM1_nOE <= '1';
                        OutputLED <= InputSW;
                    when st_write1 =>
                        current_state <= st_read1_st;
                        RAM1_DQ <= "ZZZZZZZZZZZZZZZZ";
                        RAM1_ADDR <= addr;
                        RAM1_nWE <= '1';
                        RAM1_nOE <= '0';
                    when st_read1_st =>
                        current_state <= st_read1;
                        OutputLED <= RAM1_DQ;
                        data <= RAM1_DQ;
                    when st_read1 =>
                        current_state <= st_write2;
                        RAM1_EN <= '0';
                        RAM2_EN <= '1';
                        RAM2_DQ <= data + 1;
                        RAM2_ADDR <= addr;
                        RAM2_nWE <= '0';
                        RAM2_nOE <= '1';
                        OutputLED <= data + 1;                  
                    when st_write2 =>
                        current_state <= st_read2_st;
                        RAM2_DQ <= "ZZZZZZZZZZZZZZZZ";
                        RAM2_ADDR <= addr;
                        RAM2_nWE <= '1';
                        RAM2_nOE <= '0';
                    when st_read2_st =>
                        current_state <= st_read2;
                        OutputLED <= RAM2_DQ;
                        data <= RAM2_DQ;
                    when others =>
                        current_state <= st_init;
                        OutputLED <= x"0000";
                        RAM1_EN <= '0';
                        RAM2_EN <= '0';
                end case;
            end if;
        end if;
    end process;
end;
