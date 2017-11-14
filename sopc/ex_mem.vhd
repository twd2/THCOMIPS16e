library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity ex_mem is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        STALL: in stall_t;
        FLUSH: in std_logic;

        EX_PC: in word_t;
        EX_OP: in op_t;
        EX_FUNCT: in funct_t;
        EX_ALU_RESULT: in word_t;
        EX_WRITE_EN: in std_logic;
        EX_WRITE_ADDR: in reg_addr_t;
        EX_WRITE_DATA: in word_t;
        EX_WRITE_MEM_DATA: in word_t;
        EX_HI_WRITE_EN: in std_logic;
        EX_HI_WRITE_DATA: in word_t;
        EX_LO_WRITE_EN: in std_logic;
        EX_LO_WRITE_DATA: in word_t;
        
        MEM_PC: out word_t;
        MEM_OP: out op_t;
        MEM_FUNCT: out funct_t;
        MEM_ALU_RESULT: out word_t;
        MEM_WRITE_EN: out std_logic;
        MEM_WRITE_ADDR: out reg_addr_t;
        MEM_WRITE_DATA: out word_t;
        MEM_WRITE_MEM_DATA: out word_t;
        MEM_HI_WRITE_EN: out std_logic;
        MEM_HI_WRITE_DATA: out word_t;
        MEM_LO_WRITE_EN: out std_logic;
        MEM_LO_WRITE_DATA: out word_t
    );
end;

architecture behavioral of ex_mem is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            MEM_PC <= (others => '0');
            MEM_OP <= (others => '0');
            MEM_FUNCT <= (others => '0');
            MEM_ALU_RESULT <= (others => '0');
            MEM_WRITE_EN <= '0';
            MEM_WRITE_ADDR <= (others => '0');
            MEM_WRITE_DATA <= (others => '0');
            MEM_WRITE_MEM_DATA <= (others => '0');
            MEM_HI_WRITE_EN <= '0';
            MEM_HI_WRITE_DATA <= (others => '0');
            MEM_LO_WRITE_EN <= '0';
            MEM_LO_WRITE_DATA <= (others => '0');
        elsif rising_edge(CLK) then
            if FLUSH = '1' or STALL(stage_mem downto stage_ex) = "01" then
                MEM_PC <= (others => '0');
                MEM_OP <= (others => '0');
                MEM_FUNCT <= (others => '0');
                MEM_ALU_RESULT <= (others => 'X');
                MEM_WRITE_EN <= '0';
                MEM_WRITE_ADDR <= (others => 'X');
                MEM_WRITE_DATA <= (others => 'X');
                MEM_WRITE_MEM_DATA <= (others => 'X');
                MEM_HI_WRITE_EN <= '0';
                MEM_HI_WRITE_DATA <= (others => 'X');
                MEM_LO_WRITE_EN <= '0';
                MEM_LO_WRITE_DATA <= (others => 'X');
            elsif STALL(stage_mem downto stage_ex) = "11" then
                -- do nothing
            else
                MEM_PC <= EX_PC;
                MEM_OP <= EX_OP;
                MEM_FUNCT <= EX_FUNCT;
                MEM_ALU_RESULT <= EX_ALU_RESULT;
                MEM_WRITE_EN <= EX_WRITE_EN;
                MEM_WRITE_ADDR <= EX_WRITE_ADDR;
                MEM_WRITE_DATA <= EX_WRITE_DATA;
                MEM_WRITE_MEM_DATA <= EX_WRITE_MEM_DATA;
                MEM_HI_WRITE_EN <= EX_HI_WRITE_EN;
                MEM_HI_WRITE_DATA <= EX_HI_WRITE_DATA;
                MEM_LO_WRITE_EN <= EX_LO_WRITE_EN;
                MEM_LO_WRITE_DATA <= EX_LO_WRITE_DATA;
            end if;
        end if;
    end process;
end;