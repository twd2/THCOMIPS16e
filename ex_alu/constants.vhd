library IEEE;
use IEEE.std_logic_1164.all;

package constants is
    subtype word_t is std_logic_vector(15 downto 0);
    constant word_msb: integer := 15;
    constant zero_word: word_t := (others => '0');

    subtype alu_op_t is std_logic_vector(3 downto 0);
    constant alu_add: alu_op_t := "0000";
    constant alu_sub: alu_op_t := "0001";
    constant alu_and: alu_op_t := "0100";
    constant alu_or: alu_op_t  := "0101";
    constant alu_xor: alu_op_t := "0110";
    constant alu_not: alu_op_t := "0111";
    constant alu_sll: alu_op_t := "1000";
    constant alu_srl: alu_op_t := "1001";
    constant alu_sra: alu_op_t := "1010";
    constant alu_rol: alu_op_t := "1011";
end;