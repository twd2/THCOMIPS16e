library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

package types is
    subtype word_t is std_logic_vector(word_length - 1 downto 0);
    subtype byte_mask_t is std_logic_vector(1 downto 0);
    subtype op_t is std_logic_vector(4 downto 0);
    subtype funct_t is std_logic_vector(5 downto 0);
    subtype reg_addr_t is std_logic_vector(2 downto 0);
    subtype stall_t is std_logic_vector(5 downto 0);
    type reg_file_t is array(reg_count - 1 downto 0) of word_t;
    
    type bus_request_t is record -- output for host, input for device
        addr: word_t;
        data: word_t;
        byte_mask: byte_mask_t;
        en: std_logic;
        nread_write: std_logic;
    end record;

    type bus_response_t is record -- input for host, output for device
        data: word_t;
        grant: std_logic;
        done: std_logic;
        tlb_miss: std_logic;
        page_fault: std_logic;
        error: std_logic; -- other error
    end record;
    
    type common_signal_t is record
        pc: word_t;
        op: op_t;
        funct: funct_t;
    end record;
    
    type ex_signal_t is record
        alu_op: alu_op_t;
        operand_0: word_t;
        operand_1: word_t;
    end record;
    
    type mem_signal_t is record
        alu_result: word_t;
        mem_en: std_logic;
        mem_write_en: std_logic;
        write_mem_data: word_t;
    end record;
    
    type wb_signal_t is record
        write_en: std_logic;
        write_addr: reg_addr_t;
        write_data: word_t;
        hi_write_en: std_logic;
        hi_write_data: word_t;
        lo_write_en: std_logic;
        lo_write_data: word_t;
        t_write_en: std_logic;
        t_write_data: std_logic;
        sp_write_en: std_logic;
        sp_write_data: word_t;
    end record;
end;