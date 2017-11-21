library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.constants.all;
use work.types.all;

entity vga_controller is
    generic
    (
        h_active: integer := 640;
        h_front_porch: integer := 16;
        h_sync_pulse: integer := 96;
        h_back_porch: integer := 48;

        v_active: integer := 480;
        v_front_porch: integer := 10;
        v_sync_pulse: integer := 2;
        v_back_porch: integer := 33
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
        BUS_REQ: out bus_request_t;
        BUS_RES: in bus_response_t;
        BASE_ADDR: in word_t
    );
end;

architecture behavorial of vga_controller is
    constant h_whole: integer := h_active + h_front_porch + h_sync_pulse + h_back_porch;
    constant v_whole: integer := v_active + v_front_porch + v_sync_pulse + v_back_porch;
    signal next_x: std_logic_vector(12 downto 0);
    signal next_y: std_logic_vector(12 downto 0);
    signal data: std_logic_vector(8 downto 0);
    signal h_counter: std_logic_vector(12 downto 0);
    signal v_counter: std_logic_vector(12 downto 0);
    signal done_buffer: std_logic_vector(1 downto 0);
    signal next_en, req_en, sync: std_logic;
    signal full, almost_full, empty, almost_empty: std_logic;
    signal next_read_addr: word_t;
    
    COMPONENT fifo
      PORT (
        rst : IN STD_LOGIC;
        wr_clk : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        full : OUT STD_LOGIC;
        almost_full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC;
        almost_empty : OUT STD_LOGIC
      );
    END COMPONENT;

begin
    fifo_ins : fifo
      PORT MAP (
        rst => RST or sync,
        wr_clk => WR_CLK,
        rd_clk => VGA_CLK,
        din => BUS_RES.data(8 downto 0),
        wr_en => BUS_RES.done and req_en,
        rd_en => next_en,
        dout => data,
        full => full,
        almost_full => almost_full,
        empty => empty,
        almost_empty => almost_empty
      );

    next_en <= '1' when (next_x < h_active) and (next_y < v_active) and RST = '0' else '0';
    
    -- starts at h_active and v_active
    HSYNC <= '0' when (h_counter >= h_active + h_front_porch) and (h_counter < h_active + h_front_porch + h_sync_pulse) else '1';
    VSYNC <= '0' when (v_counter >= v_active + v_front_porch) and (v_counter < v_active + v_front_porch + v_sync_pulse) else '1';

    -- next (x, y)
    process(h_counter, v_counter)
    begin
        if h_counter = h_whole - 1 then -- new line
            next_x <= conv_std_logic_vector(0, h_counter'length);
            if v_counter = v_whole - 1 then -- new scene
                next_y <= conv_std_logic_vector(0, v_counter'length);
            else
                next_y <= v_counter + 1;
            end if;
        else
            next_x <= h_counter + 1;
            next_y <= v_counter;
        end if;
    end process;

    process(VGA_CLK, RST)
    begin
        if RST = '1' then
            h_counter <= conv_std_logic_vector(0, h_counter'length);
            v_counter <= conv_std_logic_vector(0, v_counter'length);
            RED <= "000";
            GREEN <= "000";
            BLUE <= "000";
        else
            if rising_edge(VGA_CLK) then
                h_counter <= next_x;
                v_counter <= next_y;
                if next_en = '1' then
                    RED <= data(8 downto 6);
                    GREEN <= data(5 downto 3);
                    BLUE <= data(2 downto 0);
                else
                    RED <= "000";
                    GREEN <= "000";
                    BLUE <= "000";
                end if;
            end if;
        end if;
    end process;

    -- prefetch
    DONE <= '1' when next_y >= v_active else '0';
    req_en <= not almost_full and not RST;
    BUS_REQ.en <= req_en;
    BUS_REQ.nread_write <= '0';
    BUS_REQ.addr <= next_read_addr;

    process(WR_CLK, RST, sync)
    begin
        if RST = '1' or sync = '1' then
            next_read_addr <= BASE_ADDR;
        else
            if rising_edge(WR_CLK) then
                done_buffer[0] <= done;
                done_buffer[1] <= done_buffer[0];
                if BUS_RES.done = '1' and req_en then
                    if next_read_addr = BASE_ADDR + h_active * v_active - 1 then
                        next_read_addr <= BASE_ADDR;
                    else 
                        next_read_addr <= next_read_addr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(WR_CLK, RST)
    begin
        if RST = '1' then
            done_buffer <= "00";
            sync <= '0';
        elsif rising_edge(WR_CLK) then
            done_buffer(0) <= done;
            done_buffer(1) <= done_buffer(0);
            sync <= done_buffer(0) and not done_buffer(1);
        end if;
    end process;
end;