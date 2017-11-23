library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ps2_controller is
	port (
		DATA_IN, CLK_IN: in std_logic; -- PS2 clk and data
		CLK_FILTER, RST: in std_logic;  -- filter clock
		OUTPUT_FRAME: out std_logic_vector(7 downto 0) -- output signal
	);
end ps2_controller;

architecture behavioral of ps2_controller is
	type state_type is (s_wait, s_begin, s_data, s_parity, s_end, s_done);
	signal data, clk, clk1, clk2, odd, done: std_logic; 
	signal frame: std_logic_vector(7 downto 0); 
	signal state: state_type;
	signal data_cnt : integer range 0 to 7;
begin
	clk1 <= CLK_IN when rising_edge(CLK_FILTER);
	clk2 <= clk1 when rising_edge(CLK_FILTER);
	clk <= (not clk1) and clk2;
	
	data <= DATA_IN when rising_edge(CLK_FILTER);
	
	OUTPUT_FRAME <= frame when done = '1' else (others => '0');
	
	process(RST, CLK_FILTER)
	begin
		if RST = '1' then
			state <= s_wait;
			frame <= (others => '0');
			done <= '0';
		elsif rising_edge(CLK_FILTER) then
			done <= '0';
			case state is 
				when s_wait =>
					state <= s_begin;
				when s_begin =>
					if clk = '1' then
						if data = '0' then
							state <= s_data;
							data_cnt <= 0;
							odd <= '0';
						else
							state <= s_wait;
						end if;
					end if;
				when s_data =>
					if clk = '1' then
						frame(data_cnt) <= data;
						odd <= odd xor data;
						if data_cnt = 7 then
							state <= s_parity;
						else 
							data_cnt <= data_cnt + 1;
						end if;
					end if;
				when s_parity =>
					if clk = '1' then
						if (data xor odd) = '1' then
							state <= s_end;
						else
							state <= s_wait;
						end if;
					end if;
				when s_end =>
					if clk = '1' then
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
	