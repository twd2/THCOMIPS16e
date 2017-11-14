library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity execute is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        OP: in op_t;
        FUNCT: in funct_t;
        ALU_OP: in alu_op_t;
        OPERAND_0: in word_t;
        OPERAND_1: in word_t;
        WRITE_EN: in std_logic;
        WRITE_ADDR: in reg_addr_t;
        WRITE_MEM_DATA: in word_t;
        HI: in word_t;
        LO: in word_t;
        
        PC_O: out word_t;
        OP_O: out op_t;
        FUNCT_O: out funct_t;
        ALU_RESULT: out word_t;
        WRITE_EN_O: out std_logic;
        WRITE_ADDR_O: out reg_addr_t;
        WRITE_DATA: out word_t;
        WRITE_MEM_DATA_O: out word_t;
        HI_WRITE_EN: out std_logic;
        HI_WRITE_DATA: out word_t;
        LO_WRITE_EN: out std_logic;
        LO_WRITE_DATA: out word_t;
        
        -- divider interface
        -- data signals
        DIV_DIVIDEND: out word_t;
        DIV_DIV: out word_t;
        
        DIV_QUOTIENT: in word_t;
        DIV_REMAINDER: in word_t;
        
        -- control signals
        DIV_SIGN: out std_logic;
        DIV_EN: out std_logic;
        DIV_DONE: in std_logic
    );
end;

architecture behavioral of execute is
    component alu is
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
    end component;

    signal alu_result_buff: word_t;
begin
    alu_inst: alu
    port map
    (
        RST => RST,
        OP => ALU_OP,
        OPERAND_0 => OPERAND_0,
        OPERAND_1 => OPERAND_1,

        result => alu_result_buff
    );

    process(RST, PC, OP, FUNCT, alu_result_buff, WRITE_EN, WRITE_ADDR, WRITE_MEM_DATA,
            HI, LO, OPERAND_0, OPERAND_1, DIV_DONE, DIV_QUOTIENT, DIV_REMAINDER)
    begin
        if RST = '1' then
            STALL_REQ <= '0';
            PC_O <= (others => '0');
            OP_O <= (others => '0');
            FUNCT_O <= (others => '0');
            ALU_RESULT <= (others => '0');
            WRITE_EN_O <= '0';
            WRITE_ADDR_O <= (others => '0');
            WRITE_DATA <=  (others => '0');
            WRITE_MEM_DATA_O <= (others => '0');
            HI_WRITE_EN <= '0';
            HI_WRITE_DATA <= (others => '0');
            LO_WRITE_EN <= '0';
            LO_WRITE_DATA <= (others => '0');
            DIV_DIVIDEND <= (others => '0');
            DIV_DIV <= (others => '0');
            DIV_SIGN <= '0';
            DIV_EN <= '0';
        else
            STALL_REQ <= '0';
            PC_O <= PC;
            OP_O <= OP;
            FUNCT_O <= FUNCT;
            ALU_RESULT <= alu_result_buff;
            WRITE_EN_O <= WRITE_EN;
            WRITE_ADDR_O <= WRITE_ADDR;
            WRITE_DATA <= alu_result_buff;
            WRITE_MEM_DATA_O <= WRITE_MEM_DATA;
            HI_WRITE_EN <= '0';
            HI_WRITE_DATA <= (others => 'X');
            LO_WRITE_EN <= '0';
            LO_WRITE_DATA <= (others => 'X');
            DIV_DIVIDEND <= (others => 'X');
            DIV_DIV <= (others => 'X');
            DIV_SIGN <= 'X';
            DIV_EN <= '0';

            -- TODO(twd2): address of load/store
            case OP is
                when op_special =>
                    case FUNCT is
                        when func_mfhi =>
                            WRITE_DATA <= HI;
                        when func_mflo =>
                            WRITE_DATA <= LO;
                        when func_mthi =>
                            HI_WRITE_EN <= '1';
                            HI_WRITE_DATA <= OPERAND_0;
                        when func_mtlo =>
                            LO_WRITE_EN <= '1';
                            LO_WRITE_DATA <= OPERAND_0;
                        when func_div =>
                            STALL_REQ <= not DIV_DONE;
                            DIV_DIVIDEND <= OPERAND_0;
                            DIV_DIV <= OPERAND_1;
                            DIV_SIGN <= '1';
                            DIV_EN <= '1';
                            LO_WRITE_EN <= '1';
                            LO_WRITE_DATA <= DIV_QUOTIENT;
                            HI_WRITE_EN <= '1';
                            HI_WRITE_DATA <= DIV_REMAINDER;
                        when func_divu =>
                            STALL_REQ <= not DIV_DONE;
                            DIV_DIVIDEND <= OPERAND_0;
                            DIV_DIV <= OPERAND_1;
                            DIV_SIGN <= '0';
                            DIV_EN <= '1';
                            LO_WRITE_EN <= '1';
                            LO_WRITE_DATA <= DIV_QUOTIENT;
                            HI_WRITE_EN <= '1';
                            HI_WRITE_DATA <= DIV_REMAINDER;
                        when others =>
                    end case;
                when others =>
            end case;
        end if;
    end process;
end;