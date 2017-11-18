library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity special_reg_forward is
    port
    (
        RST: in std_logic;
        
        -- read from sreg
        SREG_T: in std_logic;
        SREG_SP: in word_t;

        -- ex
        EX_T_WRITE_EN: in std_logic;
        EX_T_WRITE_DATA: in std_logic;
        EX_SP_WRITE_EN: in std_logic;
        EX_SP_WRITE_DATA: in word_t;

        -- mem
        MEM_T_WRITE_EN: in std_logic;
        MEM_T_WRITE_DATA: in std_logic;
        MEM_SP_WRITE_EN: in std_logic;
        MEM_SP_WRITE_DATA: in word_t;
        
        -- wb
        WB_T_WRITE_EN: in std_logic;
        WB_T_WRITE_DATA: in std_logic;
        WB_SP_WRITE_EN: in std_logic;
        WB_SP_WRITE_DATA: in word_t;
        
        -- sreg content for id
        ID_T: out std_logic;
        ID_SP: out word_t
    );
end;

architecture behavioral of special_reg_forward is
begin
    t_proc:
    process(EX_T_WRITE_EN, EX_T_WRITE_DATA, MEM_T_WRITE_EN, MEM_T_WRITE_DATA,
            WB_T_WRITE_EN, WB_T_WRITE_DATA, SREG_T)
    begin
        if EX_T_WRITE_EN = '1' then
            ID_T <= EX_T_WRITE_DATA;
        elsif MEM_T_WRITE_EN = '1' then
            ID_T <= MEM_T_WRITE_DATA;
        elsif WB_T_WRITE_EN = '1' then
            ID_T <= WB_T_WRITE_DATA;
        else
            ID_T <= SREG_T;
        end if;
    end process;

    sp_proc:
    process(EX_SP_WRITE_EN, EX_SP_WRITE_DATA, MEM_SP_WRITE_EN, MEM_SP_WRITE_DATA,
            WB_SP_WRITE_EN, WB_SP_WRITE_DATA, SREG_SP)
    begin
        if EX_SP_WRITE_EN = '1' then
            ID_SP <= EX_SP_WRITE_DATA;
        elsif MEM_SP_WRITE_EN = '1' then
            ID_SP <= MEM_SP_WRITE_DATA;
        elsif WB_SP_WRITE_EN = '1' then
            ID_SP <= WB_SP_WRITE_DATA;
        else
            ID_SP <= SREG_SP;
        end if;
    end process;
end;