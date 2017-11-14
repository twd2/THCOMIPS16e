library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity id_ex is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;

        STALL: in stall_t;
        FLUSH: in std_logic;
        
        ID_PC: in word_t;
        ID_OP: in op_t;
        ID_FUNCT: in funct_t;
        ID_ALU_OP: in alu_op_t;
        ID_OPERAND_0: in word_t;
        ID_OPERAND_1: in word_t;
        ID_WRITE_EN: in std_logic;
        ID_WRITE_ADDR: in reg_addr_t;
        ID_WRITE_MEM_DATA: in word_t;
        ID_IS_LOAD: in std_logic;

        EX_PC: out word_t;
        EX_OP: out op_t;
        EX_FUNCT: out funct_t;
        EX_ALU_OP: out alu_op_t;
        EX_OPERAND_0: out word_t;
        EX_OPERAND_1: out word_t;
        EX_WRITE_EN: out std_logic;
        EX_WRITE_ADDR: out reg_addr_t;
        EX_WRITE_MEM_DATA: out word_t;
        EX_IS_LOAD: out std_logic
    );
end;

architecture behavioral of id_ex is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            EX_PC <= (others => '0');
            EX_OP <= (others => '0');
            EX_FUNCT <= (others => '0');
            EX_ALU_OP <= alu_nop;
            EX_OPERAND_0 <= (others => '0');
            EX_OPERAND_1 <= (others => '0');
            EX_WRITE_EN <= '0';
            EX_WRITE_ADDR <= (others => '0');
            EX_WRITE_MEM_DATA <= (others => '0');
            EX_IS_LOAD <= '0';
        elsif rising_edge(CLK) then
            if FLUSH = '1' or STALL(stage_ex downto stage_id) = "01" then
                EX_PC <= (others => '0');
                EX_OP <= (others => '0');
                EX_FUNCT <= (others => '0');
                EX_ALU_OP <= alu_nop;
                EX_OPERAND_0 <= (others => 'X');
                EX_OPERAND_1 <= (others => 'X');
                EX_WRITE_EN <= '0';
                EX_WRITE_ADDR <= (others => 'X');
                EX_WRITE_MEM_DATA <= (others => 'X');
                EX_IS_LOAD <= '0';
            elsif STALL(stage_ex downto stage_id) = "11" then
                -- do nothing
            else    
                EX_PC <= ID_PC;
                EX_OP <= ID_OP;
                EX_FUNCT <= ID_FUNCT;
                EX_ALU_OP <= ID_ALU_OP;
                EX_OPERAND_0 <= ID_OPERAND_0;
                EX_OPERAND_1 <= ID_OPERAND_1;
                EX_WRITE_EN <= ID_WRITE_EN;
                EX_WRITE_ADDR <= ID_WRITE_ADDR;
                EX_WRITE_MEM_DATA <= ID_WRITE_MEM_DATA;
                EX_IS_LOAD <= ID_IS_LOAD;
            end if;
        end if;
    end process;
end;