library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity vga_color is
    port
    (
        color_id: in std_logic_vector(7 downto 0);
        fore_color: out std_logic_vector(15 downto 0);
        back_color: out std_logic_vector(15 downto 0)
    );
end;

architecture behavioral of vga_color is
begin
    process(color_id)
    begin
        case color_id(3 downto 0) is
            when x"0" =>
                fore_color <= "00000" & "000000" & "00000";
            when x"1" =>
                fore_color <= "00000" & "000000" & "10101";
            when x"2" =>
                fore_color <= "00000" & "101010" & "00000";
            when x"3" =>
                fore_color <= "00000" & "101010" & "10101";
            when x"4" =>
                fore_color <= "10101" & "000000" & "00000";
            when x"5" =>
                fore_color <= "10101" & "000000" & "10101";
            when x"6" =>
                fore_color <= "10101" & "010101" & "00000";
            when x"7" =>
                fore_color <= "10101" & "101010" & "10101";
            when x"8" =>
                fore_color <= "01010" & "010101" & "01010";
            when x"9" =>
                fore_color <= "01010" & "010101" & "11111";
            when x"A" =>
                fore_color <= "01010" & "111111" & "01010";
            when x"B" =>
                fore_color <= "01010" & "111111" & "11111";
            when x"C" =>
                fore_color <= "11111" & "010101" & "01010";
            when x"D" =>
                fore_color <= "11111" & "010101" & "11111";
            when x"E" =>
                fore_color <= "11111" & "111111" & "01010";
            when x"F" =>
                fore_color <= "11111" & "111111" & "11111";
            when others =>
                fore_color <= "10101" & "101010" & "10101";
        end case;
    end process;
    
    process(color_id)
    begin
        case color_id(7 downto 4) is
            when x"0" =>
                back_color <= "00000" & "000000" & "00000";
            when x"1" =>
                back_color <= "00000" & "000000" & "10101";
            when x"2" =>
                back_color <= "00000" & "101010" & "00000";
            when x"3" =>
                back_color <= "00000" & "101010" & "10101";
            when x"4" =>
                back_color <= "10101" & "000000" & "00000";
            when x"5" =>
                back_color <= "10101" & "000000" & "10101";
            when x"6" =>
                back_color <= "10101" & "010101" & "00000";
            when x"7" =>
                back_color <= "10101" & "101010" & "10101";
            when x"8" =>
                back_color <= "01010" & "010101" & "01010";
            when x"9" =>
                back_color <= "01010" & "010101" & "11111";
            when x"A" =>
                back_color <= "01010" & "111111" & "01010";
            when x"B" =>
                back_color <= "01010" & "111111" & "11111";
            when x"C" =>
                back_color <= "11111" & "010101" & "01010";
            when x"D" =>
                back_color <= "11111" & "010101" & "11111";
            when x"E" =>
                back_color <= "11111" & "111111" & "01010";
            when x"F" =>
                back_color <= "11111" & "111111" & "11111";
            when others =>
                back_color <= "10101" & "101010" & "10101";
        end case;
    end process;
end;