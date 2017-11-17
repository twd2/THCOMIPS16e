library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity instruction_fetch is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;
        
        PC: in word_t;
        PC_4: in word_t;
        
        PC_O: out word_t;
        INS: out word_t;
        
        -- bus
        BUS_REQ: out bus_request_t;
        BUS_RES: in bus_response_t
    );
end;

architecture behavioral of instruction_fetch is
begin
    PC_O <= PC_4;

    -- TODO(twd2): check BUS_RES.tlb_miss, page_fault or error
    BUS_REQ.data <= (others => 'X');
    BUS_REQ.addr <= PC;
    BUS_REQ.byte_mask <= (others => '1');
    BUS_REQ.en <= not RST;
    BUS_REQ.nread_write <= '0';
    INS <= BUS_RES.data;
    
    STALL_REQ <= not BUS_RES.done; -- wait BUS_RES.done
end;