library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity alu is
    port
    (
        RST: in std_logic;

        OP: in alu_op_t;
        OPERAND_0: in word_t;
        OPERAND_1: in word_t;

        RESULT: out word_t;

        -- flags
        OVERFLOW: out std_logic;
        ZERO: out std_logic;
        SIGN: out std_logic;
        CARRY: out std_logic
    );
end;

architecture behavioral of alu is
    signal shamt: integer range 0 to word_msb;
    signal result_buff: word_t;
	 
    signal adder_operand_0, adder_operand_1: word_t;
    signal adder_carry_in: std_logic;
    signal adder_buff: std_logic_vector(word_msb + 1 downto 0);
begin
    shamt <= to_integer(unsigned(OPERAND_1(3 downto 0)));

    -- adder
    adder_buff <= ("0" & adder_operand_0) + ("0" & adder_operand_1) + adder_carry_in;
    process(OP, OPERAND_0, OPERAND_1)
    begin
        adder_operand_0 <= OPERAND_0;
        if OP = alu_addu then
            adder_operand_1 <= OPERAND_1;
            adder_carry_in <= '0';
        else -- sub
            adder_operand_1 <= not OPERAND_1;
            adder_carry_in <= '1';
        end if;
    end process;

    process(OP, OPERAND_0, OPERAND_1, adder_buff)
    begin
        if OP = alu_addu then
            CARRY <= adder_buff(word_msb + 1);
            if (OPERAND_0(word_msb) = '0' and OPERAND_1(word_msb) = '0' and adder_buff(word_msb) = '1')
               or (OPERAND_0(word_msb) = '1' and OPERAND_1(word_msb) = '1' and adder_buff(word_msb) = '0') then
                OVERFLOW <= '1';
            else
                OVERFLOW <= '0';
            end if;
        elsif OP = alu_subu then
            CARRY <= not adder_buff(word_msb + 1);
            if (OPERAND_0(word_msb) = '0' and OPERAND_1(word_msb) = '1' and adder_buff(word_msb) = '1')
               or (OPERAND_0(word_msb) = '1' and OPERAND_1(word_msb) = '0' and adder_buff(word_msb) = '0') then
                OVERFLOW <= '1';
            else
                OVERFLOW <= '0';
            end if;
        else
            CARRY <= '0';
            OVERFLOW <= '0';
        end if;
    end process;

    process(RST, OP, OPERAND_0, OPERAND_1, shamt, adder_buff)
    begin
        if RST = '1' then
            result_buff <= (others => '0');
        else
            case OP is
                when alu_addu | alu_subu =>
                    result_buff <= adder_buff(word_msb downto 0);
                when alu_or =>
                    result_buff <= OPERAND_0 or OPERAND_1;
                when alu_and =>
                    result_buff <= OPERAND_0 and OPERAND_1;
                when alu_xor =>
                    result_buff <= OPERAND_0 xor OPERAND_1;
                when alu_nor =>
                    result_buff <= OPERAND_0 nor OPERAND_1;
                when alu_sll =>
                    result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) sll shamt);
                when alu_srl =>
                    result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) srl shamt);
                when alu_sra =>
                    result_buff <= to_stdlogicvector(to_bitvector(OPERAND_0) sra shamt);
                when others =>
                    result_buff <= (others => 'X');
            end case;
        end if;
    end process;
    
    RESULT <= result_buff;
    
    -- flags
    ZERO <= '1' when result_buff = zero_word else '0';
    SIGN <= result_buff(word_msb);
end;