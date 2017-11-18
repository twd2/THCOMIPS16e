library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity memory_access is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        COMMON: in common_signal_t;
        MEM: in mem_signal_t;
        WB: in wb_signal_t;

        COMMON_O: out common_signal_t;
        WB_O: out wb_signal_t;
        
        -- bus
        BUS_REQ: out bus_request_t;
        BUS_RES: in bus_response_t
    );
end;

architecture behavioral of memory_access is
begin
    process(RST, COMMON, MEM, WB, BUS_RES)
    begin
        if RST = '1' then
            STALL_REQ <= '0';
            COMMON_O.pc <= (others => '0');
            COMMON_O.op <= (others => '0');
            COMMON_O.funct <= (others => '0');
            WB_O.write_en <= '0';
            WB_O.write_addr <= (others => '0');
            WB_O.write_data <= (others => '0');
            WB_O.hi_write_en <= '0';
            WB_O.hi_write_data <= (others => '0');
            WB_O.lo_write_en <= '0';
            WB_O.lo_write_data <= (others => '0');
            WB_O.t_write_en <= '0';
            WB_O.t_write_data <= '0';
            WB_O.sp_write_en <= '0';
            WB_O.sp_write_data <= (others => '0');
            BUS_REQ.addr <= (others => '0');
            BUS_REQ.data <= (others => '0');
            BUS_REQ.byte_mask <= (others => '0');
            BUS_REQ.en <= '0';
            BUS_REQ.nread_write <= '0';
        else
            STALL_REQ <= '0';
            COMMON_O <= COMMON;
            WB_O <= WB;
            BUS_REQ.addr <= (others => 'X');
            BUS_REQ.data <= (others => 'X');
            BUS_REQ.byte_mask <= (others => 'X');
            BUS_REQ.en <= '0';
            BUS_REQ.nread_write <= 'X';
            
            if MEM.mem_en = '1' then
                if MEM.mem_write_en = '0' then
                    BUS_REQ.addr <= MEM.alu_result;
                    BUS_REQ.byte_mask <= (others => '1'); -- TODO
                    BUS_REQ.en <= '1';
                    BUS_REQ.nread_write <= '0';
                    
                    STALL_REQ <= not BUS_RES.done; -- wait BUS_RES.done
                    WB_O.write_data <= BUS_RES.data;
                else
                    BUS_REQ.addr <= MEM.alu_result;
                    BUS_REQ.byte_mask <= (others => '1'); -- TODO
                    BUS_REQ.en <= '1';
                    BUS_REQ.nread_write <= '1';
                    BUS_REQ.data <= MEM.write_mem_data;
                    
                    STALL_REQ <= not BUS_RES.done; -- wait BUS_RES.done
                    WB_O.write_data <= (others => 'X');
                end if;
            end if;
            -- TODO(twd2): check BUS_RES.tlb_miss, page_fault or error
        end if;
    end process;
end;