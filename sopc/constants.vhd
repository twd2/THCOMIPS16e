library IEEE;
use IEEE.std_logic_1164.all;

package constants is
    constant word_length: integer := 32;
    constant word_msb: integer := word_length - 1;
    constant reg_count: integer := 32;
    constant has_zero_reg: std_logic := '1';
    constant zero_reg_addr: std_logic_vector := "00000";
    constant zero_word: std_logic_vector(word_length - 1 downto 0) := (others => '0');
    
    constant stage_pc: integer := 0;
    constant stage_if: integer := 1;
    constant stage_id: integer := 2;
    constant stage_ex: integer := 3;
    constant stage_mem: integer := 4;
    constant stage_wb: integer := 5;

    constant op_special: std_logic_vector := "000000";
    constant op_regimm: std_logic_vector := "000001";
    constant op_addiu: std_logic_vector := "001001";
    constant op_ori: std_logic_vector := "001101";
    constant op_j: std_logic_vector := "000010";
    constant op_jal: std_logic_vector := "000011";
    constant op_lw: std_logic_vector := "100011";
    constant op_sw: std_logic_vector := "101011";
    constant op_lui: std_logic_vector := "001111";
    constant op_beq: std_logic_vector := "000100";
    constant op_bne: std_logic_vector := "000101";

    constant func_add: std_logic_vector := "100000";
    constant func_addu: std_logic_vector := "100001";
    constant func_div: std_logic_vector := "011010";
    constant func_divu: std_logic_vector := "011011";
    constant func_jalr: std_logic_vector := "001001";
    constant func_mfhi: std_logic_vector := "010000";
    constant func_mflo: std_logic_vector := "010010";
    constant func_mthi: std_logic_vector := "010001";
    constant func_mtlo: std_logic_vector := "010011";
    
    constant cb_bgezal: std_logic_vector := "10001";
    
    constant ins_nop: std_logic_vector := x"00000000";

    type alu_op_t is (alu_nop,
                      alu_addu, alu_subu,
                      alu_or, alu_and, alu_xor, alu_nor,
                      alu_sll, alu_sra, alu_srl);
end;