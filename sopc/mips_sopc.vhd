library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity mips_sopc is
    port
    (
        CLK_50M: in std_logic;
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
        
        SD_nCS: out std_logic;
        SD_SCLK: out std_logic;
        SD_MISO: in std_logic;
        SD_MOSI: out std_logic;
        
        HSYNC: out std_logic;
        VSYNC: out std_logic;
        RED: out std_logic_vector(2 downto 0);
        GREEN: out std_logic_vector(2 downto 0);
        BLUE: out std_logic_vector(2 downto 0);
        
        PS2_DATA: in std_logic;
        PS2_CLK: in std_logic;

        testen: out std_logic;
        test_0: out reg_addr_t;
        test_1: out word_t;
        
        ps2_done: out std_logic;
        ps2_frame: out std_logic_vector(7 downto 0)
    );
end;

architecture behavioral of mips_sopc is
    component clock_manager is
       port ( CLKIN_IN        : in    std_logic; 
              RST_IN          : in    std_logic; 
              CLKFX_OUT       : out   std_logic; 
              CLKFX180_OUT    : out   std_logic; 
              CLKIN_IBUFG_OUT : out   std_logic; 
              CLK0_OUT        : out   std_logic; 
              LOCKED_OUT      : out   std_logic);
    end component;
    
    component clock_4x is
       port ( CLKIN_IN        : in    std_logic; 
              RST_IN          : in    std_logic; 
              CLKFX_OUT       : out   std_logic; 
              CLKFX180_OUT    : out   std_logic;
              CLK0_OUT        : out   std_logic; 
              LOCKED_OUT      : out   std_logic);
    end component;

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
            CLK: in std_logic;
            RST: in std_logic;

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

    component sd_controller is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            BUS_REQ: out bus_request_t;
            BUS_RES: in bus_response_t;

            SD_nCS: out std_logic; -- SD_NCS, SD_DATA3_CD
            SD_SCLK: out std_logic; -- SD_CLK
            SD_MISO: in std_logic;  -- SD_DOUT, SD_DATA0_DO
            SD_MOSI: out std_logic; -- SD_DIN, SD_CMD

            DONE: out std_logic;
            REJECTED: out std_logic;
            DBG: out std_logic_vector(3 downto 0)
        );
    end component;
    
    component vga_controller is
        generic
        (
            h_active: integer := 640;
            h_front_porch: integer := 16;
            h_sync_pulse: integer := 96;
            h_back_porch: integer := 48;

            v_active: integer := 480;
            v_front_porch: integer := 10;
            v_sync_pulse: integer := 2;
            v_back_porch: integer := 33;
            
            total_char_row: integer := 30;
            total_char_col: integer := 80;
            char_width: integer := 8;
            char_height: integer := 16
        );
        port
        (
            VGA_CLK: in std_logic;
            WR_CLK: in std_logic;
            RST: in std_logic;

            -- outputs
            HSYNC: out std_logic;
            VSYNC: out std_logic;
            RED: out std_logic_vector(2 downto 0);
            GREEN: out std_logic_vector(2 downto 0);
            BLUE: out std_logic_vector(2 downto 0);

            -- bus
            GRAPHICS_BUS_REQ: out bus_request_t;
            GRAPHICS_BUS_RES: in bus_response_t;
            BASE_ADDR: in word_t
        );
    end component;
    
    component ps2_controller is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            PS2_DATA: in std_logic;
            PS2_CLK: in std_logic;
            OUTPUT_FRAME: out std_logic_vector(7 downto 0);
            DONE: out std_logic
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
    signal sd_dma_bus_req: bus_request_t;
    signal sd_dma_bus_res: bus_response_t;
    signal graphics_bus_req: bus_request_t;
    signal graphics_bus_res: bus_response_t;

    signal wea: std_logic_vector(0 downto 0);
    signal sd_dbg: std_logic_vector(3 downto 0);
    
    signal core_testen: std_logic;
    signal core_test_0: reg_addr_t;
    signal core_test_1: word_t;
    
    signal CLK, CLK_180, locked, CLK_NX, CLK_NX_180, locked_nx: std_logic;
begin
    RST <= not locked or not nRST;

    SYSBUS_DQ <= SYSBUS_DOUT when SYSBUS_DEN = '1' else (others => 'Z');
    SYSBUS_DIN <= SYSBUS_DQ;
    EXTBUS_DQ <= EXTBUS_DOUT when EXTBUS_DEN = '1' else (others => 'Z');
    EXTBUS_DIN <= EXTBUS_DQ;
    
    clock_manager_inst: clock_manager
    port map
    (
        CLKIN_IN => CLK_50M,
        RST_IN => not nRST,
        CLKFX_OUT => CLK,
        CLKFX180_OUT => CLK_180,
        --CLKIN_IBUFG_OUT
        --CLK0_OUT
        LOCKED_OUT => locked
    );
    
    clock_nx_inst: clock_4x
    port map
    (
        CLKIN_IN => CLK,
        RST_IN => not nRST,
        CLKFX_OUT => CLK_NX,
        CLKFX180_OUT => CLK_NX_180,
        --CLK0_OUT
        LOCKED_OUT => locked_nx
    );
    
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
    
    -- use external instruction memory
    extbus_interface_inst: extbus_interface
    port map
    (
        CLK => CLK,
        RST => RST,
    
        EXTBUS_ADDR => EXTBUS_ADDR(15 downto 0),
        EXTBUS_DIN => EXTBUS_DIN,
        EXTBUS_DEN => EXTBUS_DEN,
        EXTBUS_DOUT => EXTBUS_DOUT,
    
        RAM2_nWE => RAM2_nWE,
        RAM2_nOE => RAM2_nOE,
        RAM2_nCE => RAM2_nCE,
    
        BUS_REQ => extbus_req,
        BUS_RES => extbus_res
    );
    
    -- use built-in rom as instruction memory
    --rom_inst: rom
    --port map
    --(
    --    addra => extbus_req.addr(9 downto 0),
    --    clka => not CLK,
    --    douta => extbus_res.data
    --);

    --extbus_res.grant <= '1';
    --extbus_res.done <= '1';
    --extbus_res.tlb_miss <= '0';
    --extbus_res.page_fault <= '0';
    --extbus_res.error <= '1' when extbus_req.nread_write = '1' else '0';

    --RAM2_nWE <= '1';
    --RAM2_nOE <= '1';
    --RAM2_nCE <= '1';
    --EXTBUS_ADDR(15 downto 0) <= (others => '0');
    --EXTBUS_DEN <= '0';
    --EXTBUS_DOUT <= (others => 'X');
    
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
    
    sd_controller_inst: sd_controller
    port map
    (
        CLK => CLK,
        RST => RST,

        BUS_REQ => sd_dma_bus_req,
        BUS_RES => sd_dma_bus_res,

        SD_nCS => SD_nCS,
        SD_SCLK => SD_SCLK,
        SD_MISO => SD_MISO,
        SD_MOSI => SD_MOSI,

        -- DONE: out std_logic;
        -- REJECTED: out std_logic;
        DBG => sd_dbg
    );
    
    sd_dma_bus_dispatcher_inst: ins_bus_dispatcher
    port map
    (
        -- host
        BUS_REQ => sd_dma_bus_req,
        BUS_RES => sd_dma_bus_res,
        
        -- devices
        EXTBUS_REQ => extbus_req_2,
        EXTBUS_RES => extbus_res_2,
        SYSBUS_REQ => sysbus_req_2,
        SYSBUS_RES => sysbus_res_2
    );
    
    vga_controller_inst: vga_controller
    port map
    (
        VGA_CLK => CLK,
        WR_CLK => CLK,
        RST => RST,

        -- outputs
        HSYNC => HSYNC,
        VSYNC => VSYNC,
        RED => RED,
        GREEN => GREEN,
        BLUE => BLUE,

        -- bus
        GRAPHICS_BUS_REQ => graphics_bus_req,
        GRAPHICS_BUS_RES => graphics_bus_res,
        BASE_ADDR => (others => '0')
    );
    
    graphics_bus_res.data <= graphics_bus_req.addr;
    graphics_bus_res.done <= '1';
    
    ps2_controller_inst: ps2_controller
    port map
    (
        CLK => CLK,
        RST => RST,
        PS2_DATA => PS2_DATA,
        PS2_CLK => PS2_CLK,
        OUTPUT_FRAME => ps2_frame,
        DONE => ps2_done
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
        
        testen => core_testen,
        test_0 => core_test_0,
        test_1 => core_test_1
    );
    
    testen <= core_testen;
    test_0 <= core_test_0;
    test_1 <= core_test_1(15 downto 4) & sd_dbg;
end;