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
        GPIO_BUS_RES: in bus_response_t;
        GRAPHICS_BUS_REQ: out bus_request_t;
        GRAPHICS_BUS_RES: in bus_response_t;
        VGA_BUS_REQ: out bus_request_t;
        VGA_BUS_RES: in bus_response_t;
        PS2_BUS_REQ: out bus_request_t;
        PS2_BUS_RES: in bus_response_t;
        SD_BUS_REQ: out bus_request_t;
        SD_BUS_RES: in bus_response_t;
        TIMER_BUS_REQ: out bus_request_t;
        TIMER_BUS_RES: in bus_response_t
    );
end;

architecture behavioral of device_bus_dispatcher is
begin
    -- device: 1110 0000 0000 0000 ~ 1111 1111 1111 1111 (E000~FFFF)
    -- VGA data: 1111 0000 0000 0000 ~ 1111 1111 1111 1111 (F000~FFFF)
    -- VGA control: 1110 1111 1111 1100 ~ 1110 1111 1111 1111 (EFFC~EFFF)
    -- GPIO: 1110 0000 0000 0000 (data) ~ 1110 0000 0000 0001 (control) (E000~E001)
    -- PS2: 1110 0000 0000 0010 (data) ~ 1110 0000 0000 0011 (control) (E002~E003)
    -- Timer: 1110 0000 0000 0100 (reserved) ~ 1110 0000 0000 0101 (control) (E004~E005)
    -- SD: 1110 0000 0000 1000 ~ 1110 0000 0000 1111 (E008~E00F)

    process(BUS_REQ, GPIO_BUS_RES)
    begin
        GPIO_BUS_REQ <= BUS_REQ;
        GRAPHICS_BUS_REQ <= BUS_REQ;
        VGA_BUS_REQ <= BUS_REQ;
        PS2_BUS_REQ <= BUS_REQ;
        SD_BUS_REQ <= BUS_REQ;
        TIMER_BUS_REQ <= BUS_REQ;
        if BUS_REQ.addr(word_msb downto 1) = x"E00" & "000" then
            BUS_RES <= GPIO_BUS_RES;
            GRAPHICS_BUS_REQ.en <= '0';
            VGA_BUS_REQ.en <= '0';
            PS2_BUS_REQ.en <= '0';
            SD_BUS_REQ.en <= '0';
            TIMER_BUS_REQ.en <= '0';
        elsif BUS_REQ.addr(word_msb downto word_msb - 3) = x"F" then
            BUS_RES <= GRAPHICS_BUS_RES;
            GPIO_BUS_REQ.en <= '0';
            VGA_BUS_REQ.en <= '0';
            PS2_BUS_REQ.en <= '0';
            SD_BUS_REQ.en <= '0';
            TIMER_BUS_REQ.en <= '0';
        elsif BUS_REQ.addr(word_msb downto 2) = x"EFF" & "11" then
            BUS_RES <= VGA_BUS_RES;
            GPIO_BUS_REQ.en <= '0';
            GRAPHICS_BUS_REQ.en <= '0';
            PS2_BUS_REQ.en <= '0';
            SD_BUS_REQ.en <= '0';
            TIMER_BUS_REQ.en <= '0';
        elsif BUS_REQ.addr(word_msb downto 1) = x"E00" & "001" then
            BUS_RES <= PS2_BUS_RES;
            GPIO_BUS_REQ.en <= '0';
            GRAPHICS_BUS_REQ.en <= '0';
            VGA_BUS_REQ.en <= '0';
            SD_BUS_REQ.en <= '0';
            TIMER_BUS_REQ.en <= '0';
        elsif BUS_REQ.addr(word_msb downto 1) = x"E00" & "010" then
            BUS_RES <= TIMER_BUS_RES;
            GPIO_BUS_REQ.en <= '0';
            GRAPHICS_BUS_REQ.en <= '0';
            VGA_BUS_REQ.en <= '0';
            PS2_BUS_REQ.en <= '0';
            SD_BUS_REQ.en <= '0';
        elsif BUS_REQ.addr(word_msb downto 3) = x"E00" & "1" then
            BUS_RES <= SD_BUS_RES;
            GPIO_BUS_REQ.en <= '0';
            GRAPHICS_BUS_REQ.en <= '0';
            VGA_BUS_REQ.en <= '0';
            PS2_BUS_REQ.en <= '0';
            TIMER_BUS_REQ.en <= '0';
        else
            BUS_RES <= GPIO_BUS_RES;
            GPIO_BUS_REQ.en <= '0';
            GRAPHICS_BUS_REQ.en <= '0';
            VGA_BUS_REQ.en <= '0';
            PS2_BUS_REQ.en <= '0';
            SD_BUS_REQ.en <= '0';
            TIMER_BUS_REQ.en <= '0';
        end if;
    end process;
end;