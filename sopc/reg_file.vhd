library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity reg_file is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        READ_ADDR_0: in reg_addr_t;
        READ_DATA_0: out word_t;
        
        READ_ADDR_1: in reg_addr_t;
        READ_DATA_1: out word_t;
        
        WRITE_EN: in std_logic;
        WRITE_ADDR: in reg_addr_t;
        WRITE_DATA: in word_t
    );
end;

architecture behavioral of reg_file is
    signal reg: reg_file_t;

    signal write_en_real: std_logic;
    signal read_addr_0_i, read_addr_1_i, write_addr_i: integer range 0 to reg_count - 1;
begin
    read_addr_0_i <= to_integer(unsigned(READ_ADDR_0));
    read_addr_1_i <= to_integer(unsigned(READ_ADDR_1));
    write_addr_i <= to_integer(unsigned(WRITE_ADDR));

    read0_proc:
    process(reg, read_addr_0_i)
    begin
        if read_addr_0_i /= 0 or has_zero_reg = '0' then
            READ_DATA_0 <= reg(read_addr_0_i);
        else
            READ_DATA_0 <= (others => '0');
        end if;
    end process;
    
    read1_proc:
    process(reg, read_addr_1_i)
    begin
        if read_addr_1_i /= 0 or has_zero_reg = '0' then
            READ_DATA_1 <= reg(read_addr_1_i);
        else
            READ_DATA_1 <= (others => '0');
        end if;
    end process;
    
    write_en_real <= '1' when WRITE_EN = '1' and not (has_zero_reg = '1' and WRITE_ADDR = zero_reg_addr) else '0';
    
    write_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            reg <= (others => (others => '0'));
        elsif rising_edge(CLK) then
            if write_en_real = '1' then
                reg(write_addr_i) <= WRITE_DATA;
            end if;
        end if;
    end process;
end;