library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity controller is
    port
    (
        nCLK: in std_logic; 
        nRST: in std_logic;
        nInputSW: in word_t;
        fout: out word_t
    );
end;

architecture behavioral of controller is
    component alu is 
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
    end component;

    type state is (s_inputA, s_inputB, s_inputOP, s_outputFout, s_outputFlag);
    signal current_state: state;
    
    signal clk, rst: std_logic;
    signal InputSW: word_t;

    signal OP: alu_op_t;
    signal OPERAND_0: word_t;
    signal OPERAND_1: word_t;
    signal result: word_t;
    signal output: word_t;
    signal OVERFLOW: std_logic;
    signal ZERO: std_logic;
    signal SIGN: std_logic;
    signal CARRY: std_logic;
begin
    clk <= not nCLK;
    rst <= not nRST;
    InputSW <= not nInputSW;

    fout <= output;

    alu_inst: alu
    port map
    (
        -- input
        OP => OP,
        OPERAND_0 => OPERAND_0,
        OPERAND_1 => OPERAND_1,

        -- output
        RESULT => result,

        -- flags
        OVERFLOW => OVERFLOW,
        ZERO => ZERO,
        SIGN => SIGN,
        CARRY => CARRY
    );

    main : process(CLK, RST)
    begin
        if RST = '1' then
            current_state <= s_inputA;
        elsif rising_edge(CLK) then
            case current_state is
                when s_inputA =>
                    OPERAND_0 <= InputSW;
                    current_state <= s_inputB;
                when s_inputB =>
                    OPERAND_1 <= InputSW;   
                    current_state <= s_inputOP;
                when s_inputOP =>
                    OP <= InputSW(3 downto 0);
                    current_state <= s_outputFout;
                when s_outputFout =>
                    current_state <= s_outputFlag;
                when s_outputFlag =>
                    OPERAND_0 <= InputSW;
                    current_state <= s_inputB;
                when others =>
                    current_state <= s_inputA;
            end case;
        end if;
    end process;

    output_proc : process(current_state, result, OVERFLOW, ZERO, SIGN, CARRY)
    begin
        case current_state is
            when s_outputFout =>
                output <= result;
            when s_outputFlag =>
                output <= (others => '0');
                output(0) <= OVERFLOW;
                output(1) <= ZERO;
                output(2) <= SIGN;
                output(3) <= CARRY;
            when others =>
                output <= (others => '0');
        end case;
    end process;
end;