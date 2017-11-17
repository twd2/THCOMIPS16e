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

        COMMON: in common_signal_t;
        EX: in ex_signal_t;
        MEM: in mem_signal_t;
        WB: in wb_signal_t;

        COMMON_O: out common_signal_t;
        MEM_O: out mem_signal_t;
        WB_O: out wb_signal_t;

        HI: in word_t;
        LO: in word_t;
        
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
        OP => EX.alu_op,
        OPERAND_0 => EX.operand_0,
        OPERAND_1 => EX.operand_1,

        result => alu_result_buff
    );

    process(RST, alu_result_buff, COMMON, EX, MEM, WB,
            HI, LO, DIV_DONE, DIV_QUOTIENT, DIV_REMAINDER)
    begin
        if RST = '1' then
            STALL_REQ <= '0';
            COMMON_O.pc <= (others => '0');
            COMMON_O.op <= (others => '0');
            COMMON_O.funct <= (others => '0');
            MEM_O.alu_result <= (others => '0');
            MEM_O.mem_en <= '0';
            MEM_O.mem_write_en <= '0';
            MEM_O.write_mem_data <= (others => '0');
            WB_O.write_en <= '0';
            WB_O.write_addr <= (others => '0');
            WB_O.write_data <= (others => '0');
            WB_O.hi_write_en <= '0';
            WB_O.hi_write_data <= (others => '0');
            WB_O.lo_write_en <= '0';
            WB_O.lo_write_data <= (others => '0');
            DIV_DIVIDEND <= (others => '0');
            DIV_DIV <= (others => '0');
            DIV_SIGN <= '0';
            DIV_EN <= '0';
        else
            STALL_REQ <= '0';
            COMMON_O <= COMMON;
            MEM_O <= MEM;
            MEM_O.alu_result <= alu_result_buff;
            WB_O <= WB;
            WB_O.write_data <= alu_result_buff;
            WB_O.hi_write_en <= '0';
            WB_O.hi_write_data <= (others => 'X');
            WB_O.lo_write_en <= '0';
            WB_O.lo_write_data <= (others => 'X');
            DIV_DIVIDEND <= (others => 'X');
            DIV_DIV <= (others => 'X');
            DIV_SIGN <= 'X';
            DIV_EN <= '0';

            -- TODO(twd2)
        end if;
    end process;
end;