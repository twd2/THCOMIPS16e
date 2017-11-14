library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity reg_forward is
    port
    (
        RST: in std_logic;
        
        ID_READ_ADDR_0: in reg_addr_t;
        ID_READ_DATA_0: out word_t;
        
        ID_READ_ADDR_1: in reg_addr_t;
        ID_READ_DATA_1: out word_t;
        
        -- read from reg file
        REG_READ_ADDR_0: out reg_addr_t;
        REG_READ_DATA_0: in word_t;
        
        REG_READ_ADDR_1: out reg_addr_t;
        REG_READ_DATA_1: in word_t;
        
        -- ex
        EX_WRITE_EN: in std_logic;
        EX_WRITE_ADDR: in reg_addr_t;
        EX_WRITE_DATA: in word_t;
        
        -- mem
        MEM_WRITE_EN: in std_logic;
        MEM_WRITE_ADDR: in reg_addr_t;
        MEM_WRITE_DATA: in word_t;
        
        -- wb
        WB_WRITE_EN: in std_logic;
        WB_WRITE_ADDR: in reg_addr_t;
        WB_WRITE_DATA: in word_t
    );
end;

architecture behavioral of reg_forward is
    signal ex_write_en_real, mem_write_en_real, wb_write_en_real: std_logic;
begin
    REG_READ_ADDR_0 <= ID_READ_ADDR_0;
    REG_READ_ADDR_1 <= ID_READ_ADDR_1;
    
    ex_write_en_real <= '1' when EX_WRITE_EN = '1' and not (has_zero_reg = '1' and EX_WRITE_ADDR = zero_reg_addr) else '0';
    mem_write_en_real <= '1' when MEM_WRITE_EN = '1' and not (has_zero_reg = '1' and MEM_WRITE_ADDR = zero_reg_addr) else '0';
    wb_write_en_real <= '1' when WB_WRITE_EN = '1' and not (has_zero_reg = '1' and WB_WRITE_ADDR = zero_reg_addr) else '0';

    read0_proc:
    process(ID_READ_ADDR_0, ex_write_en_real, EX_WRITE_ADDR, EX_WRITE_DATA,
            mem_write_en_real, MEM_WRITE_ADDR, MEM_WRITE_DATA,
            wb_write_en_real, WB_WRITE_ADDR, WB_WRITE_DATA,
            REG_READ_DATA_0)
    begin
        if ex_write_en_real = '1' and ID_READ_ADDR_0 = EX_WRITE_ADDR then
            ID_READ_DATA_0 <= EX_WRITE_DATA;
        elsif mem_write_en_real = '1' and ID_READ_ADDR_0 = MEM_WRITE_ADDR then
            ID_READ_DATA_0 <= MEM_WRITE_DATA;
        elsif wb_write_en_real = '1' and ID_READ_ADDR_0 = WB_WRITE_ADDR then
            ID_READ_DATA_0 <= WB_WRITE_DATA;
        else
            ID_READ_DATA_0 <= REG_READ_DATA_0;
        end if;
    end process;
    
    read1_proc:
    process(ID_READ_ADDR_1, ex_write_en_real, EX_WRITE_ADDR, EX_WRITE_DATA,
            mem_write_en_real, MEM_WRITE_ADDR, MEM_WRITE_DATA,
            wb_write_en_real, WB_WRITE_ADDR, WB_WRITE_DATA,
            REG_READ_DATA_1)
    begin
        if ex_write_en_real = '1' and ID_READ_ADDR_1 = EX_WRITE_ADDR then
            ID_READ_DATA_1 <= EX_WRITE_DATA;
        elsif mem_write_en_real = '1' and ID_READ_ADDR_1 = MEM_WRITE_ADDR then
            ID_READ_DATA_1 <= MEM_WRITE_DATA;
        elsif wb_write_en_real = '1' and ID_READ_ADDR_1 = WB_WRITE_ADDR then
            ID_READ_DATA_1 <= WB_WRITE_DATA;
        else
            ID_READ_DATA_1 <= REG_READ_DATA_1;
        end if;
    end process;
end;