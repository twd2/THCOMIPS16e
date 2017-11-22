library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity device_bus_dispatcher is
    port
    (
        -- host
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t;
        
        -- devices
        GPIO_BUS_REQ: out bus_request_t;
        GPIO_BUS_RES: in bus_response_t
    );
end;

architecture behavioral of device_bus_dispatcher is
begin
    -- device: 1110 0000 0000 0000 ~ 1111 1111 1111 1111 (E000~FFFF)
    -- VGA data: 1111 0000 0000 0000 ~ 1111 1111 1111 1111 (F000~FFFF)
    -- VGA control: 1110 1111 1111 1110 ~ 1110 1111 1111 1111 (EFFE~EFFF)
    -- GPIO: 1110 0000 0000 0000 (data) ~ 1110 0000 0000 0001 (control) (E000~E001)

    process(BUS_REQ, GPIO_BUS_RES)
    begin
        GPIO_BUS_REQ <= BUS_REQ;
        if BUS_REQ.addr(word_msb downto 1) = "111000000000000" then
            BUS_RES <= GPIO_BUS_RES;
        else
            GPIO_BUS_REQ.en <= '0';
            BUS_RES <= GPIO_BUS_RES;
        end if;
    end process;
end;