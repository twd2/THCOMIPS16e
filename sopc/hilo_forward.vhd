library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity hilo_forward is
    port
    (
        RST: in std_logic;
        
        -- read from HILO
        HILO_HI: in word_t;
        HILO_LO: in word_t;

        -- mem
        MEM_HI_WRITE_EN: in std_logic;
        MEM_HI_WRITE_DATA: in word_t;
        MEM_LO_WRITE_EN: in std_logic;
        MEM_LO_WRITE_DATA: in word_t;
        
        -- wb
        WB_HI_WRITE_EN: in std_logic;
        WB_HI_WRITE_DATA: in word_t;
        WB_LO_WRITE_EN: in std_logic;
        WB_LO_WRITE_DATA: in word_t;
        
        -- HILO content for ex
        EX_HI: out word_t;
        EX_LO: out word_t
    );
end;

architecture behavioral of hilo_forward is
begin
    hi_proc:
    process(MEM_HI_WRITE_EN, MEM_HI_WRITE_DATA, WB_HI_WRITE_EN, WB_HI_WRITE_DATA, HILO_HI)
    begin
        if MEM_HI_WRITE_EN = '1' then
            EX_HI <= MEM_HI_WRITE_DATA;
        elsif WB_HI_WRITE_EN = '1' then
            EX_HI <= WB_HI_WRITE_DATA;
        else
            EX_HI <= HILO_HI;
        end if;
    end process;

    lo_proc:
    process(MEM_LO_WRITE_EN, MEM_LO_WRITE_DATA, WB_LO_WRITE_EN, WB_LO_WRITE_DATA, HILO_LO)
    begin
        if MEM_LO_WRITE_EN = '1' then
            EX_LO <= MEM_LO_WRITE_DATA;
        elsif WB_LO_WRITE_EN = '1' then
            EX_LO <= WB_LO_WRITE_DATA;
        else
            EX_LO <= HILO_LO;
        end if;
    end process;
end;