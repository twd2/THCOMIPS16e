library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity hilo is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        HI_WRITE_EN: in std_logic;
        HI_WRITE_DATA: in word_t;
        LO_WRITE_EN: in std_logic;
        LO_WRITE_DATA: in word_t;
        
        HI: out word_t;
        LO: out word_t
    );
end;

architecture behavioral of hilo is
    signal hi_buff, lo_buff: word_t;
begin
    HI <= hi_buff;
    LO <= lo_buff;

    hi_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            hi_buff <= (others => '0');
        elsif rising_edge(CLK) then
            if HI_WRITE_EN = '1' then
                hi_buff <= HI_WRITE_DATA;
            end if;
        end if;
    end process;
    
    lo_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            lo_buff <= (others => '0');
        elsif rising_edge(CLK) then
            if LO_WRITE_EN = '1' then
                lo_buff <= LO_WRITE_DATA;
            end if;
        end if;
    end process;
end;