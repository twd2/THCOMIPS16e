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
    signal result_buff: word_t;
	 
    signal adder_operand_0, adder_operand_1: word_t;
    signal adder_carry_in: std_logic;
    signal adder_buff: std_logic_vector(16 downto 0);
begin
    all_zero <= (others => '0');
    shamt <= to_integer(unsigned(OPERAND_1(3 downto 0)));
	 
    -- adder
    adder_buff <= ("0" & adder_operand_0) + ("0" & adder_operand_1) + adder_carry_in;
    process(OP, OPERAND_0, OPERAND_1)
    begin
        adder_operand_0 <= OPERAND_0;
        case OP is
            when alu_add =>
                adder_operand_1 <= OPERAND_1;
                adder_carry_in <= '0';
            when alu_sub =>
                adder_operand_1 <= not OPERAND_1;
                adder_carry_in <= '1';
            when others =>
                adder_operand_1 <= (others => '-');
                adder_carry_in <= '-';
        end case;
    end process;
    
    process(OP, adder_buff)
    begin
        if OP = alu_add or OP = alu_sub then
            CARRY <= adder_buff(16);
            if adder_buff(16) /= adder_buff(15) then
                OVERFLOW <= '1';
            else
                OVERFLOW <= '0';
            end if;
        else
            CARRY <= '0';
            OVERFLOW <= '0';
        end if;
    end process;

    process(OP, OPERAND_0, OPERAND_1, shamt, adder_buff)
    begin
        result_buff <= (others => '0');
        case OP is
            when alu_add | alu_sub =>
                result_buff <= adder_buff(15 downto 0);
            when alu_and =>
                result_buff <= OPERAND_0 and OPERAND_1;
            when alu_or =>
                result_buff <= OPERAND_0 or OPERAND_1;
            when alu_xor =>
                result_buff <= OPERAND_0 xor OPERAND_1;
            when alu_not =>
                result_buff <= not OPERAND_0;
            when alu_sll =>
                result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) sll shamt);
            when alu_srl =>
                result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) srl shamt);
            when alu_sra =>
                result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) sra shamt);
            when alu_rol =>
                result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) rol shamt);
            when others =>
                result_buff <= (others => 'X');
        end case;
    end process;
	 
    RESULT <= result_buff;
    
    -- flags
    ZERO <= '1' when result_buff = all_zero else '0';
    SIGN <= result_buff(15);
end;