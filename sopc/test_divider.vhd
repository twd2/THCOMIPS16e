library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity test_divider is
    port
    (
        dummy1: in std_logic;
        dummy2: out std_logic
    );
end;

architecture behavioral of test_divider is
    component divider is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            -- data signals
            
            DIVIDEND: in word_t;
            DIV: in word_t;
            
            QUOTIENT: out word_t;
            REMAINDER: out word_t;
            
            -- control signals
            SIGN: in std_logic;
            EN: in std_logic;
            CANCEL: in std_logic;
            STALL: in std_logic;
            DONE: out std_logic
        );
    end component;
    
    signal CLK: std_logic;
    signal RST: std_logic;

    signal DIVIDEND: word_t;
    signal DIV: word_t;

    signal QUOTIENT: word_t;
    signal REMAINDER: word_t;

    signal SIGN: std_logic;
    signal EN: std_logic;
    signal CANCEL: std_logic;
    signal STALL: std_logic;
    signal DONE: std_logic;
begin
    divider_inst: divider
    port map
    (
        CLK => CLK,
        RST => RST,

        DIVIDEND => DIVIDEND,
        DIV => DIV,
        
        QUOTIENT => QUOTIENT,
        REMAINDER => REMAINDER,
        
        SIGN => SIGN,
        EN => EN,
        CANCEL => CANCEL,
        STALL => STALL,
        DONE => DONE
    );

    process
    begin
        CLK <= '0';
        RST <= '1';
        EN <= '0';
        SIGN <= '0';
        CANCEL <= '0';
        STALL <= '0';
        wait for 5 ns;
        RST <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"F001";
        DIV <= x"1000";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"1278";
        DIV <= x"0123";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"8678";
        DIV <= x"0123";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '1';
        EN <= '1';
        DIVIDEND <= x"8678";
        DIV <= x"0023";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '1';
        EN <= '1';
        DIVIDEND <= x"1278";
        DIV <= x"FE23";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '1';
        EN <= '1';
        DIVIDEND <= x"1278";
        DIV <= x"0123";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '1';
        EN <= '1';
        DIVIDEND <= x"8278";
        DIV <= x"FE23";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        -- test cancel
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"F001";
        DIV <= x"1000";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        CANCEL <= '1';
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        CANCEL <= '0';
        SIGN <= '1';
        EN <= '1';
        DIVIDEND <= x"8678";
        DIV <= x"FE23";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '1';
        EN <= '1';
        DIVIDEND <= x"8000";
        DIV <= x"FFFF";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"FFFF";
        DIV <= x"0001";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"FFFF";
        DIV <= x"0007";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        SIGN <= '0';
        EN <= '1';
        DIVIDEND <= x"FFFF";
        DIV <= x"0007";
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        STALL <= '1';
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 1 ns;
        STALL <= '0';
        wait for 4 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        CLK <= '1';
        wait for 5 ns;
        CLK <= '0';
        wait for 5 ns;
        
        wait;
    end process;
end;