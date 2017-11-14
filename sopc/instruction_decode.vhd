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
        
        PC_O: out word_t;
        OP: out op_t;
        FUNCT: out funct_t;
        ALU_OP: out alu_op_t;
        OPERAND_0: out word_t;
        OPERAND_1: out word_t;
        WRITE_EN: out std_logic;
        WRITE_ADDR: out reg_addr_t;
        WRITE_MEM_DATA: out word_t;
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
            PC_O <= (others => '0');
            OP <= (others => '0');
            FUNCT <= (others => '0');
            ALU_OP <= alu_nop;
            OPERAND_0 <= (others => '0');
            OPERAND_1 <= (others => '0');
            WRITE_EN <= '0';
            WRITE_ADDR <= (others => '0');
            WRITE_MEM_DATA <= (others => '0');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => '0');
            IS_LOAD <= '0';
        else
            read_addr_0_buff <= rs;
            read_addr_1_buff <= rt;
            PC_O <= PC;
            OP <= op_buff;
            FUNCT <= funct_buff;
            ALU_OP <= alu_nop;
            OPERAND_0 <= (others => 'X');
            OPERAND_1 <= (others => 'X');
            WRITE_EN <= '0';
            WRITE_ADDR <= (others => 'X');
            WRITE_MEM_DATA <= (others => 'X');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => 'X');
            IS_LOAD <= '0';

            case op_buff is
                when op_special =>
                    OPERAND_0 <= READ_DATA_0;
                    OPERAND_1 <= READ_DATA_1;
                    WRITE_EN <= '1';
                    WRITE_ADDR <= rd;
                    case funct_buff is
                        when func_addu =>
                            ALU_OP <= alu_addu;
                        when func_jalr =>
                            ALU_OP <= alu_addu;
                            OPERAND_0 <= PC;
                            OPERAND_1 <= x"00000004";
                            
                            BRANCH_EN <= '1';
                            BRANCH_PC <= READ_DATA_0;
                        when func_mfhi | func_mflo =>
                            -- nothing
                        when func_mthi | func_mtlo =>
                            WRITE_EN <= '0';
                            WRITE_ADDR <= (others => 'X');
                        when func_div | func_divu =>
                            WRITE_EN <= '0';
                            WRITE_ADDR <= (others => 'X');
                        when others =>
                            WRITE_EN <= '0';
                            WRITE_ADDR <= (others => 'X');
                    end case;
                when op_ori =>
                    ALU_OP <= alu_or;
                    OPERAND_0 <= READ_DATA_0;
                    OPERAND_1 <= zero_bits & imm;
                    WRITE_EN <= '1';
                    WRITE_ADDR <= rt;
                when op_addiu =>
                    ALU_OP <= alu_addu;
                    OPERAND_0 <= READ_DATA_0;
                    OPERAND_1 <= sign_bits & imm;
                    WRITE_EN <= '1';
                    WRITE_ADDR <= rt;
                when op_lui =>
                    ALU_OP <= alu_or;
                    OPERAND_0 <= imm & zero_bits;
                    OPERAND_1 <= zero_word;
                    WRITE_EN <= '1';
                    WRITE_ADDR <= rt;
                when op_lw =>
                    ALU_OP <= alu_addu;
                    OPERAND_0 <= READ_DATA_0;
                    OPERAND_1 <= sign_bits & imm;
                    WRITE_EN <= '1';
                    WRITE_ADDR <= rt;
                    IS_LOAD <= '1';
                when op_sw =>
                    ALU_OP <= alu_addu;
                    OPERAND_0 <= READ_DATA_0;
                    OPERAND_1 <= sign_bits & imm;
                    WRITE_MEM_DATA <= READ_DATA_1;
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
                    ALU_OP <= alu_addu;
                    OPERAND_0 <= PC;
                    OPERAND_1 <= x"00000004";
                    WRITE_EN <= '1';
                    WRITE_ADDR <= "11111"; -- 31
                    
                    BRANCH_EN <= '1';
                    BRANCH_PC <= PC(31 downto 28) & ins_addr & "00";
                when op_regimm =>
                    case cb_type is
                        when cb_bgezal =>
                            ALU_OP <= alu_addu;
                            OPERAND_0 <= PC;
                            OPERAND_1 <= x"00000004";
                            WRITE_EN <= '1';
                            WRITE_ADDR <= "11111"; -- 31
                            
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
                          (EX_WRITE_ADDR = read_addr_0_buff or EX_WRITE_ADDR = read_addr_1_buff) else '0';
                          -- check zero reg here?
end;