library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity instruction_decode is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        INS: in word_t;
        
        -- reg file
        READ_ADDR_0: out reg_addr_t;
        READ_DATA_0: in word_t;
        
        READ_ADDR_1: out reg_addr_t;
        READ_DATA_1: in word_t;
        
        T: in std_logic;
        SP: in word_t;
        
        COMMON: out common_signal_t;
        EX: out ex_signal_t;
        MEM: out mem_signal_t;
        WB: out wb_signal_t;

        IS_LOAD: out std_logic;
        
        EX_IS_LOAD: in std_logic;
        EX_WRITE_ADDR: in reg_addr_t;
        
        BRANCH_EN: out std_logic;
        BRANCH_PC: out word_t
    );
end;

architecture behavioral of instruction_decode is
    signal rx, ry, rz: reg_addr_t;
    signal shamt_buff: word_t;
    signal op_buff: op_t;
    signal imm4se, imm5se, imm8se, imm8ze, imm11se: word_t;
    
    signal read_addr_0_buff, read_addr_1_buff: reg_addr_t;
    signal read_en_0_buff, read_en_1_buff: std_logic;
    
    -- for branch instrutions
    signal reg_0_eq_0: std_logic;
    signal b_pc, cb_pc: word_t;
begin
    op_buff <= INS(15 downto 11);
    rx <= INS(10 downto 8);
    ry <= INS(7 downto 5);
    rz <= INS(4 downto 2);
    
    process(INS)
    begin
        if INS(4 downto 2) = "000" then
            shamt_buff <= (11 downto 0 => '0') & x"8";
        else
            shamt_buff <= (11 downto 0 => '0') & "0" & INS(4 downto 2);
        end if;
    end process;
    
    imm4se <= (11 downto 0 => INS(3)) & INS(3 downto 0);
    imm5se <= (10 downto 0 => INS(4)) & INS(4 downto 0);
    imm8se <= (7 downto 0 => INS(7)) & INS(7 downto 0);
    imm8ze <= (7 downto 0 => '0') & INS(7 downto 0);
    imm11se <= (4 downto 0 => INS(10)) & INS(10 downto 0);

    reg_0_eq_0 <= '1' when READ_DATA_0 = zero_word else '0';
    
    b_pc <= PC + imm11se;
    cb_pc <= PC + imm8se;
    
    READ_ADDR_0 <= read_addr_0_buff;
    READ_ADDR_1 <= read_addr_1_buff;
    
    process(RST, INS, op_buff, rx, ry, rz, PC, READ_DATA_0, READ_DATA_1, T, SP,
            reg_0_eq_0,
            imm4se, imm5se, imm8se, imm8ze, imm11se)
    begin
        if RST = '1' then
            read_addr_0_buff <= (others => '0');
            read_addr_1_buff <= (others => '0');
            read_en_0_buff <= '0';
            read_en_1_buff <= '0';
            COMMON.pc <= (others => '0');
            COMMON.op <= (others => '0');
            COMMON.funct <= (others => '0');
            EX.alu_op <= alu_nop;
            EX.operand_0 <= (others => '0');
            EX.operand_1 <= (others => '0');
            MEM.alu_result <= (others => '0');
            MEM.mem_en <= '0';
            MEM.mem_write_en <= '0';
            MEM.write_mem_data <= (others => '0');
            WB.write_en <= '0';
            WB.write_addr <= (others => '0');
            WB.write_data <= (others => '0');
            WB.hi_write_en <= '0';
            WB.hi_write_data <= (others => '0');
            WB.lo_write_en <= '0';
            WB.lo_write_data <= (others => '0');
            WB.t_write_en <= '0';
            WB.t_write_data <= '0';
            WB.sp_write_en <= '0';
            WB.sp_write_data <= (others => '0');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => '0');
            IS_LOAD <= '0';
        else
            read_addr_0_buff <= rx;
            read_addr_1_buff <= ry;
            read_en_0_buff <= '1'; -- TODO, for performance
            read_en_1_buff <= '1';
            COMMON.pc <= PC;
            COMMON.op <= op_buff;
            COMMON.funct <= (others => 'X'); -- TODO
            EX.alu_op <= alu_nop;
            EX.operand_0 <= (others => 'X');
            EX.operand_1 <= (others => 'X');
            MEM.alu_result <= (others => 'X');
            MEM.mem_en <= '0';
            MEM.mem_write_en <= 'X';
            MEM.write_mem_data <= (others => 'X');
            WB.write_en <= '0';
            WB.write_addr <= (others => 'X');
            WB.write_data <= (others => 'X');
            WB.hi_write_en <= 'X';
            WB.hi_write_data <= (others => 'X');
            WB.lo_write_en <= 'X';
            WB.lo_write_data <= (others => 'X');
            WB.t_write_en <= '0';
            WB.t_write_data <= 'X';
            WB.sp_write_en <= '0';
            WB.sp_write_data <= (others => 'X');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => 'X');
            IS_LOAD <= '0';

            -- TODO
            case op_buff is
                when "00010" => -- b
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    BRANCH_EN <= '1';
                    BRANCH_PC <= b_pc;
                when "00101" => -- bnez
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    BRANCH_EN <= not reg_0_eq_0;
                    BRANCH_PC <= cb_pc;
                when "01100" => -- bteqz
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    BRANCH_EN <= not T;
                    BRANCH_PC <= cb_pc;
                when "01001" => -- addiu
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm8se;
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                when "01000" => -- addiu3
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm4se;
                    WB.write_en <= '1';
                    WB.write_addr <= ry;
                when "01101" => -- li
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_or;
                    EX.operand_0 <= zero_word;
                    EX.operand_1 <= imm8ze;
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                when "01111" => -- move
                    read_en_0_buff <= '0';
                    EX.alu_op <= alu_or;
                    EX.operand_0 <= READ_DATA_1;
                    EX.operand_1 <= zero_word;
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                when "00110" =>
                    case INS(1 downto 0) is
                        when "00" => -- sll
                            read_en_0_buff <= '0';
                            EX.alu_op <= alu_sll;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= shamt_buff;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when others =>
                    end case;
                when "11101" =>
                    case INS(4 downto 0) is
                        when "00100" => -- sllv
                            EX.alu_op <= alu_sll;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= READ_DATA_0;
                            WB.write_en <= '1';
                            WB.write_addr <= ry;
                        when "01101" => -- or
                            EX.alu_op <= alu_or;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when "01010" => -- cmp
                            EX.alu_op <= alu_cmp;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.t_write_en <= '1';
                        when others =>
                    end case;
                when "00001" => -- nop
                when others =>
            end case;
        end if;
    end process;

    -- load hazard
    STALL_REQ <= '1' when EX_IS_LOAD = '1' and 
                          ((read_en_0_buff = '1' and EX_WRITE_ADDR = read_addr_0_buff) or
                           (read_en_1_buff = '1' and EX_WRITE_ADDR = read_addr_1_buff)) else '0';
                          -- TODO: check zero reg here?
end;