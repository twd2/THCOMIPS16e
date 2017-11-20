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
        
        GPIO: inout word_t;

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
    
    component extbus_interface is
        port
        (
            EXTBUS_ADDR: out word_t;
            EXTBUS_DIN: in word_t;
            EXTBUS_DEN: out std_logic;
            EXTBUS_DOUT: out word_t;

            RAM2_nWE: out std_logic;
            RAM2_nOE: out std_logic;
            RAM2_nCE: out std_logic;
            
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t
        );
    end component;
    
    component gpio_controller is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
        
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t;

            GPIO: inout word_t
        );
    end component;
    
    component ins_bus_dispatcher is
        port
        (
            -- host
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t;
            
            -- devices
            EXTBUS_REQ: out bus_request_t;
            EXTBUS_RES: in bus_response_t;
            SYSBUS_REQ: out bus_request_t;
            SYSBUS_RES: in bus_response_t
        );
    end component;
    
    component data_bus_dispatcher is
        port
        (
            -- host
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t;
            
            -- devices
            EXTBUS_REQ: out bus_request_t;
            EXTBUS_RES: in bus_response_t;
            SYSBUS_REQ: out bus_request_t;
            SYSBUS_RES: in bus_response_t;
            DEVBUS_REQ: out bus_request_t;
            DEVBUS_RES: in bus_response_t
        );
    end component;
    
    component device_bus_dispatcher is
        port
        (
            -- host
            BUS_REQ: in bus_request_t;
            BUS_RES: out bus_response_t;
            
            -- devices
            GPIO_BUS_REQ: out bus_request_t;
            GPIO_BUS_RES: in bus_response_t
        );
    end component;

    component bus_arbiter is
        port
        (
            -- hosts (2 > 1 > 0)
            BUS_REQ_0: in bus_request_t;
            BUS_RES_0: out bus_response_t;
            BUS_REQ_1: in bus_request_t;
            BUS_RES_1: out bus_response_t;
            BUS_REQ_2: in bus_request_t;
            BUS_RES_2: out bus_response_t;
            
            -- device
            BUS_REQ: out bus_request_t;
            BUS_RES: in bus_response_t
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

    signal sysbus_req: bus_request_t;
    signal sysbus_res: bus_response_t;
    signal extbus_req: bus_request_t;
    signal extbus_res: bus_response_t;
    signal sysbus_req_0: bus_request_t;
    signal sysbus_res_0: bus_response_t;
    signal sysbus_req_1: bus_request_t;
    signal sysbus_res_1: bus_response_t;
    signal sysbus_req_2: bus_request_t;
    signal sysbus_res_2: bus_response_t;
    signal extbus_req_0: bus_request_t;
    signal extbus_res_0: bus_response_t;
    signal extbus_req_1: bus_request_t;
    signal extbus_res_1: bus_response_t;
    signal extbus_req_2: bus_request_t;
    signal extbus_res_2: bus_response_t;
    signal devbus_req: bus_request_t;
    signal devbus_res: bus_response_t;
    
    signal gpio_bus_req: bus_request_t;
    signal gpio_bus_res: bus_response_t;

    signal wea: std_logic_vector(0 downto 0);
begin
    RST <= not nRST;

    SYSBUS_DQ <= SYSBUS_DOUT when SYSBUS_DEN = '1' else (others => 'Z');
    SYSBUS_DIN <= SYSBUS_DQ;
    EXTBUS_DQ <= EXTBUS_DOUT when EXTBUS_DEN = '1' else (others => 'Z');
    EXTBUS_DIN <= EXTBUS_DQ;
    
    sysbus_controller_inst: sysbus_controller
    port map
    (
        CLK => CLK,
        RST => RST,
    
        BUS_REQ => sysbus_req,
        BUS_RES => sysbus_res,

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
    
    rom_inst: rom
    port map
    (
        addra => extbus_req.addr(9 downto 0),
        clka => not CLK,
        douta => extbus_res.data
    );

    extbus_res.grant <= '1';
    extbus_res.done <= '1';
    extbus_res.tlb_miss <= '0';
    extbus_res.page_fault <= '0';
    extbus_res.error <= '1' when extbus_req.nread_write = '1' else '0';
    
    --extbus_interface_inst: extbus_interface
    --port map
    --(
    --    EXTBUS_ADDR => EXTBUS_ADDR(15 downto 0),
    --    EXTBUS_DIN => EXTBUS_DIN,
    --    EXTBUS_DEN => EXTBUS_DEN,
    --    EXTBUS_DOUT => EXTBUS_DOUT,
    --
    --    RAM2_nWE => RAM2_nWE,
    --    RAM2_nOE => RAM2_nOE,
    --    RAM2_nCE => RAM2_nCE,
    --
    --    BUS_REQ => extbus_req,
    --    BUS_RES => extbus_res
    --);
    
    RAM2_nWE <= '1';
    RAM2_nOE <= '1';
    RAM2_nCE <= '1';
    EXTBUS_ADDR(15 downto 0) <= (others => '0');
    EXTBUS_DEN <= '0';
    EXTBUS_DOUT <= (others => 'X');
    
    EXTBUS_ADDR(17 downto 16) <= "00"; -- TODO
    
    gpio_controller_inst: gpio_controller
    port map
    (
        CLK => CLK,
        RST => RST,
    
        BUS_REQ => gpio_bus_req,
        BUS_RES => gpio_bus_res,

        GPIO => GPIO
    );

    ins_bus_dispatcher_inst: ins_bus_dispatcher
    port map
    (
        -- host
        BUS_REQ => ins_bus_req,
        BUS_RES => ins_bus_res,
        
        -- devices
        EXTBUS_REQ => extbus_req_0,
        EXTBUS_RES => extbus_res_0,
        SYSBUS_REQ => sysbus_req_0,
        SYSBUS_RES => sysbus_res_0
    );

    data_bus_dispatcher_inst: data_bus_dispatcher
    port map
    (
        -- host
        BUS_REQ => data_bus_req,
        BUS_RES => data_bus_res,

        -- devices
        EXTBUS_REQ => extbus_req_1,
        EXTBUS_RES => extbus_res_1,
        SYSBUS_REQ => sysbus_req_1,
        SYSBUS_RES => sysbus_res_1,
        DEVBUS_REQ => devbus_req,
        DEVBUS_RES => devbus_res
    );
    
    device_bus_dispatcher_inst: device_bus_dispatcher
    port map
    (
        -- host
        BUS_REQ => devbus_req,
        BUS_RES => devbus_res,
        
        -- devices
        GPIO_BUS_REQ => gpio_bus_req,
        GPIO_BUS_RES => gpio_bus_res
    );
    
    extbus_arbiter: bus_arbiter
    port map
    (
        -- hosts (2 > 1 > 0)
        BUS_REQ_0 => extbus_req_0,
        BUS_RES_0 => extbus_res_0,
        BUS_REQ_1 => extbus_req_1,
        BUS_RES_1 => extbus_res_1,
        BUS_REQ_2 => extbus_req_2,
        BUS_RES_2 => extbus_res_2,
        
        -- device
        BUS_REQ => extbus_req,
        BUS_RES => extbus_res
    );
    
    sysbus_arbiter: bus_arbiter
    port map
    (
        -- hosts (2 > 1 > 0)
        BUS_REQ_0 => sysbus_req_0,
        BUS_RES_0 => sysbus_res_0,
        BUS_REQ_1 => sysbus_req_1,
        BUS_RES_1 => sysbus_res_1,
        BUS_REQ_2 => sysbus_req_2,
        BUS_RES_2 => sysbus_res_2,
        
        -- device
        BUS_REQ => sysbus_req,
        BUS_RES => sysbus_res
    );

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