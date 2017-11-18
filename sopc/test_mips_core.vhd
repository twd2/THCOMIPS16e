library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity test_mips_sopc is
    port
    (
        dummy1: in std_logic;
        dummy2: out std_logic
    );
end;

architecture behavioral of test_mips_sopc is
    component mips_sopc is
        port
        (
            CLK: in std_logic;
            nRST: in std_logic;

            SYSBUS_ADDR: out word_t;
            SYSBUS_DQ: inout word_t;
            RAM1_nWE: out std_logic;
            RAM1_nOE: out std_logic;
            RAM1_nCE: out std_logic;
            
            EXTBUS_ADDR: out word_t;
            EXTBUS_DQ: inout word_t;
            RAM2_nWE: out std_logic;
            RAM2_nOE: out std_logic;
            RAM2_nCE: out std_logic;
            
            UART_nRE: out std_logic;
            UART_READY: in std_logic;
            
            UART_nWE: out std_logic;
            UART_TBRE: in std_logic;
            UART_TSRE: in std_logic;

            testen: out std_logic;
            test_0: out reg_addr_t;
            test_1: out word_t
        );
    end component;
    
    signal CLK: std_logic;
    signal nRST: std_logic;
    
    signal testen: std_logic;
    signal test_0: reg_addr_t;
    signal test_1: word_t;
begin
    mips_sopc_inst: mips_sopc
    port map
    (
        CLK => CLK,
        nRST => nRST,
        
        UART_READY => '1',
        
        UART_TBRE => '1',
        UART_TSRE => '1',

        testen => testen,
        test_0 => test_0,
        test_1 => test_1
    );

    process
    begin
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
    end process;
    
    process
    begin
        nRST <= '0';
        wait for 12 ns;
        nRST <= '1';
        wait;
    end process;
end;