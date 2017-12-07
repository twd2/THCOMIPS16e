library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity ex_mem_reg is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        STALL: in stall_t;
        FLUSH: in std_logic;
        
        EX_COMMON: in common_signal_t;
        EX_MEM: in mem_signal_t;
        EX_WB: in wb_signal_t;
        
        MEM_COMMON: out common_signal_t;
        MEM_MEM: out mem_signal_t;
        MEM_WB: out wb_signal_t
    );
end;

architecture behavioral of ex_mem_reg is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            MEM_COMMON.pc <= (others => '0');
            MEM_COMMON.op <= (others => '0');
            MEM_COMMON.funct <= (others => '0');
            MEM_COMMON.is_in_delay_slot <= '0';
            MEM_MEM.alu_result <= (others => '0');
            MEM_MEM.mem_en <= '0';
            MEM_MEM.mem_write_en <= '0';
            MEM_MEM.write_mem_data <= (others => '0');
            MEM_MEM.is_uart_data <= '0';
            MEM_MEM.is_uart_control <= '0';
            MEM_MEM.except_type <= except_none;
            MEM_WB.write_en <= '0';
            MEM_WB.write_addr <= (others => '0');
            MEM_WB.write_data <= (others => '0');
            MEM_WB.hi_write_en <= '0';
            MEM_WB.hi_write_data <= (others => '0');
            MEM_WB.lo_write_en <= '0';
            MEM_WB.lo_write_data <= (others => '0');
            MEM_WB.t_write_en <= '0';
            MEM_WB.t_write_data <= '0';
            MEM_WB.sp_write_en <= '0';
            MEM_WB.sp_write_data <= (others => '0');
            MEM_WB.ds_write_en <= '0';
            MEM_WB.ds_write_data <= (others => '0');
            MEM_WB.cp0_write_en <= '0';
            MEM_WB.cp0_write_addr <= (others => '0');
            MEM_WB.cp0_write_data <= (others => '0');
        elsif rising_edge(CLK) then
            if FLUSH = '1' or STALL(stage_mem downto stage_ex) = "01" then
                MEM_COMMON.pc <= (others => '0');
                MEM_COMMON.op <= (others => '0');
                MEM_COMMON.funct <= (others => '0');
                MEM_COMMON.is_in_delay_slot <= '0';
                MEM_MEM.alu_result <= (others => 'X');
                MEM_MEM.mem_en <= '0';
                MEM_MEM.mem_write_en <= 'X';
                MEM_MEM.write_mem_data <= (others => 'X');
                MEM_MEM.is_uart_data <= 'X';
                MEM_MEM.is_uart_control <= 'X';
                MEM_MEM.except_type <= except_none;
                MEM_WB.write_en <= '0';
                MEM_WB.write_addr <= (others => 'X');
                MEM_WB.write_data <= (others => 'X');
                MEM_WB.hi_write_en <= '0';
                MEM_WB.hi_write_data <= (others => 'X');
                MEM_WB.lo_write_en <= '0';
                MEM_WB.lo_write_data <= (others => 'X');
                MEM_WB.t_write_en <= '0';
                MEM_WB.t_write_data <= 'X';
                MEM_WB.sp_write_en <= '0';
                MEM_WB.sp_write_data <= (others => 'X');
                MEM_WB.ds_write_en <= '0';
                MEM_WB.ds_write_data <= (others => 'X');
                MEM_WB.cp0_write_en <= '0';
                MEM_WB.cp0_write_addr <= (others => 'X');
                MEM_WB.cp0_write_data <= (others => 'X');
            elsif STALL(stage_mem downto stage_ex) = "11" then
                -- do nothing
            else
                MEM_COMMON <= EX_COMMON;
                MEM_MEM <= EX_MEM;
                MEM_WB <= EX_WB;
            end if;
        end if;
    end process;
end;