library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity sysbus_controller is
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

architecture behavioral of sysbus_controller is
    signal uart_read_ready_buff, uart_write_ready_buff: std_logic_vector(1 downto 0);
    signal uart_control_reg: word_t;
    signal uart_nre_buff, uart_nwe_buff: std_logic;
    signal is_uart_data: std_logic;
begin
    RAM1_nCE <= '0';

    -- delay 2 clocks
    process(CLK, RST)
    begin
        if RST = '1' then
            uart_read_ready_buff <= "00";
        elsif rising_edge(CLK) then
            if uart_nre_buff = '0' then
                uart_read_ready_buff <= "00";
            else
                uart_read_ready_buff <= uart_read_ready_buff(0) & UART_READY;
            end if;
        end if;
    end process;
    
    -- delay 2 clocks
    process(CLK, RST)
    begin
        if RST = '1' then
            uart_write_ready_buff <= "00";
        elsif rising_edge(CLK) then
            if uart_nwe_buff = '0' then
                uart_write_ready_buff <= "00";
            else
                uart_write_ready_buff <= uart_write_ready_buff(0) & (UART_TBRE and UART_TSRE);
            end if;
        end if;
    end process;
    
    uart_control_reg <= (13 downto 0 => '0') & uart_read_ready_buff(1) & uart_write_ready_buff(1);
    
    UART_nRE <= uart_nre_buff;
    UART_nWE <= CLK or uart_nwe_buff;
    
    is_uart_data <= '1' when BUS_REQ.addr(14 downto 0) = "011" & x"F00" else '0';

    process(CLK, BUS_REQ, SYSBUS_DIN, uart_control_reg, is_uart_data)
    begin
        RAM1_nOE <= not (not is_uart_data and not BUS_REQ.nread_write);
        RAM1_nWE <= not (CLK and BUS_REQ.en and BUS_REQ.nread_write);
        uart_nre_buff <= not (is_uart_data and BUS_REQ.en and not BUS_REQ.nread_write);
        uart_nwe_buff <= not (BUS_REQ.en and BUS_REQ.nread_write and is_uart_data);

        SYSBUS_ADDR <= "0" & BUS_REQ.addr(word_msb - 1 downto 0);
        SYSBUS_DEN <= BUS_REQ.nread_write;
        SYSBUS_DOUT <= BUS_REQ.data;

        BUS_RES.data <= SYSBUS_DIN;
        BUS_RES.grant <= '1';
        BUS_RES.done <= '1';
        BUS_RES.tlb_miss <= '0';
        BUS_RES.page_fault <= '0';
        BUS_RES.error <= '0';

        if BUS_REQ.addr(14 downto 0) = "011" & x"F01" then -- UART control reg
            BUS_RES.data <= uart_control_reg;
        end if;
    end process;
end;