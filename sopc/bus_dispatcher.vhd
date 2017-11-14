library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity bus_dispatcher is
    port
    (
        -- master
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t;
        
        -- slaves
        BUS_REQ_0: out bus_request_t;
        BUS_RES_0: in bus_response_t;
        BUS_REQ_1: out bus_request_t;
        BUS_RES_1: in bus_response_t
    );
end;

architecture behavioral of bus_dispatcher is
    signal slave_sel: std_logic;
begin
    slave_sel <= BUS_REQ.addr(31); -- TODO

    process(all)
    begin
        BUS_REQ_0 <= BUS_REQ;
        BUS_REQ_1 <= BUS_REQ;
        if slave_sel = '0' then
            BUS_RES <= BUS_RES_0;
            BUS_REQ_1.en <= '0';
        else
            BUS_RES <= BUS_RES_1;
            BUS_REQ_0.en <= '0';
        end if;
    end process;
end;