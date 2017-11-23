library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity keyboard_controller is
	port (
		DATA_IN, CLK_IN: in std_logic; -- PS2 clk and data
		CLK_FILTER, RST: in std_logic;  -- filter clock
		OUTPUT_FRAME: out std_logic_vector(7 downto 0) -- output signal
	);
end keyboard_controller;

architecture behavioral of keyboard_controller is
	type state_type is (s_wait, s_begin, s_data_0, s_data_1, s_data_2, s_data_3,
	                    s_data_4, s_data_5, s_data_6, s_data_7, s_parity, s_end, s_done);
	signal data, clk, clk1, clk2, odd, done: std_logic; 
	signal frame: std_logic_vector(7 downto 0); 
	signal state: state_type;
begin
	clk1 <= CLK_IN when rising_edge(CLK_FILTER);
	clk2 <= clk1 when rising_edge(CLK_FILTER);
	clk <= (not clk1) and clk2;
	
	data <= DATA_IN when rising_edge(CLK_FILTER);
	
	odd <= frame(0) xor frame(1) xor frame(2) xor frame(3) 
		xor frame(4) xor frame(5) xor frame(6) xor frame(7);
	
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
							state <= s_data_0;
						else
							state <= s_wait;
						end if;
					end if;
				when s_data_0 =>
					if clk = '1' then
						frame(0) <= data;
						state <= s_data_1;
					end if;
				when s_data_1 =>
					if clk = '1' then
						frame(1) <= data;
						state <= s_data_2;
					end if;
				when s_data_2 =>
					if clk = '1' then
						frame(2) <= data;
						state <= s_data_3;
					end if;
				when s_data_3 =>
					if clk = '1' then
						frame(3) <= data;
						state <= s_data_4;
					end if;
				when s_data_4 =>
					if clk = '1' then
						frame(4) <= data;
						state <= s_data_5;
					end if;
				when s_data_5 =>
					if clk = '1' then
						frame(5) <= data;
						state <= s_data_6;
					end if;
				when s_data_6 =>
					if clk = '1' then
						frame(6) <= data;
						state <= s_data_7;
					end if;
				when s_data_7 =>
					if clk = '1' then
						frame(7) <= data;
						state <= s_parity;
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
	