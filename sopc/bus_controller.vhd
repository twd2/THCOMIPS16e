library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity bus_controller is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
    
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t;

        SYSBUS_ADDR: out word_t;
        SYSBUS_DIN: in word_t;
        SYSBUS_DEN: out std_logic;
        SYSBUS_DOUT: out word_t;

        RAM1_nWE: out std_logic;
        RAM1_nOE: out std_logic;
        RAM1_nCE: out std_logic;

        UART_nRE: out std_logic;
        UART_READY: in std_logic;

        UART_nWE: out std_logic;
        UART_TBRE: in std_logic;
        UART_TSRE: in std_logic
    );
end;

architecture behavioral of bus_controller is
    signal uart_read_ready_buff, uart_write_ready_buff: std_logic_vector(1 downto 0);
    signal uart_control_reg: word_t;
    signal uart_nwe_buff: std_logic;
begin
    RAM1_nCE <= '0';

    -- delay 2 clocks
    process(CLK, RST)
    begin
        if RST = '1' then
            uart_read_ready_buff <= "00";
        elsif rising_edge(CLK) then
            uart_read_ready_buff <= uart_read_ready_buff(0) & UART_READY;
        end if;
    end process;
    
    -- delay 2 clocks
    process(CLK, RST)
    begin
        if RST = '1' then
            uart_write_ready_buff <= "00";
        elsif rising_edge(CLK) then
            uart_write_ready_buff <= uart_write_ready_buff(0) & (UART_TBRE and UART_TSRE);
        end if;
    end process;
    
    uart_control_reg <= (13 downto 0 => '0') & uart_read_ready_buff(1) & uart_write_ready_buff(1);
    
    process(CLK, RST)
    begin
        if RST = '1' then
            UART_nWE <= '1';
        elsif falling_edge(CLK) then -- FIXME: gated clock
            UART_nWE <= uart_nwe_buff; -- delay 0.5 clock
        end if;
    end process;

    process(BUS_REQ, SYSBUS_DIN, uart_control_reg)
    begin
        RAM1_nOE <= '1';
        RAM1_nWE <= '1';
        UART_nRE <= '1';
        uart_nwe_buff <= '1';

        SYSBUS_ADDR <= "0" & BUS_REQ.addr(word_msb - 1 downto 0);
        SYSBUS_DEN <= BUS_REQ.nread_write;
        SYSBUS_DOUT <= BUS_REQ.data;

        BUS_RES.data <= SYSBUS_DIN;
        BUS_RES.grant <= '1';
        BUS_RES.done <= '1';
        BUS_RES.tlb_miss <= '0';
        BUS_RES.page_fault <= '0';
        BUS_RES.error <= '0';

        if BUS_REQ.en = '1' then
            if BUS_REQ.addr = x"BF01" then -- UART control reg
                if BUS_REQ.nread_write = '0' then -- read
                    BUS_RES.data <= uart_control_reg;
                else -- write
                    -- undefined behavior
                end if;
            elsif BUS_REQ.addr = x"BF00" then -- UART data reg
                if BUS_REQ.nread_write = '0' then -- read
                    UART_nRE <= '0';
                else -- write
                    uart_nwe_buff <= '0';
                end if;
            else -- SRAM1
                if BUS_REQ.nread_write = '0' then -- read
                    RAM1_nOE <= '0';
                    RAM1_nWE <= '1';
                else -- write
                    RAM1_nOE <= '1';
                    RAM1_nWE <= '0';
                end if;
            end if;
        end if;
    end process;
end;