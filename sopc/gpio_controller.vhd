library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity gpio_controller is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
    
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t;

        GPIO: inout word_t
    );
end;

architecture behavioral of gpio_controller is
    signal direction_buff, din_buff, dout_buff: word_t;
    
    signal GPIO_DIN: word_t;
    signal GPIO_nDEN: word_t;
    signal GPIO_DOUT: word_t;
begin
    GPIO_nDEN <= direction_buff;
    GPIO_DOUT <= dout_buff;
    GPIO_DIN <= GPIO;
    
    process(GPIO_nDEN, GPIO_DOUT)
    begin
        for i in 0 to word_msb loop
            if GPIO_nDEN(i) = '0' then
                GPIO(i) <= GPIO_DOUT(i);
            else
                GPIO(i) <= 'Z';
            end if;
        end loop;
    end process;

    process(CLK, RST)
    begin
        if RST = '1' then
            din_buff <= (others => '0');
        elsif rising_edge(CLK) then
            din_buff <= GPIO_DIN; -- delay DIN 1 clock
        end if;
    end process;

    BUS_RES.grant <= '1';
    BUS_RES.done <= '1';
    BUS_RES.tlb_miss <= '0';
    BUS_RES.page_fault <= '0';
    BUS_RES.error <= '0';

    read_proc:
    process(BUS_REQ)
    begin
        if BUS_REQ.addr(0) = '0' then -- data
            BUS_RES.data <= din_buff;
        else -- control
            BUS_RES.data <= direction_buff;
        end if;
    end process;

    write_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            dout_buff <= (others => '0');
            direction_buff <= (others => '1');
        elsif rising_edge(CLK) then
            if BUS_REQ.en = '1' and BUS_REQ.nread_write = '1' then
                if BUS_REQ.addr(0) = '0' then -- data
                    dout_buff <= BUS_REQ.data;
                else -- control
                    direction_buff <= BUS_REQ.data;
                end if;
            end if;
        end if;
    end process;
end;