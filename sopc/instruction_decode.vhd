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
    signal rs, rt, rd: reg_addr_t;
    signal shamt_buff: std_logic_vector(4 downto 0);
    signal op_buff: op_t;
    signal funct_buff: funct_t;
    signal imm, zero_bits, sign_bits: std_logic_vector(15 downto 0);
    signal ins_addr: std_logic_vector(25 downto 0);
    
    signal read_addr_0_buff, read_addr_1_buff: reg_addr_t;
    signal read_en_0_buff, read_en_1_buff: std_logic;
    
    -- for branch instrutions
    signal pc_offset_imm, cb_target: word_t;
    signal reg_0_eq_reg_1, reg_0_eq_0, reg_0_sign: std_logic;
    signal cb_type: std_logic_vector(4 downto 0);
begin
    op_buff <= INS(31 downto 26);
    rs <= INS(25 downto 21);
    rt <= INS(20 downto 16);
    rd <= INS(15 downto 11);
    shamt_buff <= INS(10 downto 6);
    funct_buff <= INS(5 downto 0);
    imm <= INS(15 downto 0);
    zero_bits <= (others => '0');
    sign_bits <= (others => imm(15));
    ins_addr <= INS(25 downto 0);
    
    cb_type <= INS(20 downto 16);
    pc_offset_imm <= (13 downto 0 => imm(15)) & imm & "00";
    cb_target <= PC + pc_offset_imm;
    
    reg_0_eq_reg_1 <= '1' when READ_DATA_0 = READ_DATA_1 else '0';
    reg_0_eq_0 <= '1' when READ_DATA_0 = zero_word else '0';
    reg_0_sign <= READ_DATA_0(word_length - 1);
    
    READ_ADDR_0 <= read_addr_0_buff;
    READ_ADDR_1 <= read_addr_1_buff;
    
    process(RST, op_buff, funct_buff, ins_addr, rs, rt, rd, PC, READ_DATA_0, READ_DATA_1,
            cb_type, cb_target, reg_0_eq_reg_1, reg_0_eq_0, reg_0_sign,
            zero_bits, sign_bits, imm)
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
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => '0');
            IS_LOAD <= '0';
        else
            read_addr_0_buff <= rs;
            read_addr_1_buff <= rt;
            read_en_0_buff <= '1'; -- TODO
            read_en_1_buff <= '1';
            COMMON.pc <= PC;
            COMMON.op <= op_buff;
            COMMON.funct <= funct_buff;
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
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => 'X');
            IS_LOAD <= '0';

            case op_buff is
                when op_special =>
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= READ_DATA_1;
                    WB.write_en <= '1';
                    WB.write_addr <= rd;
                    case funct_buff is
                        when func_addu =>
                            EX.alu_op <= alu_addu;
                        when func_jalr =>
                            EX.alu_op <= alu_addu;
                            EX.operand_0 <= PC;
                            EX.operand_1 <= x"00000004";
                            
                            BRANCH_EN <= '1';
                            BRANCH_PC <= READ_DATA_0;
                        when func_mfhi | func_mflo =>
                            -- nothing
                        when func_mthi | func_mtlo =>
                            WB.write_en <= '0';
                            WB.write_addr <= (others => 'X');
                        when func_div | func_divu =>
                            WB.write_en <= '0';
                            WB.write_addr <= (others => 'X');
                        when others =>
                            WB.write_en <= '0';
                            WB.write_addr <= (others => 'X');
                    end case;
                when op_ori =>
                    EX.alu_op <= alu_or;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= zero_bits & imm;
                    WB.write_en <= '1';
                    WB.write_addr <= rt;
                when op_addiu =>
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= sign_bits & imm;
                    WB.write_en <= '1';
                    WB.write_addr <= rt;
                when op_lui =>
                    EX.alu_op <= alu_or;
                    EX.operand_0 <= imm & zero_bits;
                    EX.operand_1 <= zero_word;
                    WB.write_en <= '1';
                    WB.write_addr <= rt;
                when op_lw =>
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= sign_bits & imm;
                    MEM.mem_en <= '1';
                    MEM.mem_write_en <= '0';
                    WB.write_en <= '1';
                    WB.write_addr <= rt;
                    IS_LOAD <= '1';
                when op_sw =>
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= sign_bits & imm;
                    MEM.mem_en <= '1';
                    MEM.mem_write_en <= '1';
                    MEM.write_mem_data <= READ_DATA_1;
                when op_beq =>
                    BRANCH_EN <= reg_0_eq_reg_1;
                    BRANCH_PC <= cb_target;
                when op_bne =>
                    BRANCH_EN <= not reg_0_eq_reg_1;
                    BRANCH_PC <= cb_target;
                when op_j => -- type J
                    BRANCH_EN <= '1';
                    BRANCH_PC <= PC(31 downto 28) & ins_addr & "00";
                when op_jal => -- type J
                    -- retaddr = PC + 4
                    -- PC points to next ins, +4 is caused by branch delay slot
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= PC;
                    EX.operand_1 <= x"00000004";
                    WB.write_en <= '1';
                    WB.write_addr <= "11111"; -- 31
                    
                    BRANCH_EN <= '1';
                    BRANCH_PC <= PC(31 downto 28) & ins_addr & "00";
                when op_regimm =>
                    case cb_type is
                        when cb_bgezal =>
                            EX.alu_op <= alu_addu;
                            EX.operand_0 <= PC;
                            EX.operand_1 <= x"00000004";
                            WB.write_en <= '1';
                            WB.write_addr <= "11111"; -- 31
                            
                            BRANCH_EN <= not reg_0_sign;
                            BRANCH_PC <= cb_target;
                        when others =>
                    end case;
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