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
    subtype cp0_addr_t is std_logic_vector(2 downto 0);
    type cp0_reg_t is array(cp0_reg_count - 1 downto 0) of word_t;
    subtype except_type_t is std_logic_vector(7 downto 0);
    
    type bus_request_t is record -- output for host, input for device
        addr: word_t;
        data: word_t;
        byte_mask: byte_mask_t;
        en: std_logic;
        nread_write: std_logic;
        is_uart_data: std_logic; -- to improve timing
        is_uart_control: std_logic;
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
        is_in_delay_slot: std_logic;
    end record;
    
    type ex_signal_t is record
        cp0_read_en: std_logic;
        cp0_read_addr: cp0_addr_t;
        alu_op: alu_op_t;
        operand_0: word_t;
        operand_1: word_t;
    end record;
    
    type mem_signal_t is record
        alu_result: word_t;
        mem_en: std_logic;
        mem_write_en: std_logic;
        sw_after_load: std_logic;
        write_mem_data: word_t;
        is_uart_data: std_logic; -- to improve timing
        is_uart_control: std_logic;
        except_type: except_type_t;
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
        ds_write_en: std_logic;
        ds_write_data: word_t;
        cp0_write_en: std_logic;
        cp0_write_addr: cp0_addr_t;
        cp0_write_data: word_t;
    end record;
    
    type font_task_t is record
        valid: std_logic;
        char_id: std_logic_vector(11 downto 0);
        char_x: std_logic_vector(2 downto 0);
        char_y: std_logic_vector(3 downto 0);
        char_col: std_logic_vector(7 downto 0);
        char_row: std_logic_vector(7 downto 0);
        colored_char: word_t;
        color: word_t;
    end record;

    type tasks_t is array(integer range <>) of font_task_t;

    type cp0_bits_t is record
        interrupt_enable: std_logic; -- interrupt enable
        in_except_handler: std_logic;
        interrupt_mask: std_logic_vector(5 downto 0); -- '1' disables interrupt
        epc: word_t;
        ecs: word_t;
    end record;

    type cp0_except_write_t is record
        en: std_logic;
        in_except_handler: std_logic;
        cause: except_type_t;
        epc: word_t;
        ecs: word_t;
    end record;
end;