library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity timer is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        IRQ: out std_logic
    );
end;

architecture behavioral of timer is
    constant TIMEOUT_TICKS: integer := 20;--36000;
    signal counter: integer range 0 to TIMEOUT_TICKS - 1;
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            counter <= 0;
        elsif rising_edge(CLK) then
            if counter = TIMEOUT_TICKS - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    IRQ <= '1' when counter = TIMEOUT_TICKS - 1 else '0';
end;