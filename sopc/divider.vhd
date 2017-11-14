library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
-- use IEEE.std_logic_arith.conv_std_logic_vector;
-- use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity divider is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;

        -- data signals
        DIVIDEND: in word_t;
        DIV: in word_t;
        
        QUOTIENT: out word_t;
        REMAINDER: out word_t;
        
        -- control signals
        SIGN: in std_logic;
        EN: in std_logic;
        CANCEL: in std_logic;
        STALL: in std_logic;
        DONE: out std_logic
    );
end;

architecture behavioral of divider is
    type state_t is (st_init, st_div, st_sign, st_done);

    signal sign_buff, dividend_sign, div_sign: std_logic;
    signal div_buff: word_t;

    signal Q: std_logic_vector(word_length * 2 - 1 downto 0);

    signal adder_buff: std_logic_vector(word_length downto 0);
    signal adder_carry: std_logic;
    signal adder_result: std_logic_vector(word_length - 1 downto 0);
    signal current_state: state_t;
    signal iter: integer range 0 to word_length - 1;
    
    signal quotient_buff, remainder_buff: word_t;
begin
    -- QUOTIENT <= conv_std_logic_vector(to_integer(unsigned(DIVIDEND)) / to_integer(unsigned(DIV)), 32);
    -- REMAINDER <= conv_std_logic_vector(to_integer(unsigned(DIVIDEND)) mod to_integer(unsigned(DIV)), 32);

    QUOTIENT <= quotient_buff;
    REMAINDER <= remainder_buff;

    adder_buff <= ("0" & Q(word_length * 2 - 1 downto word_length)) + ("0" & not div_buff) + 1;
    adder_carry <= not adder_buff(word_length);
    adder_result <= adder_buff(word_length - 1 downto 0);

    process(CLK, RST)
    begin
        if RST = '1' then
            DONE <= '0';
            current_state <= st_init;
        elsif rising_edge(CLK) then
            if CANCEL = '1' then
                DONE <= '0';
                current_state <= st_init;
            else
                case current_state is
                    when st_init =>
                        if EN = '1' then
                            sign_buff <= SIGN;
                            dividend_sign <= DIVIDEND(word_length - 1);
                            div_sign <= DIV(word_length - 1);
                            if DIVIDEND(word_length - 1) = '0' or SIGN = '0' then
                                Q <= (word_length - 2 downto 0 => '0') & DIVIDEND & "0";
                            else
                                Q <= (word_length - 2 downto 0 => '0') & (not DIVIDEND + 1) & "0";
                            end if;
                            if DIV(word_length - 1) = '0' or SIGN = '0' then
                                div_buff <= DIV;
                            else
                                div_buff <= not DIV + 1;
                            end if;
                            iter <= 0;
                            current_state <= st_div;
                        end if;
                    when st_div =>
                        if iter = word_length - 1 then
                            if adder_carry = '0' then -- remainder >= div
                                remainder_buff <= adder_result;
                                quotient_buff <= Q(word_length - 1 downto 1) & "1";
                            else -- remainder < div
                                remainder_buff <= Q(word_length * 2 - 1 downto word_length);
                                quotient_buff <= Q(word_length - 1 downto 1) & "0";
                            end if;
                            if sign_buff = '0' then
                                DONE <= '1';
                                current_state <= st_done;
                            else
                                current_state <= st_sign;
                            end if;
                        else
                            if adder_carry = '0' then -- remainder >= div
                                Q <= adder_result(word_length - 2 downto 0) &
                                     Q(word_length - 1 downto 1) & "10";
                            else -- remainder < div
                                Q <= Q(word_length * 2 - 2 downto 1) & "00";
                            end if;
                            iter <= iter + 1;
                        end if;
                    when st_sign =>
                        if dividend_sign /= div_sign then
                            quotient_buff <= not quotient_buff + 1;
                        end if;
                        if dividend_sign = '1' then
                            remainder_buff <= not remainder_buff + 1;
                        end if;
                        DONE <= '1';
                        current_state <= st_done;
                    when st_done =>
                        if STALL = '0' then
                            DONE <= '0';
                            current_state <= st_init;
                        end if;
                    when others =>
                        current_state <= st_init;
                end case;
            end if;
        end if;
    end process;
end;