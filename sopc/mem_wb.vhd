library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity mem_wb is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        STALL: in stall_t;
        FLUSH: in std_logic;

        MEM_PC: in word_t;
        MEM_OP: in op_t;
        MEM_FUNCT: in funct_t;
        MEM_WRITE_EN: in std_logic;
        MEM_WRITE_ADDR: in reg_addr_t;
        MEM_WRITE_DATA: in word_t;
        MEM_HI_WRITE_EN: in std_logic;
        MEM_HI_WRITE_DATA: in word_t;
        MEM_LO_WRITE_EN: in std_logic;
        MEM_LO_WRITE_DATA: in word_t;
        
        WB_PC: out word_t;
        WB_OP: out op_t;
        WB_FUNCT: out funct_t;
        WB_WRITE_EN: out std_logic;
        WB_WRITE_ADDR: out reg_addr_t;
        WB_WRITE_DATA: out word_t;
        WB_HI_WRITE_EN: out std_logic;
        WB_HI_WRITE_DATA: out word_t;
        WB_LO_WRITE_EN: out std_logic;
        WB_LO_WRITE_DATA: out word_t
    );
end;

architecture behavioral of mem_wb is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            WB_PC <= (others => '0');
            WB_OP <= (others => '0');
            WB_FUNCT <= (others => '0');
            WB_WRITE_EN <= '0';
            WB_WRITE_ADDR <= (others => '0');
            WB_WRITE_DATA <= (others => '0');
            WB_HI_WRITE_EN <= '0';
            WB_HI_WRITE_DATA <= (others => '0');
            WB_LO_WRITE_EN <= '0';
            WB_LO_WRITE_DATA <= (others => '0');
        elsif rising_edge(CLK) then
            if FLUSH = '1' or STALL(stage_wb downto stage_mem) = "01" then
                WB_PC <= (others => '0');
                WB_OP <= (others => '0');
                WB_FUNCT <= (others => '0');
                WB_WRITE_EN <= '0';
                WB_WRITE_ADDR <= (others => 'X');
                WB_WRITE_DATA <= (others => 'X');
                WB_HI_WRITE_EN <= '0';
                WB_HI_WRITE_DATA <= (others => 'X');
                WB_LO_WRITE_EN <= '0';
                WB_LO_WRITE_DATA <= (others => 'X');
            elsif STALL(stage_wb downto stage_mem) = "11" then
                -- do nothing
            else
                WB_PC <= MEM_PC;
                WB_OP <= MEM_OP;
                WB_FUNCT <= MEM_FUNCT;
                WB_WRITE_EN <= MEM_WRITE_EN;
                WB_WRITE_ADDR <= MEM_WRITE_ADDR;
                WB_WRITE_DATA <= MEM_WRITE_DATA;
                WB_HI_WRITE_EN <= MEM_HI_WRITE_EN;
                WB_HI_WRITE_DATA <= MEM_HI_WRITE_DATA;
                WB_LO_WRITE_EN <= MEM_LO_WRITE_EN;
                WB_LO_WRITE_DATA <= MEM_LO_WRITE_DATA;
            end if;
        end if;
    end process;
end;