library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity except_controller is
    port
    (
        RST: in std_logic;
        
        MEM_EXCEPT_TYPE: in except_type_t;
        MEM_IS_IN_DELAY_SLOT: in std_logic;
        MEM_PC: in word_t;
        MEM_CP0_BITS: in cp0_bits_t;

        PC_FLUSH: out std_logic;
        PC_FLUSH_PC: out word_t;

        IF_ID_FLUSH: out std_logic;
        ID_EX_FLUSH: out std_logic;
        EX_MEM_FLUSH: out std_logic;
        MEM_WB_FLUSH: out std_logic;
        
        EXCEPT_WRITE: out cp0_except_write_t
    );
end;

architecture behavioral of except_controller is
    signal epc: word_t;
begin
    process(MEM_IS_IN_DELAY_SLOT, MEM_PC)
    begin
        if MEM_IS_IN_DELAY_SLOT = '0' then
            epc <= MEM_PC - 1; -- victim
        else -- is in branch delay slot
            epc <= MEM_PC - 2; -- points to the branch instruction
        end if;
    end process;

    process(MEM_EXCEPT_TYPE, MEM_CP0_BITS, epc, MEM_EXCEPT_TYPE)
    begin
        PC_FLUSH <= '0';
        PC_FLUSH_PC <= (others => 'X');
        IF_ID_FLUSH <= '0';
        ID_EX_FLUSH <= '0';
        EX_MEM_FLUSH <= '0';
        MEM_WB_FLUSH <= '0';
        EXCEPT_WRITE.en <= '0';
        EXCEPT_WRITE.in_except_handler <= '1';
        EXCEPT_WRITE.cause <= MEM_EXCEPT_TYPE;
        EXCEPT_WRITE.epc <= epc;
        EXCEPT_WRITE.ecs <= (others => 'X');

        if MEM_PC /= x"0000" then -- is not bubble
            if MEM_EXCEPT_TYPE(except_type_bit_eret) = '1' then
                PC_FLUSH <= '1';
                PC_FLUSH_PC <= MEM_CP0_BITS.EPC;
                IF_ID_FLUSH <= '1';
                ID_EX_FLUSH <= '1';
                EX_MEM_FLUSH <= '1';
                MEM_WB_FLUSH <= '1';
                EXCEPT_WRITE.en <= '1';
                EXCEPT_WRITE.in_except_handler <= '0';
            elsif MEM_EXCEPT_TYPE(except_type_bit_syscall) = '1' then
                PC_FLUSH <= '1';
                PC_FLUSH_PC <= x"0010"; -- TODO: internal interrupt handler
                IF_ID_FLUSH <= '1';
                ID_EX_FLUSH <= '1';
                EX_MEM_FLUSH <= '1';
                MEM_WB_FLUSH <= '1';
                EXCEPT_WRITE.en <= '1';
            elsif MEM_EXCEPT_TYPE(5 downto 0) /= (5 downto 0 => '0') then
                PC_FLUSH <= '1';
                PC_FLUSH_PC <= x"0020"; -- TODO: external interrupt handler
                IF_ID_FLUSH <= '1';
                ID_EX_FLUSH <= '1';
                EX_MEM_FLUSH <= '1';
                MEM_WB_FLUSH <= '1';
                EXCEPT_WRITE.en <= '1';
            end if;
        end if;
    end process;
end;