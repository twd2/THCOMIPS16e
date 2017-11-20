library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity bus_arbiter is
    port
    (
        -- hosts (2 > 1 > 0)
        BUS_REQ_0: in bus_request_t;
        BUS_RES_0: out bus_response_t;
        BUS_REQ_1: in bus_request_t;
        BUS_RES_1: out bus_response_t;
        BUS_REQ_2: in bus_request_t;
        BUS_RES_2: out bus_response_t;
        
        -- device
        BUS_REQ: out bus_request_t;
        BUS_RES: in bus_response_t
    );
end;

architecture behavioral of bus_arbiter is
begin
    process(BUS_REQ_0, BUS_REQ_1, BUS_REQ_2, BUS_RES)
    begin
        BUS_RES_0 <= BUS_RES;
        BUS_RES_1 <= BUS_RES;
        BUS_RES_2 <= BUS_RES;
        if BUS_REQ_2.en = '1' then
            BUS_REQ <= BUS_REQ_2;
            BUS_RES_0.done <= '0';
            BUS_RES_0.grant <= '0';
            BUS_RES_1.done <= '0';
            BUS_RES_1.grant <= '0';
        elsif BUS_REQ_1.en = '1' then
            BUS_REQ <= BUS_REQ_1;
            BUS_RES_0.done <= '0';
            BUS_RES_0.grant <= '0';
            BUS_RES_2.done <= '0';
            BUS_RES_2.grant <= '0';
        else
            BUS_REQ <= BUS_REQ_0;
            BUS_RES_1.done <= '0';
            BUS_RES_1.grant <= '0';
            BUS_RES_2.done <= '0';
            BUS_RES_2.grant <= '0';
        end if;
    end process;
end;