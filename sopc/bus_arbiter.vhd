library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity bus_arbiter is
    port
    (
        -- masters (0 has higher priority)
        BUS_REQ_0: in bus_request_t;
        BUS_RES_0: out bus_response_t;
        BUS_REQ_1: in bus_request_t;
        BUS_RES_1: out bus_response_t;
        
        -- slave
        BUS_REQ: out bus_request_t;
        BUS_RES: in bus_response_t
    );
end;

architecture behavioral of bus_arbiter is
begin
    process(all)
    begin
        BUS_RES_0 <= BUS_RES;
        BUS_RES_1 <= BUS_RES;
        if BUS_REQ_0.en = '1' then
            BUS_REQ <= BUS_REQ_0;
            BUS_RES_1.done <= '0';
            BUS_RES_1.grant <= '0';
        else
            BUS_REQ <= BUS_REQ_1;
            BUS_RES_0.done <= '0';
            BUS_RES_0.grant <= '0';
        end if;
    end process;
end;