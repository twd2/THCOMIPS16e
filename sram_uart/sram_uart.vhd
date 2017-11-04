library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;

entity sram_uart is
    port
    (
        CLK: in std_logic;
        KEY0: in std_logic;
        nRST: in std_logic;
        nInputSW: in std_logic_vector(WORD_WIDTH - 1 downto 0);

        SYSBUS_ADDR: out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        SYSBUS_DQ: inout std_logic_vector(WORD_WIDTH - 1 downto 0);
        RAM1_nWE: out std_logic;
        RAM1_nOE: out std_logic;
        RAM1_nCE: out std_logic;
        
        EXTBUS_ADDR: out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        EXTBUS_DQ: inout std_logic_vector(WORD_WIDTH - 1 downto 0);
        RAM2_nWE: out std_logic;
        RAM2_nOE: out std_logic;
        RAM2_nCE: out std_logic;
        
        UART_nRE: out std_logic;
        UART_READY: in std_logic;
        
        UART_nWE: out std_logic;
        UART_TBRE: in std_logic;
        UART_TSRE: in std_logic
    );
end;

architecture behavioral of sram_uart is
    type state_t is (st_init, st_read_init, st_read_wait, st_read,
                     st_write_sram, st_clear_bus_1, st_clear_bus_2, st_read_sram, st_read_sram_wait,
                     st_write_init, st_write, st_write_wait);
    signal current_state: state_t;
    
    signal InputSW: std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal RST: std_logic;
    signal SYSBUS_DIN, SYSBUS_DOUT: std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal SYSBUS_DEN: std_logic;
    signal EXTBUS_DIN, EXTBUS_DOUT: std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal EXTBUS_DEN: std_logic;
    signal addr: std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal data: std_logic_vector(WORD_WIDTH - 1 downto 0);
begin
    RST <= not nRST;
    InputSW <= not nInputSW;
    SYSBUS_DQ <= SYSBUS_DOUT when SYSBUS_DEN = '1' else (others => 'Z');
    SYSBUS_DIN <= SYSBUS_DQ;
    EXTBUS_DQ <= EXTBUS_DOUT when EXTBUS_DEN = '1' else (others => 'Z');
    EXTBUS_DIN <= EXTBUS_DQ;
    RAM1_nCE <= '0';
    RAM2_nCE <= '0';

    process(KEY0, RST)
    begin
        if RST = '1' then
            addr <= (others => '0');
        elsif rising_edge(KEY0) then
            addr <= "00" & InputSW;
        end if;
    end process;

    process(CLK, RST)
    begin
        if RST = '1' then
            RAM1_nWE <= '1'; -- disable sram
            RAM1_nOE <= '1';
            UART_nRE <= '1'; -- disable uart
            SYSBUS_ADDR <= (others =>'0');
            SYSBUS_DEN <= '0'; -- disable fpga
            SYSBUS_DOUT <= (others => '0');
            EXTBUS_ADDR <= (others =>'0');
            EXTBUS_DEN <= '0';
            EXTBUS_DOUT <= (others => '0');
            current_state <= st_init;
        elsif rising_edge(CLK) then
            case current_state is
                when st_init =>
                    current_state <= st_read_init;
                when st_read_init =>
                    RAM1_nWE <= '1'; -- disable sram
                    RAM1_nOE <= '1';
                    UART_nRE <= '1'; -- disable uart
                    SYSBUS_DEN <= '0'; -- disable fpga
                    current_state <= st_read_wait;
                when st_read_wait =>
                    if UART_READY = '1' then
                        UART_nRE <= '0';
                        current_state <= st_read;
                    end if;
                when st_read =>
                    data <= SYSBUS_DIN;
                    UART_nRE <= '1';
                    current_state <= st_write_sram;
                when st_write_sram =>
                    -- sram 1
                    RAM1_nWE <= '0';
                    RAM1_nOE <= '1';
                    SYSBUS_ADDR <= addr;
                    SYSBUS_DEN <= '1';
                    SYSBUS_DOUT <= data + 1;
                    -- sram 2
                    RAM2_nWE <= '0';
                    RAM2_nOE <= '1';
                    EXTBUS_ADDR <= addr;
                    EXTBUS_DEN <= '1';
                    EXTBUS_DOUT <= data + 2;
                    current_state <= st_clear_bus_1;
                when st_clear_bus_1 =>
                    -- sram 1
                    RAM1_nWE <= '1';
                    SYSBUS_DOUT <= x"05AF";
                    -- sram 2
                    RAM2_nWE <= '1';
                    EXTBUS_DOUT <= x"FA50";
                    current_state <= st_clear_bus_2;
                when st_clear_bus_2 =>
                    SYSBUS_DEN <= '0';
                    EXTBUS_DEN <= '0';
                    current_state <= st_read_sram;
                when st_read_sram =>
                    -- sram 1
                    RAM1_nWE <= '1';
                    RAM1_nOE <= '0';
                    SYSBUS_ADDR <= addr;
                    SYSBUS_DEN <= '0';
                    -- sram 2
                    RAM2_nWE <= '1';
                    RAM2_nOE <= '0';
                    EXTBUS_ADDR <= addr;
                    EXTBUS_DEN <= '0';
                    current_state <= st_read_sram_wait;
                when st_read_sram_wait =>
                    -- sram 1
                    RAM1_nOE <= '1';
                    SYSBUS_DEN <= '0';
                    data <= SYSBUS_DIN;
                    -- sram 2
                    RAM2_nOE <= '1';
                    EXTBUS_DEN <= '0';
                    -- EXTBUS_DIN?
                    current_state <= st_write_init;
                when st_write_init =>
                    SYSBUS_DEN <= '1';
                    UART_nWE <= '1';
                    SYSBUS_DOUT <= data;
                    current_state <= st_write;
                when st_write =>
                    UART_nWE <= '0';
                    current_state <= st_write_wait;
                when st_write_wait =>
                    UART_nWE <= '1';
                    if UART_TBRE = '1' and UART_TSRE = '1' then
                        current_state <= st_read_init;
                    end if;
                when others =>
                    current_state <= st_init;
            end case;
        end if;
    end process;
end;
