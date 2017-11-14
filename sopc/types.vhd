library IEEE;
use IEEE.std_logic_1164.all;

package types is
    subtype word_t is std_logic_vector(31 downto 0);
    subtype byte_mask_t is std_logic_vector(3 downto 0);
    subtype op_t is std_logic_vector(5 downto 0);
    subtype funct_t is std_logic_vector(5 downto 0);
    subtype reg_addr_t is std_logic_vector(4 downto 0);
    subtype stall_t is std_logic_vector(5 downto 0);
    type reg_file_t is array(31 downto 0) of word_t;
    
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
end;