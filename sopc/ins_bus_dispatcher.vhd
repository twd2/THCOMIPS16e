library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity ins_bus_dispatcher is
    port
    (
        -- host
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t;
        
        -- devices
        EXTBUS_REQ: out bus_request_t;
        EXTBUS_RES: in bus_response_t;
        SYSBUS_REQ: out bus_request_t;
        SYSBUS_RES: in bus_response_t
    );
end;

architecture behavioral of ins_bus_dispatcher is
    signal is_sys, is_ext: std_logic;
begin
    is_ext <= not BUS_REQ.addr(word_msb);

    process(BUS_REQ, EXTBUS_RES, SYSBUS_RES)
    begin
        EXTBUS_REQ <= BUS_REQ;
        SYSBUS_REQ <= BUS_REQ;
        if is_ext = '1' then
            BUS_RES <= EXTBUS_RES;
            SYSBUS_REQ.en <= '0';
        else -- is_sys
            BUS_RES <= SYSBUS_RES;
            EXTBUS_REQ.en <= '0';
        end if;
    end process;
end;