library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity instruction_decode is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        PC: in word_t;
        INS: in word_t;
        
        -- reg file
        READ_ADDR_0: out reg_addr_t;
        READ_DATA_0: in word_t;
        
        READ_ADDR_1: out reg_addr_t;
        READ_DATA_1: in word_t;
        
        T: in std_logic;
        SP: in word_t;
        DS: in word_t;
        
        COMMON: out common_signal_t;
        EX: out ex_signal_t;
        MEM: out mem_signal_t;
        WB: out wb_signal_t;

        IS_LOAD: out std_logic;
        
        EX_IS_LOAD: in std_logic;
        EX_WRITE_ADDR: in reg_addr_t;
        
        BRANCH_EN: out std_logic;
        BRANCH_PC: out word_t;
        
        IS_IN_DELAY_SLOT: in std_logic
    );
end;

architecture behavioral of instruction_decode is
    signal rx, ry, rz: reg_addr_t;
    signal shamt_buff: word_t;
    signal op_buff: op_t;
    signal imm4se, imm5se, imm8se, imm8ze, imm11se: word_t;
    signal cp0_addr: cp0_addr_t;
    
    signal read_addr_0_buff, read_addr_1_buff: reg_addr_t;
    signal read_en_0_buff, read_en_1_buff: std_logic;
    
    signal store_after_load_buff: std_logic;
    
    -- for branch instrutions
    signal reg_0_eq_0: std_logic;
    signal b_pc, cb_pc: word_t;
begin
    op_buff <= INS(15 downto 11);
    rx <= INS(10 downto 8);
    ry <= INS(7 downto 5);
    rz <= INS(4 downto 2);
    cp0_addr <= INS(7 downto 5);
    
    process(INS)
    begin
        if INS(4 downto 2) = "000" then
            shamt_buff <= (11 downto 0 => '0') & x"8";
        else
            shamt_buff <= (11 downto 0 => '0') & "0" & INS(4 downto 2);
        end if;
    end process;
    
    imm4se <= (11 downto 0 => INS(3)) & INS(3 downto 0);
    imm5se <= (10 downto 0 => INS(4)) & INS(4 downto 0);
    imm8se <= (7 downto 0 => INS(7)) & INS(7 downto 0);
    imm8ze <= (7 downto 0 => '0') & INS(7 downto 0);
    imm11se <= (4 downto 0 => INS(10)) & INS(10 downto 0);

    reg_0_eq_0 <= '1' when READ_DATA_0 = zero_word else '0';
    
    b_pc <= PC + imm11se;
    cb_pc <= PC + imm8se;
    
    READ_ADDR_0 <= read_addr_0_buff;
    READ_ADDR_1 <= read_addr_1_buff;
    
    process(RST, INS, op_buff, rx, ry, rz, PC, READ_DATA_0, READ_DATA_1, T, SP, DS,
            reg_0_eq_0, store_after_load_buff,
            imm4se, imm5se, imm8se, imm8ze, imm11se,
            cp0_addr)
    begin
        if RST = '1' then
            read_addr_0_buff <= (others => '0');
            read_addr_1_buff <= (others => '0');
            read_en_0_buff <= '0';
            read_en_1_buff <= '0';
            COMMON.pc <= (others => '0');
            COMMON.op <= (others => '0');
            COMMON.funct <= (others => '0');
            COMMON.is_in_delay_slot <= '0';
            EX.cp0_read_en <= '0';
            EX.cp0_read_addr <= (others => '0');
            EX.alu_op <= alu_nop;
            EX.operand_0 <= (others => '0');
            EX.operand_1 <= (others => '0');
            MEM.alu_result <= (others => '0');
            MEM.mem_en <= '0';
            MEM.mem_write_en <= '0';
            MEM.write_mem_data <= (others => '0');
            MEM.sw_after_load <= '0';
            MEM.is_uart_data <= '0';
            MEM.is_uart_control <= '0';
            MEM.except_type <= except_none;
            WB.write_en <= '0';
            WB.write_addr <= (others => '0');
            WB.write_data <= (others => '0');
            WB.hi_write_en <= '0';
            WB.hi_write_data <= (others => '0');
            WB.lo_write_en <= '0';
            WB.lo_write_data <= (others => '0');
            WB.t_write_en <= '0';
            WB.t_write_data <= '0';
            WB.sp_write_en <= '0';
            WB.sp_write_data <= (others => '0');
            WB.ds_write_en <= '0';
            WB.ds_write_data <= (others => '0');
            WB.cp0_write_en <= '0';
            WB.cp0_write_addr <= (others => '0');
            WB.cp0_write_data <= (others => '0');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => '0');
            IS_LOAD <= '0';
        else
            read_addr_0_buff <= rx;
            read_addr_1_buff <= ry;
            read_en_0_buff <= '1';
            read_en_1_buff <= '1';
            COMMON.pc <= PC;
            COMMON.op <= op_buff;
            COMMON.funct <= (others => 'X'); -- TODO
            COMMON.is_in_delay_slot <= IS_IN_DELAY_SLOT;
            EX.cp0_read_en <= '0';
            EX.cp0_read_addr <= (others => 'X');
            EX.alu_op <= alu_nop;
            EX.operand_0 <= (others => 'X');
            EX.operand_1 <= (others => 'X');
            MEM.alu_result <= (others => 'X');
            MEM.mem_en <= '0';
            MEM.mem_write_en <= 'X';
            MEM.write_mem_data <= (others => 'X');
            MEM.is_uart_data <= 'X';
            MEM.is_uart_control <= 'X';
            MEM.except_type <= except_none;
            WB.write_en <= '0';
            WB.write_addr <= (others => 'X');
            WB.write_data <= (others => 'X');
            WB.hi_write_en <= 'X';
            WB.hi_write_data <= (others => 'X');
            WB.lo_write_en <= 'X';
            WB.lo_write_data <= (others => 'X');
            WB.t_write_en <= '0';
            WB.t_write_data <= 'X';
            WB.sp_write_en <= '0';
            WB.sp_write_data <= (others => 'X');
            WB.ds_write_en <= '0';
            WB.ds_write_data <= (others => 'X');
            WB.cp0_write_en <= '0';
            WB.cp0_write_addr <= (others => 'X');
            WB.cp0_write_data <= (others => 'X');
            BRANCH_EN <= '0';
            BRANCH_PC <= (others => 'X');
            IS_LOAD <= '0';
            
            store_after_load_buff <= '0';
            MEM.sw_after_load <= store_after_load_buff;

            case op_buff is
                when "00010" => -- b
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    BRANCH_EN <= '1';
                    BRANCH_PC <= b_pc;
                when "00100" => -- beqz
                    read_en_1_buff <= '0';
                    BRANCH_EN <= reg_0_eq_0;
                    BRANCH_PC <= cb_pc;
                when "00101" => -- bnez
                    read_en_1_buff <= '0';
                    BRANCH_EN <= not reg_0_eq_0;
                    BRANCH_PC <= cb_pc;
                when "01100" => 
                    case INS(10 downto 8) is
                        when "000" => -- bteqz
                            read_en_0_buff <= '0';
                            read_en_1_buff <= '0';
                            BRANCH_EN <= not T;
                            BRANCH_PC <= cb_pc;
                        when "011" => -- addsp
                            read_en_0_buff <= '0';
                            read_en_1_buff <= '0';
                            EX.alu_op <= alu_addu;
                            EX.operand_0 <= SP;
                            EX.operand_1 <= imm8se;
                            WB.sp_write_en <= '1';
                        when "100" => -- mtsp
                            read_en_0_buff <= '0';
                            EX.alu_op <= alu_or;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= zero_word;
                            WB.sp_write_en <= '1';
                        when others =>
                    end case;
                when "01001" => -- addiu
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm8se;
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                when "01000" => -- addiu3
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm4se;
                    WB.write_en <= '1';
                    WB.write_addr <= ry;
                when "11100" =>
                    case INS(1 downto 0) is
                        when "01" => -- addu
                            EX.alu_op <= alu_addu;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.write_en <= '1';
                            WB.write_addr <= rz;
                        when "11" => -- subu
                            EX.alu_op <= alu_subu;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.write_en <= '1';
                            WB.write_addr <= rz;
                        when others =>
                    end case;
                when "01101" => -- li
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_or;
                    EX.operand_0 <= zero_word;
                    EX.operand_1 <= imm8ze;
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                when "01111" => -- move
                    read_en_0_buff <= '0';
                    EX.alu_op <= alu_or;
                    EX.operand_0 <= READ_DATA_1;
                    EX.operand_1 <= zero_word;
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                when "01110" => -- cmpi
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_cmp;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm8se;
                    WB.t_write_en <= '1';
                when "00110" =>
                    case INS(1 downto 0) is
                        when "00" => -- sll
                            read_en_0_buff <= '0';
                            EX.alu_op <= alu_sll;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= shamt_buff;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when "11" => -- sra
                            read_en_0_buff <= '0';
                            EX.alu_op <= alu_sra;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= shamt_buff;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when others =>
                    end case;
                when "11101" =>
                    case INS(4 downto 0) is
                        when "01111" => -- not
                            read_en_0_buff <= '0';
                            EX.alu_op <= alu_nor;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= zero_word;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when "00100" => -- sllv
                            EX.alu_op <= alu_sll;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= READ_DATA_0;
                            WB.write_en <= '1';
                            WB.write_addr <= ry;
                        when "00111" => -- srav
                            EX.alu_op <= alu_sra;
                            EX.operand_0 <= READ_DATA_1;
                            EX.operand_1 <= READ_DATA_0;
                            WB.write_en <= '1';
                            WB.write_addr <= ry;
                        when "01100" => -- and
                            EX.alu_op <= alu_and;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when "01101" => -- or
                            EX.alu_op <= alu_or;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when "01010" => -- cmp
                            EX.alu_op <= alu_cmp;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= READ_DATA_1;
                            WB.t_write_en <= '1';
                        when "00000" =>
                            case INS(7 downto 5) is
                                when "000" => -- jr
                                    read_en_1_buff <= '0';
                                    BRANCH_EN <= '1';
                                    BRANCH_PC <= READ_DATA_0;
                                when "010" => -- mfpc
                                    read_en_0_buff <= '0';
                                    read_en_1_buff <= '0';
                                    EX.alu_op <= alu_or;
                                    EX.operand_0 <= PC;
                                    EX.operand_1 <= zero_word;
                                    WB.write_en <= '1';
                                    WB.write_addr <= rx;
                                when others =>
                            end case;                        
                        when others =>
                    end case;
                when "00001" => -- nop
                when "10011" => -- lw
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm5se;
                    MEM.mem_en <= '1';
                    MEM.mem_write_en <= '0';
                    WB.write_en <= '1';
                    WB.write_addr <= ry;
                    IS_LOAD <= '1';
                when "10010" => -- lwsp
                    read_en_0_buff <= '0';
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= SP;
                    EX.operand_1 <= imm8se;
                    MEM.mem_en <= '1';
                    MEM.mem_write_en <= '0';
                    WB.write_en <= '1';
                    WB.write_addr <= rx;
                    IS_LOAD <= '1';
                when "11011" => -- sw
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= READ_DATA_0;
                    EX.operand_1 <= imm5se;
                    MEM.mem_en <= '1';
                    MEM.mem_write_en <= '1';
                    MEM.write_mem_data <= READ_DATA_1;
                    if EX_IS_LOAD = '1' and EX_WRITE_ADDR = read_addr_1_buff then
                        store_after_load_buff <= '1';
                    end if;
                when "11010" => -- swsp
                    read_en_1_buff <= '0';
                    EX.alu_op <= alu_addu;
                    EX.operand_0 <= SP;
                    EX.operand_1 <= imm8se;
                    MEM.mem_en <= '1';
                    MEM.mem_write_en <= '1';
                    MEM.write_mem_data <= READ_DATA_0;
                    if EX_IS_LOAD = '1' and EX_WRITE_ADDR = read_addr_0_buff then
                        store_after_load_buff <= '1';
                    end if;
                when "11110" =>
                    case INS(4 downto 0) is
                        when "00000" => -- mfc0
                            read_en_0_buff <= '0';
                            read_en_1_buff <= '0';
                            EX.cp0_read_en <= '1';
                            EX.cp0_read_addr <= cp0_addr;
                            WB.write_en <= '1';
                            WB.write_addr <= rx;
                        when "00001" => -- mtc0
                            read_en_1_buff <= '0';
                            EX.alu_op <= alu_or;
                            EX.operand_0 <= READ_DATA_0;
                            EX.operand_1 <= zero_word;
                            WB.cp0_write_en <= '1';
                            WB.cp0_write_addr <= cp0_addr;
                        when "00010" => -- eret
                            MEM.except_type <= "10000000";
                        when others =>
                    end case;
                when "11111" => -- syscall
                    MEM.except_type <= "01000000";
                when others =>
            end case;
        end if;
    end process;

    -- load hazard
    STALL_REQ <= '1' when EX_IS_LOAD = '1' and store_after_load_buff = '0' and
                          ((read_en_0_buff = '1' and EX_WRITE_ADDR = read_addr_0_buff) or
                           (read_en_1_buff = '1' and EX_WRITE_ADDR = read_addr_1_buff)) else '0';
                          -- TODO: check zero reg here?
end;