library IEEE;
use IEEE.std_logic_1164.all;
use work.signals.all;
use work.state.all;
use work.image_info.all;
use work.constants.all;

entity wow_crow is
    port
    (
        CLK: in std_logic; 
        RST: in std_logic;
        InputSW: in std_logic_vector(15 downto 0);
        fout: out std_logic_vector(15 downto 0);
    );
end;

architecture behavioral of wow_crow is
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
    signal current_state : state := s_inputA;
    signal OP: alu_op_t;
    signal OPERAND_0: word_t;
    signal OPERAND_1: word_t;
    signal result: word_t;
    signal output: word_t;
    signal OVERFLOW: out std_logic;
    signal ZERO: out std_logic;
    signal SIGN: out std_logic;
    signal CARRY: out std_logic;
begin
    fout <= output;
    alu_inst: alu
    port map
    (
        -- input
        OP => OP;
        OPERAND_0 => OPERAND_0;
        OPERAND_1 => OPERAND_1;

        -- output
        RESULT => result;

        -- flags
        OVERFLOW => OVERFLOW;
        ZERO => ZERO;
        SIGN => SIGN;
        CARRY => CARRY
    );

    main : process(CLK, RST)
    begin
        if RST = '1' then
            current_state <= s_inputA;
            OPERAND_0 <= InputSW;
        elsif rising_edge(CLK) then
            case current_state is
                when s_inputA =>
                    current_state <= s_inputB;
                    OPERAND_1 <= InputSW;                   
                when s_inputB =>
                    current_state <= s_inputOP;
                    OP <= InputSW[3 downto 0]; 
                when s_inputOP =>
                    current_state <= s_outFout;
                    output <= result;                     
                when s_outFout =>
                    current_state <= s_outFlag;
                    output[0] <= OVERFLOW;
                    output[1] <= ZERO;
                    output[2] <= SIGN;
                    output[3] <= CARRY;                      
                when others =>
                    current_state <= s_inputA;
                    OPERAND_0 <= InputSW;
            end case;
        end if;
    end process;
end;