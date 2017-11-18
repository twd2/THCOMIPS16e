library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity extbus_interface is
    port
    (
        EXTBUS_ADDR: out word_t;
        EXTBUS_DIN: in word_t;
        EXTBUS_DEN: out std_logic;
        EXTBUS_DOUT: out word_t;

        RAM2_nWE: out std_logic;
        RAM2_nOE: out std_logic;
        RAM2_nCE: out std_logic;
        
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t
    );
end;

architecture behavioral of extbus_interface is
begin
    RAM2_nCE <= '0';

    EXTBUS_ADDR <= BUS_REQ.addr;
    EXTBUS_DEN <= BUS_REQ.nread_write;
    EXTBUS_DOUT <= BUS_REQ.data;
    BUS_RES.data <= EXTBUS_DIN;
    
    RAM2_nWE <= not BUS_REQ.nread_write;
    RAM2_nOE <= BUS_REQ.nread_write;
    
    BUS_RES.grant <= '1';
    BUS_RES.done <= '1';
    BUS_RES.tlb_miss <= '0';
    BUS_RES.page_fault <= '0';
    BUS_RES.error <= '0';
end;