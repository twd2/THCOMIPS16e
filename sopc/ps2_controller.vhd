library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.constants.all;
use work.types.all;

entity ps2_controller is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        PS2_DATA: in std_logic;
        PS2_CLK: in std_logic;
        
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t
    );
end;

architecture behavioral of ps2_controller is
    type state_type is (s_wait, s_begin, s_data, s_parity, s_end, s_done);
    signal data0, data, ps2_clk_buff, clk1, clk2, parity: std_logic; 
    signal frame: std_logic_vector(7 downto 0); 
    signal state: state_type;
    signal data_cnt : integer range 0 to 7;
    
    signal data_buff: word_t;
    signal data_ready: std_logic;
begin
    clk1 <= PS2_CLK when rising_edge(CLK);
    clk2 <= clk1 when rising_edge(CLK);
    ps2_clk_buff <= (not clk1) and clk2;
    
    data0 <= PS2_DATA when rising_edge(CLK);
    data <= data0 when rising_edge(CLK);
    
    process(RST, CLK)
    begin
        if RST = '1' then
            state <= s_begin;
            frame <= (others => '0');
            parity <= '0';
            data_cnt <= 0;
            data_buff <= (others => '0');
        elsif rising_edge(CLK) then
            case state is 
                when s_begin =>
                    if ps2_clk_buff = '1' then
                        if data = '0' then
                            state <= s_data;
                            data_cnt <= 0;
                            parity <= '0';
                        end if;
                    end if;
                when s_data =>
                    if ps2_clk_buff = '1' then
                        frame <= data & frame(7 downto 1) ;
                        parity <= parity xor data;
                        if data_cnt = 7 then
                            state <= s_parity;
                        else 
                            data_cnt <= data_cnt + 1;
                        end if;
                    end if;
                when s_parity =>
                    if ps2_clk_buff = '1' then
                        if (data xor parity) = '1' then
                            state <= s_end;
                        else
                            state <= s_begin;
                        end if;
                    end if;
                when s_end =>
                    if ps2_clk_buff = '1' then
                        if data = '1' then
                            data_buff <= (7 downto 0 => '0') & frame;
                            state <= s_done;
                        else
                            state <= s_begin;
                        end if;
                    end if;
                when s_done =>
                    state <= s_begin;
                when others =>
                    state <= s_begin;
            end case; 
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
            BUS_RES.data <= data_buff;
        else -- control
            BUS_RES.data <= (15 downto 1 => '0') & data_ready;
        end if;
    end process;

    data_ready_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            data_ready <= '0';
        elsif rising_edge(CLK) then
            if state = s_done then
                data_ready <= '1';
            end if;

            if BUS_REQ.en = '1' and BUS_REQ.nread_write = '0' then
                if BUS_REQ.addr(0) = '0' then -- data
                    data_ready <= '0';
                end if;
            end if;
        end if;
    end process;
end;
    