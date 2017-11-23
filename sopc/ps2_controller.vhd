library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ps2_controller is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        PS2_DATA: in std_logic;
        PS2_CLK: in std_logic;
        OUTPUT_FRAME: out std_logic_vector(7 downto 0);
        DONE: out std_logic
    );
end;

architecture behavioral of ps2_controller is
    type state_type is (s_wait, s_begin, s_data, s_parity, s_end, s_done);
    signal data, ps2_clk_buff, clk1, clk2, parity: std_logic; 
    signal frame: std_logic_vector(7 downto 0); 
    signal state: state_type;
    signal data_cnt : integer range 0 to 7;
begin
    clk1 <= PS2_CLK when rising_edge(CLK);
    clk2 <= clk1 when rising_edge(CLK);
    ps2_clk_buff <= (not clk1) and clk2;
    
    data <= PS2_DATA when rising_edge(CLK);
    
    OUTPUT_FRAME <= frame;
    
    process(RST, CLK)
    begin
        if RST = '1' then
            state <= s_wait;
            frame <= (others => '0');
            done <= '0';
        elsif rising_edge(CLK) then
            done <= '0';
            case state is 
                when s_wait =>
                    state <= s_begin;
                when s_begin =>
                    if ps2_clk_buff = '1' then
                        if data = '0' then
                            state <= s_data;
                            data_cnt <= 0;
                            parity <= '0';
                        else
                            state <= s_wait;
                        end if;
                    end if;
                when s_data =>
                    if ps2_clk_buff = '1' then
                        frame(data_cnt) <= data;
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
                            state <= s_wait;
                        end if;
                    end if;
                when s_end =>
                    if ps2_clk_buff = '1' then
                        if data = '1' then
                            state <= s_done;
                        else
                            state <= s_wait;
                        end if;
                    end if;
                when s_done =>
                    state <= s_wait;
                    done <= '1';
                when others =>
                    state <= s_wait;
            end case; 
        end if;
    end process;
end;
    