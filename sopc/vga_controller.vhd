library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
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

        -- graphics memory bus
        GRAPHICS_BUS_REQ: out bus_request_t;
        GRAPHICS_BUS_RES: in bus_response_t;
        
        -- control bus 
        BUS_REQ: in bus_request_t;
        BUS_RES: out bus_response_t
    );
end;

architecture behavorial of vga_controller is
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
    
    COMPONENT font_rom IS
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
    
    component vga_color is
        port
        (
            color_id: in std_logic_vector(7 downto 0);
            fore_color: out std_logic_vector(15 downto 0);
            back_color: out std_logic_vector(15 downto 0)
        );
    end component;

    constant h_whole: integer := h_active + h_front_porch + h_sync_pulse + h_back_porch;
    constant v_whole: integer := v_active + v_front_porch + v_sync_pulse + v_back_porch;
    signal next_x: std_logic_vector(12 downto 0);
    signal next_y: std_logic_vector(12 downto 0);
    signal data: std_logic_vector(8 downto 0);
    signal h_counter: std_logic_vector(12 downto 0);
    signal v_counter: std_logic_vector(12 downto 0);
    signal done_buffer: std_logic_vector(1 downto 0);
    signal next_en, sync: std_logic;
    signal full, almost_full, empty, almost_empty: std_logic;
    signal next_read_addr: word_t;
    signal done: std_logic;
    signal wr_rst, wr_en: std_logic;
    signal char_row, char_col: std_logic_vector(7 downto 0);
    signal char_x: std_logic_vector(2 downto 0);
    signal char_y: std_logic_vector(3 downto 0);
    signal char_id: std_logic_vector(11 downto 0);

    signal pipeline_en: std_logic;
    signal font_addr: std_logic_vector(11 downto 0);
    signal font_pixel: std_logic;
    signal font_row: std_logic_vector(7 downto 0);
    signal font_fore_color: std_logic_vector(15 downto 0);
    signal font_back_color: std_logic_vector(15 downto 0);
    signal tasks: tasks_t(1 downto 0);
    
    -- registers
    signal base_addr_hi, base_addr, cursor_pos, cursor_counter_limit: word_t;
    signal show_cursor_buff: std_logic_vector(1 downto 0);
    signal at_cursor: std_logic;
    
    signal show_cursor: std_logic;
    signal cursor_counter, cursor_counter_limit_buff1, cursor_counter_limit_buff2: word_t;
begin
    wr_rst <= RST or sync;

    fifo_ins : fifo
      PORT MAP (
        rst => wr_rst,
        wr_clk => WR_CLK,
        rd_clk => VGA_CLK,
        din => tasks(1).color(8 downto 0),
        wr_en => tasks(1).valid,
        rd_en => next_en,
        dout => data,
        full => full,
        almost_full => almost_full,
        empty => empty,
        almost_empty => almost_empty
      );

    ------------------------------- clock domain VGA_CLK ------------------------------------
    next_en <= '1' when (next_x < h_active) and (next_y < v_active) and RST = '0' else '0';
    
    -- starts at h_active and v_active
    HSYNC <= '0' when (h_counter >= h_active + h_front_porch) and (h_counter < h_active + h_front_porch + h_sync_pulse) else '1';
    VSYNC <= '0' when (v_counter >= v_active + v_front_porch) and (v_counter < v_active + v_front_porch + v_sync_pulse) else '1';

    -- next (x, y)
    process(h_counter, v_counter)
    begin
        if h_counter = h_whole - 1 then -- new line
            next_x <= (others => '0');
            if v_counter = v_whole - 1 then -- new scene
                next_y <= (others => '0');
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
            h_counter <= (others => '0');
            v_counter <= (others => '0');
            RED <= (others => '0');
            GREEN <= (others => '0');
            BLUE <= (others => '0');
            
            cursor_counter_limit_buff1 <= (others => '0');
            cursor_counter_limit_buff2 <= (others => '0');
            show_cursor <= '0';
        elsif rising_edge(VGA_CLK) then
            h_counter <= next_x;
            v_counter <= next_y;
            if next_en = '1' then
                RED <= data(8 downto 6);
                GREEN <= data(5 downto 3);
                BLUE <= data(2 downto 0);
            else
                RED <= (others => '0');
                GREEN <= (others => '0');
                BLUE <= (others => '0');
            end if;
            
            -- sample cursor_counter_limit from clock domain WR_CLK
            cursor_counter_limit_buff1 <= cursor_counter_limit;
            cursor_counter_limit_buff2 <= cursor_counter_limit_buff1;
            
            if next_x = "0" & x"000" and next_y = "0" & x"000" then
                if cursor_counter >= cursor_counter_limit_buff2 then
                    cursor_counter <= (others => '0');
                    show_cursor <= not show_cursor;
                else
                    cursor_counter <= cursor_counter + 1;
                end if;
            end if;
            
            if cursor_counter_limit_buff2 = x"0000" then
                show_cursor <= '0';
            elsif cursor_counter_limit_buff2 = x"ffff" then
                show_cursor <= '1';
            end if;
        end if;
    end process;
    
    done <= '1' when next_y >= v_active else '0';
    
    ------------------------------- clock domain WR_CLK ------------------------------------

    -- prefetch
    pipeline_en <= GRAPHICS_BUS_RES.done and not almost_full;
    GRAPHICS_BUS_REQ.en <= not almost_full;
    GRAPHICS_BUS_REQ.nread_write <= '0';

    process(WR_CLK, wr_rst)
    begin
        if wr_rst = '1' then
            char_id <= (others => '0');
            char_row <= (others => '0');
            char_col <= (others => '0');
            char_x <= (others => '0');
            char_y <= (others => '0');
        elsif rising_edge(WR_CLK) then
            if pipeline_en = '1' then
                if char_x = char_width - 1 then
                    if char_col = total_char_col - 1 then
                        if char_y = char_height - 1 then
                            if char_row = total_char_row - 1 then
                                char_id <= (others => '0');
                                char_row <= (others => '0');
                            else
                                char_id <= char_id + 1;
                                char_row <= char_row + 1;
                            end if;
                            char_y <= (others => '0');
                        else
                            char_y <= char_y + 1;
                            char_id <= char_id + (1 - total_char_col);
                        end if;
                        char_col <= (others => '0');
                    else
                        char_col <= char_col + 1;
                        char_id <= char_id + 1;
                    end if;
                    char_x <= (others => '0');
                else
                    char_x <= char_x + 1;
                end if;
            end if;
        end if;
    end process;

    -- get sync
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
    
    -- pipeline to convert char to color
    
    -- read char at (char_x, char_y)
    process(WR_CLK, wr_rst)
    begin
        if wr_rst = '1' then
            tasks(0).valid <= '0';
            tasks(0).char_id <= (others => '0');
            tasks(0).char_x <= (others => '0');
            tasks(0).char_y <= (others => '0');
            tasks(0).char_col <= (others => '0');
            tasks(0).char_row <= (others => '0');
            tasks(0).color <= (others => '0');
        elsif rising_edge(WR_CLK) then
            if pipeline_en = '1' then
                tasks(0).valid <= '1';
                tasks(0).char_id <= char_id;
                tasks(0).char_x <= char_x;
                tasks(0).char_y <= char_y;
                tasks(0).char_col <= char_col;
                tasks(0).char_row <= char_row;
            end if;
        end if;
    end process;
    
    GRAPHICS_BUS_REQ.addr <= (3 downto 0 => '0') & tasks(0).char_id;
    tasks(0).colored_char <= GRAPHICS_BUS_RES.data;
    
    -- convert char to color
    process(WR_CLK, wr_rst)
    begin
        if wr_rst = '1' then
            tasks(1).valid <= '0';
            tasks(1).char_id <= (others => '0');
            tasks(1).char_x <= (others => '0');
            tasks(1).char_y <= (others => '0');
            tasks(1).char_col <= (others => '0');
            tasks(1).char_row <= (others => '0');
            tasks(1).colored_char <= (others => '0');
        elsif rising_edge(WR_CLK) then
            if pipeline_en = '1' then
                tasks(1).valid <= tasks(0).valid;
            else
                tasks(1).valid <= '0';
            end if;
            tasks(1).char_id <= tasks(0).char_id;
            tasks(1).char_x <= tasks(0).char_x;
            tasks(1).char_y <= tasks(0).char_y;
            tasks(1).char_col <= tasks(0).char_col;
            tasks(1).char_row <= tasks(0).char_row;
            tasks(1).colored_char <= tasks(0).colored_char;
        end if;
    end process;
    
    font_addr <= tasks(1).colored_char(7 downto 0) & tasks(1).char_y;
    
    font_rom_inst: font_rom
    port map
    (
        clka => not WR_CLK,
        addra => font_addr,
        douta => font_row
    );
    
    font_pixel <= font_row(conv_integer(unsigned(tasks(1).char_x)));
    
    vga_color_inst: vga_color
    port map
    (
        color_id => tasks(1).colored_char(15 downto 8),
        fore_color => font_fore_color,
        back_color => font_back_color
    );

    -- sample show_cursor from clock domain VGA_CLK
    process(WR_CLK, RST)
    begin
        if RST = '1' then
            show_cursor_buff <= (others => '0');
        elsif rising_edge(WR_CLK) then
            show_cursor_buff <= show_cursor_buff(0) & show_cursor;
        end if;
    end process;

    process(tasks)
    begin
        if (tasks(1).char_col = cursor_pos(7 downto 0)) and (tasks(1).char_row = cursor_pos(15 downto 8)) then
            at_cursor <= show_cursor_buff(1);
        else
            at_cursor <= '0';
        end if;
    end process;

    process(tasks)
    begin
        if (font_pixel xor at_cursor) = '1' then
            tasks(1).color <= "0000000" & font_fore_color(15 downto 13) & font_fore_color(10 downto 8) & font_fore_color(4 downto 2);
        else
            tasks(1).color <= "0000000" & font_back_color(15 downto 13) & font_back_color(10 downto 8) & font_back_color(4 downto 2);
        end if;
    end process;
    
    -- registers
    
    BUS_RES.grant <= '1';
    BUS_RES.done <= '1';
    BUS_RES.tlb_miss <= '0';
    BUS_RES.page_fault <= '0';
    BUS_RES.error <= '0';
    
    read_proc:
    process(BUS_REQ, base_addr, base_addr_hi, cursor_pos, cursor_counter_limit)
    begin
        case BUS_REQ.addr(1 downto 0) is
            when "00" =>
                BUS_RES.data <= base_addr;
            when "01" =>
                BUS_RES.data <= base_addr_hi;
            when "10" =>
                BUS_RES.data <= cursor_pos;
            when "11" =>
                BUS_RES.data <= cursor_counter_limit;
            when others =>
                BUS_RES.data <= (others => 'X');
        end case;
    end process;

    write_proc:
    process(WR_CLK, RST)
    begin
        if RST = '1' then
            base_addr <= (others => '0');
            base_addr_hi <= (others => '0');
            cursor_pos <= (others => '0');
            cursor_counter_limit <= x"001D";
        elsif rising_edge(WR_CLK) then
            if BUS_REQ.en = '1' and BUS_REQ.nread_write = '1' then
                case BUS_REQ.addr(1 downto 0) is
                    when "00" =>
                        base_addr <= BUS_REQ.data;
                    when "01" =>
                        base_addr_hi <= BUS_REQ.data;
                    when "10" =>
                        cursor_pos <= BUS_REQ.data;
                    when "11" =>
                        cursor_counter_limit <= BUS_REQ.data;
                    when others =>
                end case;
            end if;
        end if;
    end process;
end;