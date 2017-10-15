library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.constants.all;

entity alu is
    port
    (
        -- input
        OP: in alu_op_t;
        OPERAND_0: in word_t;
        OPERAND_1: in word_t;

        -- output
        RESULT: out word_t;

        -- flags
        OVERFLOW: out std_logic;
        ZERO: out std_logic;
        SIGN: out std_logic;
        CARRY: out std_logic
    );
end;

architecture behavioral of alu is
    signal shamt: integer range 0 to 15;
    signal all_zero: word_t;
	 signal result_buff: std_logic_vector(16 downto 0);
begin
    all_zero <= (others => '0');
    shamt <= to_integer(unsigned(OPERAND_1(3 downto 0)));

    process(OP, OPERAND_0, OPERAND_1, shamt)
    begin
		  result_buff <= (others => '0');
        case OP is
            when alu_add =>
                result_buff <= ("0" & OPERAND_0) + ("0" & OPERAND_1);
            when alu_sub =>
                result_buff <= ("0" & OPERAND_0) + ("0" & (not OPERAND_1 + 1));
            when alu_and =>
                result_buff(15 downto 0) <= OPERAND_0 and OPERAND_1;
            when alu_or =>
                result_buff(15 downto 0) <= OPERAND_0 or OPERAND_1;
            when alu_xor =>
                result_buff(15 downto 0) <= OPERAND_0 xor OPERAND_1;
            when alu_not =>
                result_buff(15 downto 0) <= not OPERAND_0;
            when alu_sll =>
                result_buff(15 downto 0) <= to_stdlogicvector(to_bitvector(OPERAND_0) sll shamt);
            when alu_srl =>
                result_buff(15 downto 0) <= to_stdlogicvector(to_bitvector(OPERAND_0) srl shamt);
            when alu_sra =>
                result_buff(15 downto 0) <= to_stdlogicvector(to_bitvector(OPERAND_0) sra shamt);
            when alu_rol =>
                result_buff(15 downto 0) <= to_stdlogicvector(to_bitvector(OPERAND_0) rol shamt);
            when others =>
                result_buff(15 downto 0) <= (others => 'X');
        end case;
    end process;
	 
	 RESULT <= result_buff(15 downto 0);
    
    -- flags
	 CARRY <= result_buff(16);
    OVERFLOW <= '1' when result_buff(16) /= result_buff(15) else '0';
    ZERO <= '1' when result_buff(15 downto 0) = all_zero else '0';
    SIGN <= result_buff(15);
end;