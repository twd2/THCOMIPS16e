library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity memory_access is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        OP: in op_t;
        FUNCT: in funct_t;
        ALU_RESULT: in word_t;
        WRITE_EN: in std_logic;
        WRITE_ADDR: in reg_addr_t;
        WRITE_DATA: in word_t;
        WRITE_MEM_DATA: in word_t;
        HI_WRITE_EN: in std_logic;
        HI_WRITE_DATA: in word_t;
        LO_WRITE_EN: in std_logic;
        LO_WRITE_DATA: in word_t;
        
        PC_O: out word_t;
        OP_O: out op_t;
        FUNCT_O: out funct_t;
        WRITE_EN_O: out std_logic;
        WRITE_ADDR_O: out reg_addr_t;
        WRITE_DATA_O: out word_t;
        HI_WRITE_EN_O: out std_logic;
        HI_WRITE_DATA_O: out word_t;
        LO_WRITE_EN_O: out std_logic;
        LO_WRITE_DATA_O: out word_t;
        
        -- bus
        BUS_REQ: out bus_request_t;
        BUS_RES: in bus_response_t
    );
end;

architecture behavioral of memory_access is
begin
    process(RST, PC, OP, FUNCT, WRITE_ADDR, WRITE_DATA, WRITE_EN, WRITE_MEM_DATA,
            BUS_RES, ALU_RESULT)
    begin
        if RST = '1' then
            STALL_REQ <= '0';
            PC_O <= (others => '0');
            OP_O <= (others => '0');
            FUNCT_O <= (others => '0');
            WRITE_EN_O <= '0';
            WRITE_ADDR_O <= (others => '0');
            WRITE_DATA_O <= (others => '0');
            HI_WRITE_EN_O <= '0';
            HI_WRITE_DATA_O <= (others => '0');
            LO_WRITE_EN_O <= '0';
            LO_WRITE_DATA_O <= (others => '0');
            BUS_REQ.addr <= (others => '0');
            BUS_REQ.data <= (others => '0');
            BUS_REQ.byte_mask <= (others => '0');
            BUS_REQ.en <= '0';
            BUS_REQ.nread_write <= '0';
        else
            STALL_REQ <= '0';
            PC_O <= PC;
            OP_O <= OP;
            FUNCT_O <= FUNCT;
            WRITE_EN_O <= WRITE_EN;
            WRITE_ADDR_O <= WRITE_ADDR;
            WRITE_DATA_O <= WRITE_DATA;
            HI_WRITE_EN_O <= HI_WRITE_EN;
            HI_WRITE_DATA_O <= HI_WRITE_DATA;
            LO_WRITE_EN_O <= LO_WRITE_EN;
            LO_WRITE_DATA_O <= LO_WRITE_DATA;
            BUS_REQ.addr <= (others => 'X');
            BUS_REQ.data <= (others => 'X');
            BUS_REQ.byte_mask <= (others => 'X');
            BUS_REQ.en <= '0';
            BUS_REQ.nread_write <= '0';
            
            case OP is
                when op_lw =>
                    BUS_REQ.addr <= ALU_RESULT;
                    BUS_REQ.byte_mask <= (others => '1');
                    BUS_REQ.en <= '1';
                    BUS_REQ.nread_write <= '0';
                    
                    STALL_REQ <= not BUS_RES.done; -- wait BUS_RES.done
                    WRITE_DATA_O <= BUS_RES.data;
                when op_sw =>
                    BUS_REQ.addr <= ALU_RESULT;
                    BUS_REQ.byte_mask <= (others => '1');
                    BUS_REQ.en <= '1';
                    BUS_REQ.nread_write <= '1';
                    BUS_REQ.data <= WRITE_MEM_DATA;
                    
                    STALL_REQ <= not BUS_RES.done; -- wait BUS_RES.done
                when others =>
            end case;
            -- TODO(twd2): check BUS_RES.tlb_miss, page_fault or error
        end if;
    end process;
end;