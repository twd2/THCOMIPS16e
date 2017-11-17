library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity program_counter is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;

        STALL: in stall_t;
        
        FLUSH: in std_logic;
        FLUSH_PC: in word_t;
        
        PC: out word_t;
        PC_4: out word_t;
        
        BRANCH_EN: in std_logic;
        BRANCH_PC: in word_t
    );
end;

architecture behavioral of program_counter is
    signal pc_4_buff, next_pc: word_t;
    signal pc_reg: word_t;
begin
    PC <= pc_reg;
    pc_4_buff <= pc_reg + 4;
    PC_4 <= pc_4_buff;

    process(CLK, RST)
    begin
        if RST = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(CLK) then
            if FLUSH = '1' then
                pc_reg <= FLUSH_PC;
            elsif STALL(stage_if downto stage_pc) = "01" then
                pc_reg <= (others => '0');
            elsif STALL(stage_if downto stage_pc) = "11" then
                -- do nothing
            elsif BRANCH_EN = '1' then
                pc_reg <= BRANCH_PC;
            else
                pc_reg <= pc_4_buff;
            end if;
        end if;
    end process;
end;