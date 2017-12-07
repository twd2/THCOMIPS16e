library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity timer is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t;
        
        IRQ: out std_logic
    );
end;

architecture behavioral of timer is
    constant TIMEOUT_TICKS: integer := 180000; -- 5ms
    signal counter: integer range 0 to TIMEOUT_TICKS - 1;
    signal irq_buff: std_logic;
begin
    IRQ <= irq_buff;

    process(CLK, RST)
    begin
        if RST = '1' then
            counter <= 0;
        elsif rising_edge(CLK) then
            if counter = TIMEOUT_TICKS - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    BUS_RES.grant <= '1';
    BUS_RES.done <= '1';
    BUS_RES.tlb_miss <= '0';
    BUS_RES.page_fault <= '0';
    BUS_RES.error <= '0';
    
    read_proc:
    process(BUS_REQ, irq_buff)
    begin
        if BUS_REQ.addr(0) = '1' then
            BUS_RES.data <= (15 downto 1 => '0') & irq_buff;
        else
            BUS_RES.data <= (others => 'X');
        end if;
    end process;
    
    write_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            irq_buff <= '0';
        elsif rising_edge(CLK) then
            if counter = TIMEOUT_TICKS - 1 then
                irq_buff <= '1';
            end if;
            
            if BUS_REQ.en = '1' and BUS_REQ.nread_write = '1' then
                if BUS_REQ.addr(0) = '1' then
                    if BUS_REQ.data(0) = '1' then
                        irq_buff <= '0'; -- write 1 to clear
                    end if;
                end if;
            end if;
        end if;
    end process;
end;