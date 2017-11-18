library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity mips_sopc is
    port
    (
        CLK: in std_logic;
        nRST: in std_logic;

        SYSBUS_ADDR: out std_logic_vector(17 downto 0);
        SYSBUS_DQ: inout word_t;
        RAM1_nWE: out std_logic;
        RAM1_nOE: out std_logic;
        RAM1_nCE: out std_logic;
        
        EXTBUS_ADDR: out std_logic_vector(17 downto 0);
        EXTBUS_DQ: inout word_t;
        RAM2_nWE: out std_logic;
        RAM2_nOE: out std_logic;
        RAM2_nCE: out std_logic;
        
        UART_nRE: out std_logic;
        UART_READY: in std_logic;
        
        UART_nWE: out std_logic;
        UART_TBRE: in std_logic;
        UART_TSRE: in std_logic;

        testen: out std_logic;
        test_0: out reg_addr_t;
        test_1: out word_t
    );
end;

architecture behavioral of mips_sopc is
    component sysbus_controller is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
        
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t;

            SYSBUS_ADDR: out word_t;
            SYSBUS_DIN: in word_t;
            SYSBUS_DEN: out std_logic;
            SYSBUS_DOUT: out word_t;

            RAM1_nWE: out std_logic;
            RAM1_nOE: out std_logic;
            RAM1_nCE: out std_logic;

            UART_nRE: out std_logic;
            UART_READY: in std_logic;

            UART_nWE: out std_logic;
            UART_TBRE: in std_logic;
            UART_TSRE: in std_logic
        );
    end component;

    component mips_core is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            INS_BUS_REQ: out bus_request_t;
            INS_BUS_RES: in bus_response_t;
            DATA_BUS_REQ: out bus_request_t;
            DATA_BUS_RES: in bus_response_t;

            IRQ: in std_logic_vector(5 downto 0);

            testen: out std_logic;
            test_0: out reg_addr_t;
            test_1: out word_t
        );
    end component;

    component rom IS
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
    END component;

    component memory IS
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
    END component;

    signal RST: std_logic;
    
    signal SYSBUS_DIN, SYSBUS_DOUT: word_t;
    signal SYSBUS_DEN: std_logic;
    signal EXTBUS_DIN, EXTBUS_DOUT: word_t;
    signal EXTBUS_DEN: std_logic;
    
    signal ins_bus_req: bus_request_t;
    signal ins_bus_res: bus_response_t;
    signal data_bus_req: bus_request_t;
    signal data_bus_res: bus_response_t;
    signal wea: std_logic_vector(0 downto 0);
begin
    RST <= not nRST;
    
    -- TODO
    EXTBUS_ADDR <= (others => '1');

    RAM2_nWE <= '1';
    RAM2_nOE <= '1';
    RAM2_nCE <= '1';

    SYSBUS_DQ <= SYSBUS_DOUT when SYSBUS_DEN = '1' else (others => 'Z');
    SYSBUS_DIN <= SYSBUS_DQ;
    EXTBUS_DQ <= EXTBUS_DOUT when EXTBUS_DEN = '1' else (others => 'Z');
    EXTBUS_DIN <= EXTBUS_DQ;

    rom_inst: rom
    port map
    (
        addra => ins_bus_req.addr(9 downto 0),
        clka => not CLK,
        douta => ins_bus_res.data
    );

    ins_bus_res.grant <= '1';
    ins_bus_res.done <= '1';
    ins_bus_res.tlb_miss <= '0';
    ins_bus_res.page_fault <= '0';
    ins_bus_res.error <= '1' when ins_bus_req.nread_write = '1' else '0';
    
    sysbus_controller_inst: sysbus_controller
    port map
    (
        CLK => CLK,
        RST => RST,
    
        BUS_REQ => data_bus_req,
        BUS_RES => data_bus_res,

        SYSBUS_ADDR => SYSBUS_ADDR(15 downto 0),
        SYSBUS_DIN => SYSBUS_DIN,
        SYSBUS_DEN => SYSBUS_DEN,
        SYSBUS_DOUT => SYSBUS_DOUT,

        RAM1_nWE => RAM1_nWE,
        RAM1_nOE => RAM1_nOE,
        RAM1_nCE => RAM1_nCE,

        UART_nRE => UART_nRE,
        UART_READY => UART_READY,

        UART_nWE => UART_nWE,
        UART_TBRE => UART_TBRE,
        UART_TSRE => UART_TSRE
    );

    SYSBUS_ADDR(17 downto 16) <= "00"; -- TODO

    mips_core_inst: mips_core
    port map
    (
        CLK => CLK,
        RST => RST,
        
        INS_BUS_REQ => ins_bus_req,
        INS_BUS_RES => ins_bus_res,
        DATA_BUS_REQ => data_bus_req,
        DATA_BUS_RES => data_bus_res,
        
        IRQ => (others => '0'),
        
        testen => testen,
        test_0 => test_0,
        test_1 => test_1
    );
end;