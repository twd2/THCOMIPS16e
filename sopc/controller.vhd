library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity controller is
    port
    (
        RST: in std_logic;

        IF_STALL_REQ: in std_logic;
        ID_STALL_REQ: in std_logic;
        EX_STALL_REQ: in std_logic;
        MEM_STALL_REQ: in std_logic;
        
        STALL: out stall_t
    );
end;

architecture behavioral of controller is
    signal if_stall: stall_t;
    signal id_stall: stall_t;
    signal ex_stall: stall_t;
    signal mem_stall: stall_t;
begin
    if_stall <= (stage_if downto 0 => '1', others => '0') when IF_STALL_REQ = '1' else (others => '0');
    id_stall <= (stage_id downto 0 => '1', others => '0') when ID_STALL_REQ = '1' else (others => '0');
    ex_stall <= (stage_ex downto 0 => '1', others => '0') when EX_STALL_REQ = '1' else (others => '0');
    mem_stall <= (stage_mem downto 0 => '1', others => '0') when MEM_STALL_REQ = '1' else (others => '0');
    
    process(RST, if_stall, id_stall, ex_stall, mem_stall)
    begin
        if RST = '1' then
            STALL <= (others => '0');
        else
            STALL <= if_stall or id_stall or ex_stall or mem_stall;
        end if;
    end process;
end;