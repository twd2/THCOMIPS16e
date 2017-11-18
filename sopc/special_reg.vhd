library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity special_reg is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        T_WRITE_EN: in std_logic;
        T_WRITE_DATA: in std_logic;
        SP_WRITE_EN: in std_logic;
        SP_WRITE_DATA: in word_t;
        
        T: out std_logic;
        SP: out word_t
    );
end;

architecture behavioral of special_reg is
    signal t_buff: std_logic;
    signal sp_buff: word_t;
begin
    T <= t_buff;
    SP <= sp_buff;

    t_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            t_buff <= '0';
        elsif rising_edge(CLK) then
            if T_WRITE_EN = '1' then
                t_buff <= T_WRITE_DATA;
            end if;
        end if;
    end process;
    
    sp_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            sp_buff <= (others => '0');
        elsif rising_edge(CLK) then
            if SP_WRITE_EN = '1' then
                sp_buff <= SP_WRITE_DATA;
            end if;
        end if;
    end process;
end;