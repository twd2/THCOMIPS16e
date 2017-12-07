library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity except_controller is
    port
    (
        RST: in std_logic;

        IF_ID_FLUSH: out std_logic;
    );
end;

architecture behavioral of except_controller is
begin
    
end;