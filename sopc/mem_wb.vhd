library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity mem_wb_reg is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        STALL: in stall_t;
        FLUSH: in std_logic;

        MEM_COMMON: in common_signal_t;
        MEM_WB: in wb_signal_t;
        
        WB_COMMON: out common_signal_t;
        WB_WB: out wb_signal_t
    );
end;

architecture behavioral of mem_wb_reg is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            WB_COMMON.pc <= (others => '0');
            WB_COMMON.op <= (others => '0');
            WB_COMMON.funct <= (others => '0');
            WB_COMMON.is_in_delay_slot <= '0';
            WB_WB.write_en <= '0';
            WB_WB.write_addr <= (others => '0');
            WB_WB.write_data <= (others => '0');
            WB_WB.hi_write_en <= '0';
            WB_WB.hi_write_data <= (others => '0');
            WB_WB.lo_write_en <= '0';
            WB_WB.lo_write_data <= (others => '0');
            WB_WB.t_write_en <= '0';
            WB_WB.t_write_data <= '0';
            WB_WB.sp_write_en <= '0';
            WB_WB.sp_write_data <= (others => '0');
            WB_WB.ds_write_en <= '0';
            WB_WB.ds_write_data <= (others => '0');
            WB_WB.cp0_write_en <= '0';
            WB_WB.cp0_write_addr <= (others => '0');
            WB_WB.cp0_write_data <= (others => '0');
        elsif rising_edge(CLK) then
            if FLUSH = '1' or STALL(stage_wb downto stage_mem) = "01" then
                WB_COMMON.pc <= (others => '0');
                WB_COMMON.op <= (others => '0');
                WB_COMMON.funct <= (others => '0');
                WB_COMMON.is_in_delay_slot <= '0';
                WB_WB.write_en <= '0';
                WB_WB.write_addr <= (others => 'X');
                WB_WB.write_data <= (others => 'X');
                WB_WB.hi_write_en <= '0';
                WB_WB.hi_write_data <= (others => 'X');
                WB_WB.lo_write_en <= '0';
                WB_WB.lo_write_data <= (others => 'X');
                WB_WB.t_write_en <= '0';
                WB_WB.t_write_data <= 'X';
                WB_WB.sp_write_en <= '0';
                WB_WB.sp_write_data <= (others => 'X');
                WB_WB.ds_write_en <= '0';
                WB_WB.ds_write_data <= (others => 'X');
                WB_WB.cp0_write_en <= '0';
                WB_WB.cp0_write_addr <= (others => 'X');
                WB_WB.cp0_write_data <= (others => 'X');
            elsif STALL(stage_wb downto stage_mem) = "11" then
                -- do nothing
            else
                WB_COMMON <= MEM_COMMON;
                WB_WB <= MEM_WB;
            end if;
        end if;
    end process;
end;