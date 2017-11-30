library IEEE;
use IEEE.std_logic_1164.all;

package constants is
    constant word_length: integer := 16;
    constant word_msb: integer := word_length - 1;
    constant reg_count: integer := 8;
    constant has_zero_reg: std_logic := '0';
    constant zero_reg_addr: std_logic_vector := "000";
    constant zero_word: std_logic_vector(word_length - 1 downto 0) := (others => '0');
    
    constant stage_pc: integer := 0;
    constant stage_if: integer := 1;
    constant stage_id: integer := 2;
    constant stage_ex: integer := 3;
    constant stage_mem: integer := 4;
    constant stage_wb: integer := 5;
    
    constant ins_nop: std_logic_vector := x"0800";

    type alu_op_t is (alu_nop, alu_cmp,
                      alu_addu, alu_subu,
                      alu_or, alu_and, alu_xor, alu_nor,
                      alu_sll, alu_sra, alu_srl);

    constant cp0_reg_count: integer := 8;
    
    constant cp0_addr_status: integer := 0;
    constant cp0_addr_cause: integer := 1;
    constant cp0_addr_epc: integer := 2;
    constant cp0_addr_ecs: integer := 3;
    constant cp0_addr_tmp0: integer := 4;
    constant cp0_addr_tmp1: integer := 5;
    constant cp0_addr_tmp2: integer := 6;
    
    constant cp0_bit_interrupt_enable: integer := 0;
    constant cp0_bit_in_except_handler: integer := 1;
end;