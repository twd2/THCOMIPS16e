library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.types.all;

entity cp0 is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        
        READ_ADDR: in cp0_addr_t;
        READ_DATA: out word_t;

        WRITE_EN: in std_logic;
        WRITE_ADDR: in cp0_addr_t;
        WRITE_DATA: in word_t;
 
        EX_READ_ADDR: in cp0_addr_t;
        EX_READ_DATA: out word_t;

        EX_BITS: out cp0_bits_t;
        
        -- mem
        MEM_WRITE_EN: in std_logic;
        MEM_WRITE_ADDR: in cp0_addr_t;
        MEM_WRITE_DATA: in word_t;
        
        EXCEPT_WRITE: in cp0_except_write_t
    );
end;

architecture behavioral of cp0 is
    signal cp0_reg, ex_cp0_reg: cp0_reg_t;
    signal read_addr_i, write_addr_i,
           mem_write_addr_i, ex_read_addr_i: integer range 0 to cp0_reg_count - 1;
begin
    read_addr_i <= to_integer(unsigned(READ_ADDR));
    write_addr_i <= to_integer(unsigned(WRITE_ADDR));
    mem_write_addr_i <= to_integer(unsigned(MEM_WRITE_ADDR));
    ex_read_addr_i <= to_integer(unsigned(EX_READ_ADDR));

    read_proc:
    process(cp0_reg, read_addr_i)
    begin
        READ_DATA <= cp0_reg(read_addr_i);
    end process;

    write_proc:
    process(CLK, RST)
    begin
        if RST = '1' then
            cp0_reg <= (others => (others => '0'));
        elsif rising_edge(CLK) then
            if WRITE_EN = '1' then
                cp0_reg(write_addr_i) <= WRITE_DATA;
            end if;
            
            -- override
            cp0_reg(cp0_addr_status)(15 downto 8) <= (others => '0');
            cp0_reg(cp0_addr_cause)(15 downto 8) <= (others => '0');
            
            if EXCEPT_WRITE.en = '1' then
                cp0_reg(cp0_addr_status)(cp0_bit_in_except_handler) <= EXCEPT_WRITE.in_except_handler;
                cp0_reg(cp0_addr_cause)(7 downto 0) <= EXCEPT_WRITE.cause;
                cp0_reg(cp0_addr_epc) <= EXCEPT_WRITE.epc;
                cp0_reg(cp0_addr_ecs) <= EXCEPT_WRITE.ecs;
            end if;
        end if;
    end process;
    
    -- for EX stage
    
    forward_proc:
    process(cp0_reg, write_addr_i, WRITE_DATA, mem_write_addr_i, MEM_WRITE_DATA)
    begin
        ex_cp0_reg <= cp0_reg;
        if WRITE_EN = '1' then
            ex_cp0_reg(write_addr_i) <= WRITE_DATA;
        end if;
        if MEM_WRITE_EN = '1' then
            ex_cp0_reg(mem_write_addr_i) <= MEM_WRITE_DATA;
        end if;

        -- override
        ex_cp0_reg(cp0_addr_status)(15 downto 8) <= (others => '0');
        ex_cp0_reg(cp0_addr_cause)(15 downto 8) <= (others => '0');
    end process;
    
    EX_BITS.interrupt_enable <= ex_cp0_reg(cp0_addr_status)(cp0_bit_interrupt_enable);
    EX_BITS.in_except_handler <= ex_cp0_reg(cp0_addr_status)(cp0_bit_in_except_handler);
    EX_BITS.interrupt_mask <= ex_cp0_reg(cp0_addr_status)(7 downto 2);
    EX_BITS.epc <= ex_cp0_reg(cp0_addr_epc);
    EX_BITS.ecs <= ex_cp0_reg(cp0_addr_ecs);
    
    EX_READ_DATA <= ex_cp0_reg(ex_read_addr_i);
end;