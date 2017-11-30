library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.types.all;

entity mips_core is
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
end;

architecture behavioral of mips_core is
    component reg_file is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            READ_ADDR_0: in reg_addr_t;
            READ_DATA_0: out word_t;
            
            READ_ADDR_1: in reg_addr_t;
            READ_DATA_1: out word_t;
            
            WRITE_EN: in std_logic;
            WRITE_ADDR: in reg_addr_t;
            WRITE_DATA: in word_t
        );
    end component;
    
    component reg_forward is
        port
        (
            RST: in std_logic;
            
            ID_READ_ADDR_0: in reg_addr_t;
            ID_READ_DATA_0: out word_t;
            
            ID_READ_ADDR_1: in reg_addr_t;
            ID_READ_DATA_1: out word_t;
            
            -- read from reg file
            REG_READ_ADDR_0: out reg_addr_t;
            REG_READ_DATA_0: in word_t;
            
            REG_READ_ADDR_1: out reg_addr_t;
            REG_READ_DATA_1: in word_t;
            
            -- ex
            EX_WRITE_EN: in std_logic;
            EX_WRITE_ADDR: in reg_addr_t;
            EX_WRITE_DATA: in word_t;
            
            -- mem
            MEM_WRITE_EN: in std_logic;
            MEM_WRITE_ADDR: in reg_addr_t;
            MEM_WRITE_DATA: in word_t;
            
            -- wb
            WB_WRITE_EN: in std_logic;
            WB_WRITE_ADDR: in reg_addr_t;
            WB_WRITE_DATA: in word_t
        );
    end component;
    
    component hilo is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            HI_WRITE_EN: in std_logic;
            HI_WRITE_DATA: in word_t;
            LO_WRITE_EN: in std_logic;
            LO_WRITE_DATA: in word_t;
            
            HI: out word_t;
            LO: out word_t
        );
    end component;
    
    component hilo_forward is
        port
        (
            RST: in std_logic;
            
            -- read from HILO
            HILO_HI: in word_t;
            HILO_LO: in word_t;

            -- mem
            MEM_HI_WRITE_EN: in std_logic;
            MEM_HI_WRITE_DATA: in word_t;
            MEM_LO_WRITE_EN: in std_logic;
            MEM_LO_WRITE_DATA: in word_t;
            
            -- wb
            WB_HI_WRITE_EN: in std_logic;
            WB_HI_WRITE_DATA: in word_t;
            WB_LO_WRITE_EN: in std_logic;
            WB_LO_WRITE_DATA: in word_t;
            
            -- HILO content for ex
            EX_HI: out word_t;
            EX_LO: out word_t
        );
    end component;
    
    component special_reg is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            T_WRITE_EN: in std_logic;
            T_WRITE_DATA: in std_logic;
            SP_WRITE_EN: in std_logic;
            SP_WRITE_DATA: in word_t;
            DS_WRITE_EN: in std_logic;
            DS_WRITE_DATA: in word_t;
            
            T: out std_logic;
            SP: out word_t;
            DS: out word_t
        );
    end component;
    
    component special_reg_forward is
        port
        (
            RST: in std_logic;
            
            -- read from sreg
            SREG_T: in std_logic;
            SREG_SP: in word_t;
            SREG_DS: in word_t;

            -- ex
            EX_T_WRITE_EN: in std_logic;
            EX_T_WRITE_DATA: in std_logic;
            EX_SP_WRITE_EN: in std_logic;
            EX_SP_WRITE_DATA: in word_t;
            EX_DS_WRITE_EN: in std_logic;
            EX_DS_WRITE_DATA: in word_t;

            -- mem
            MEM_T_WRITE_EN: in std_logic;
            MEM_T_WRITE_DATA: in std_logic;
            MEM_SP_WRITE_EN: in std_logic;
            MEM_SP_WRITE_DATA: in word_t;
            MEM_DS_WRITE_EN: in std_logic;
            MEM_DS_WRITE_DATA: in word_t;
            
            -- wb
            WB_T_WRITE_EN: in std_logic;
            WB_T_WRITE_DATA: in std_logic;
            WB_SP_WRITE_EN: in std_logic;
            WB_SP_WRITE_DATA: in word_t;
            WB_DS_WRITE_EN: in std_logic;
            WB_DS_WRITE_DATA: in word_t;
            
            -- sreg content for id
            ID_T: out std_logic;
            ID_SP: out word_t;
            ID_DS: out word_t
        );
    end component;

    component controller is
        port
        (
            RST: in std_logic;

            IF_STALL_REQ: in std_logic;
            ID_STALL_REQ: in std_logic;
            EX_STALL_REQ: in std_logic;
            MEM_STALL_REQ: in std_logic;
            
            STALL: out stall_t
        );
    end component;
    
    component cp0 is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            READ_ADDR: in cp0_addr_t;
            READ_DATA: out word_t;

            WRITE_EN: in std_logic;
            WRITE_ADDR: in cp0_addr_t;
            WRITE_DATA: in word_t;
     
            EX_READ_ADDR: in cp0_addr_t;
            EX_READ_DATA: out word_t;

            EX_BITS: out cp0_bits_t;
            
            -- mem
            MEM_WRITE_EN: in std_logic;
            MEM_WRITE_ADDR: in cp0_addr_t;
            MEM_WRITE_DATA: in word_t;
            
            EXCEPT_WRITE: in cp0_except_write_t
        );
    end component;

    component program_counter is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            STALL: in stall_t;
            
            FLUSH: in std_logic;
            FLUSH_PC: in word_t;
            
            PC: out word_t;
            PC_4: out word_t;
            
            BRANCH_EN: in std_logic;
            BRANCH_PC: in word_t
        );
    end component;
    
    component instruction_fetch is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;
            
            PC: in word_t;
            PC_4: in word_t;
            
            PC_O: out word_t;
            INS: out word_t;
            
            -- bus
            BUS_REQ: out bus_request_t;
            BUS_RES: in bus_response_t
        );
    end component;
    
    component if_id_reg is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;
            FLUSH: in std_logic;

            IF_PC: in word_t;
            IF_INS: in word_t;
            
            ID_PC: out word_t;
            ID_INS: out word_t
        );
    end component;

    component instruction_decode is
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
            BRANCH_PC: out word_t
        );
    end component;
    
    component id_ex_reg is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            STALL: in stall_t;
            FLUSH: in std_logic;
            
            ID_COMMON: in common_signal_t;
            ID_EX: in ex_signal_t;
            ID_MEM: in mem_signal_t;
            ID_WB: in wb_signal_t;
            ID_IS_LOAD: in std_logic;
            
            EX_COMMON: out common_signal_t;
            EX_EX: out ex_signal_t;
            EX_MEM: out mem_signal_t;
            EX_WB: out wb_signal_t;
            EX_IS_LOAD: out std_logic
        );
    end component;

    component execute is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            COMMON: in common_signal_t;
            EX: in ex_signal_t;
            MEM: in mem_signal_t;
            WB: in wb_signal_t;

            COMMON_O: out common_signal_t;
            MEM_O: out mem_signal_t;
            WB_O: out wb_signal_t;

            HI: in word_t;
            LO: in word_t;

            MEM_LOADED_DATA: in word_t;
            
            -- CP0 interface
            CP0_READ_ADDR: out cp0_addr_t;
            CP0_READ_DATA: in word_t;
            
            -- divider interface
            -- data signals
            DIV_DIVIDEND: out word_t;
            DIV_DIV: out word_t;
            
            DIV_QUOTIENT: in word_t;
            DIV_REMAINDER: in word_t;
            
            -- control signals
            DIV_SIGN: out std_logic;
            DIV_EN: out std_logic;
            DIV_DONE: in std_logic
        );
    end component;

    component divider is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;

            -- data signals
            DIVIDEND: in word_t;
            DIV: in word_t;
            
            QUOTIENT: out word_t;
            REMAINDER: out word_t;
            
            -- control signals
            SIGN: in std_logic;
            EN: in std_logic;
            CANCEL: in std_logic;
            STALL: in std_logic;
            DONE: out std_logic
        );
    end component;
    
    component ex_mem_reg is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;
            FLUSH: in std_logic;
            
            EX_COMMON: in common_signal_t;
            EX_MEM: in mem_signal_t;
            EX_WB: in wb_signal_t;
            
            MEM_COMMON: out common_signal_t;
            MEM_MEM: out mem_signal_t;
            MEM_WB: out wb_signal_t
        );
    end component;
 
    component memory_access is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            COMMON: in common_signal_t;
            MEM: in mem_signal_t;
            WB: in wb_signal_t;

            COMMON_O: out common_signal_t;
            WB_O: out wb_signal_t;
            
            -- bus
            BUS_REQ: out bus_request_t;
            BUS_RES: in bus_response_t;

            LOADED_DATA: out word_t
        );
    end component;

    component mem_wb_reg is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;
            FLUSH: in std_logic;

            MEM_COMMON: in common_signal_t;
            MEM_WB: in wb_signal_t;
            
            WB_COMMON: out common_signal_t;
            WB_WB: out wb_signal_t
        );
    end component;
 
    signal comb_rst: std_logic;
    
    signal reg_read_addr_0: reg_addr_t;
    signal reg_read_data_0: word_t;
    signal reg_read_addr_1: reg_addr_t;
    signal reg_read_data_1: word_t;
    
    signal hilo_hi, hilo_lo: word_t;
    signal sreg_t: std_logic;
    signal sreg_sp: word_t;
    signal sreg_ds: word_t;
    
    signal cp0_bits: cp0_bits_t;
    signal cp0_except_write: cp0_except_write_t;
    
    signal if_stall_req: std_logic;
    signal id_stall_req: std_logic;
    signal ex_stall_req: std_logic;
    signal mem_stall_req: std_logic;
    signal stall: stall_t;

    -- IF inputs
    signal if_pc, if_pc_4: word_t;
    -- IF outputs
    signal if_pc_o, if_ins: word_t;
    
    -- ID inputs
    signal id_pc, id_ins: word_t;
    -- reg for ID
    signal id_read_addr_0: reg_addr_t;
    signal id_read_data_0: word_t;
    signal id_read_addr_1: reg_addr_t;
    signal id_read_data_1: word_t;
    signal id_t: std_logic;
    signal id_sp: word_t;
    signal id_ds: word_t;
    
    -- ID outputs
    signal id_common: common_signal_t;
    signal id_ex: ex_signal_t;
    signal id_mem: mem_signal_t;
    signal id_wb: wb_signal_t;
    
    signal id_branch_en: std_logic;
    signal id_branch_pc: word_t;
    signal id_is_load: std_logic;
    
    -- EX inputs
    signal ex_common: common_signal_t;
    signal ex_ex: ex_signal_t;
    signal ex_mem: mem_signal_t;
    signal ex_wb: wb_signal_t;
    signal ex_is_load: std_logic;
    signal ex_hi, ex_lo: word_t;
    -- EX outputs
    signal ex_common_o: common_signal_t;
    signal ex_mem_o: mem_signal_t;
    signal ex_wb_o: wb_signal_t;
    -- EX CP0 interface
    signal ex_cp0_read_addr: cp0_addr_t;
    signal ex_cp0_read_data: word_t;
    -- EX divider interface
    signal ex_div_dividend: word_t;
    signal ex_div_div: word_t;
    signal ex_div_quotient: word_t;
    signal ex_div_remainder: word_t;
    signal ex_div_sign: std_logic;
    signal ex_div_en: std_logic;
    signal ex_div_done: std_logic;

    -- MEM inputs
    signal mem_common: common_signal_t;
    signal mem_mem: mem_signal_t;
    signal mem_wb: wb_signal_t;
    -- MEM outputs
    signal mem_common_o: common_signal_t;
    signal mem_wb_o: wb_signal_t;
    signal mem_loaded_data: word_t;

    -- WB inputs
    signal wb_common: common_signal_t;
    signal wb_wb: wb_signal_t;
begin
    comb_rst <= '0';
    
    testen <= wb_wb.write_en;
    test_0 <= wb_wb.write_addr;
    test_1 <= wb_wb.write_data;
    
    reg_file_inst: reg_file
    port map
    (
        CLK => CLK,
        RST => RST,

        READ_ADDR_0 => reg_read_addr_0,
        READ_DATA_0 => reg_read_data_0,
        READ_ADDR_1 => reg_read_addr_1,
        READ_DATA_1 => reg_read_data_1,

        WRITE_EN => wb_wb.write_en,
        WRITE_ADDR => wb_wb.write_addr,
        WRITE_DATA => wb_wb.write_data
    );
    
    reg_forward_inst: reg_forward
    port map
    (
        RST => comb_rst,
        
        ID_READ_ADDR_0 => id_read_addr_0,
        ID_READ_DATA_0 => id_read_data_0,
        
        ID_READ_ADDR_1 => id_read_addr_1,
        ID_READ_DATA_1 => id_read_data_1,
        
        -- read from reg file
        REG_READ_ADDR_0 => reg_read_addr_0,
        REG_READ_DATA_0 => reg_read_data_0,
        
        REG_READ_ADDR_1 => reg_read_addr_1,
        REG_READ_DATA_1 => reg_read_data_1,
        
        -- ex
        EX_WRITE_EN => ex_wb_o.write_en,
        EX_WRITE_ADDR => ex_wb_o.write_addr,
        EX_WRITE_DATA => ex_wb_o.write_data,
        
        -- mem
        MEM_WRITE_EN => mem_wb_o.write_en,
        MEM_WRITE_ADDR => mem_wb_o.write_addr,
        MEM_WRITE_DATA => mem_wb_o.write_data,
        
        -- wb
        WB_WRITE_EN => wb_wb.write_en,
        WB_WRITE_ADDR => wb_wb.write_addr,
        WB_WRITE_DATA => wb_wb.write_data
    );
    
    hilo_inst: hilo
    port map
    (
        CLK => CLK,
        RST => RST,
        
        HI_WRITE_EN => wb_wb.hi_write_en,
        HI_WRITE_DATA => wb_wb.hi_write_data,
        LO_WRITE_EN => wb_wb.lo_write_en,
        LO_WRITE_DATA => wb_wb.lo_write_data,
        
        HI => hilo_hi,
        LO => hilo_lo
    );
    
    hilo_forward_inst: hilo_forward
    port map
    (
        RST => comb_rst,
        
        -- read from HILO
        HILO_HI => hilo_hi,
        HILO_LO => hilo_lo,

        -- mem
        MEM_HI_WRITE_EN => mem_wb_o.hi_write_en,
        MEM_HI_WRITE_DATA => mem_wb_o.hi_write_data,
        MEM_LO_WRITE_EN => mem_wb_o.lo_write_en,
        MEM_LO_WRITE_DATA => mem_wb_o.lo_write_data,
        
        -- wb
        WB_HI_WRITE_EN => wb_wb.hi_write_en,
        WB_HI_WRITE_DATA => wb_wb.hi_write_data,
        WB_LO_WRITE_EN => wb_wb.lo_write_en,
        WB_LO_WRITE_DATA => wb_wb.lo_write_data,
        
        -- HILO content for ex
        EX_HI => ex_hi,
        EX_LO => ex_lo
    );
    
    special_reg_inst: special_reg
    port map
    (
        CLK => CLK,
        RST => RST,
        
        T_WRITE_EN => wb_wb.t_write_en,
        T_WRITE_DATA => wb_wb.t_write_data,
        SP_WRITE_EN => wb_wb.sp_write_en,
        SP_WRITE_DATA => wb_wb.sp_write_data,
        DS_WRITE_EN => wb_wb.ds_write_en,
        DS_WRITE_DATA => wb_wb.ds_write_data,
        
        T => sreg_t,
        SP => sreg_sp,
        DS => sreg_ds
    );
    
    special_reg_forward_inst: special_reg_forward
    port map
    (
        RST => comb_rst,
        
        -- read from sreg
        SREG_T => sreg_t,
        SREG_SP => sreg_sp,
        SREG_DS => sreg_ds,

        -- ex
        EX_T_WRITE_EN => ex_wb_o.t_write_en,
        EX_T_WRITE_DATA => ex_wb_o.t_write_data,
        EX_SP_WRITE_EN => ex_wb_o.sp_write_en,
        EX_SP_WRITE_DATA => ex_wb_o.sp_write_data,
        EX_DS_WRITE_EN => ex_wb_o.ds_write_en,
        EX_DS_WRITE_DATA => ex_wb_o.ds_write_data,

        -- mem
        MEM_T_WRITE_EN => mem_wb_o.t_write_en,
        MEM_T_WRITE_DATA => mem_wb_o.t_write_data,
        MEM_SP_WRITE_EN => mem_wb_o.sp_write_en,
        MEM_SP_WRITE_DATA => mem_wb_o.sp_write_data,
        MEM_DS_WRITE_EN => mem_wb_o.ds_write_en,
        MEM_DS_WRITE_DATA => mem_wb_o.ds_write_data,
        
        -- wb
        WB_T_WRITE_EN => wb_wb.t_write_en,
        WB_T_WRITE_DATA => wb_wb.t_write_data,
        WB_SP_WRITE_EN => wb_wb.sp_write_en,
        WB_SP_WRITE_DATA => wb_wb.sp_write_data,
        WB_DS_WRITE_EN => wb_wb.ds_write_en,
        WB_DS_WRITE_DATA => wb_wb.ds_write_data,
        
        -- sreg content for id
        ID_T => id_t,
        ID_SP => id_sp,
        ID_DS => id_ds
    );
    
    controller_inst: controller
    port map
    (
        RST => comb_rst,

        IF_STALL_REQ => if_stall_req,
        ID_STALL_REQ => id_stall_req,
        EX_STALL_REQ => ex_stall_req,
        MEM_STALL_REQ => mem_stall_req,
        
        STALL => stall
    );
    
    cp0_inst: cp0
    port map
    (
        CLK => CLK,
        RST => RST, 
        
        READ_ADDR => (others => 'X'),
        -- READ_DATA =>

        WRITE_EN => wb_wb.cp0_write_en,
        WRITE_ADDR => wb_wb.cp0_write_addr,
        WRITE_DATA => wb_wb.cp0_write_data,
 
        EX_READ_ADDR => ex_cp0_read_addr,
        EX_READ_DATA => ex_cp0_read_data,

        EX_BITS => cp0_bits,
        
        -- mem
        MEM_WRITE_EN => mem_wb_o.cp0_write_en,
        MEM_WRITE_ADDR => mem_wb_o.cp0_write_addr,
        MEM_WRITE_DATA => mem_wb_o.cp0_write_data,
        
        EXCEPT_WRITE => cp0_except_write
    );
    
    cp0_except_write.en <= '0';
    -- TODO
    
    program_counter_inst: program_counter
    port map
    (
        CLK => CLK,
        RST => RST, 

        STALL => stall,
        
        FLUSH => '0',
        FLUSH_PC => (others => '0'),
        
        PC => if_pc,
        PC_4 => if_pc_4,
        
        BRANCH_EN => id_branch_en,
        BRANCH_PC => id_branch_pc
    );

    
    instruction_fetch_inst: instruction_fetch
    port map
    (
        RST => comb_rst,
        
        STALL_REQ => if_stall_req,
        
        PC => if_pc,
        PC_4 => if_pc_4,
        
        PC_O => if_pc_o,
        INS => if_ins,
        
        BUS_REQ => INS_BUS_REQ,
        BUS_RES => INS_BUS_RES
    );
    
    if_id_reg_inst: if_id_reg
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO
        
        IF_PC => if_pc_o,
        IF_INS => if_ins,
        
        ID_PC => id_pc,
        ID_INS => id_ins
    );
    
    instruction_decode_inst: instruction_decode
    port map
    (
        RST => comb_rst,
        
        STALL_REQ => id_stall_req,
        
        PC => id_pc,
        INS => id_ins,
        
        READ_ADDR_0 => id_read_addr_0,
        READ_DATA_0 => id_read_data_0,
        READ_ADDR_1 => id_read_addr_1,
        READ_DATA_1 => id_read_data_1,
        
        T => id_t,
        SP => id_sp,
        DS => id_ds,
        
        COMMON => id_common,
        EX => id_ex,
        MEM => id_mem,
        WB => id_wb,

        IS_LOAD => id_is_load,
        
        EX_IS_LOAD => ex_is_load,
        EX_WRITE_ADDR => ex_wb.write_addr,
		  
        BRANCH_EN => id_branch_en,
        BRANCH_PC => id_branch_pc
    );
    
    id_ex_reg_inst: id_ex_reg
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO

        ID_COMMON => id_common,
        ID_EX => id_ex,
        ID_MEM => id_mem,
        ID_WB => id_wb,
        ID_IS_LOAD => id_is_load,
        
        EX_COMMON => ex_common,
        EX_EX => ex_ex,
        EX_MEM => ex_mem,
        EX_WB => ex_wb,
        EX_IS_LOAD => ex_is_load
    );
    
    execute_inst: execute
    port map
    (
        RST => comb_rst,
        
        STALL_REQ => ex_stall_req,

        COMMON => ex_common,
        EX => ex_ex,
        MEM => ex_mem,
        WB => ex_wb,

        COMMON_O => ex_common_o,
        MEM_O => ex_mem_o,
        WB_O => ex_wb_o,

        HI => ex_hi,
        LO => ex_lo, 
        MEM_LOADED_DATA => mem_loaded_data,
        
        CP0_READ_ADDR => ex_cp0_read_addr,
        CP0_READ_DATA => ex_cp0_read_data,
 
        DIV_DIVIDEND => ex_div_dividend,
        DIV_DIV => ex_div_div,
        
        DIV_QUOTIENT => ex_div_quotient,
        DIV_REMAINDER => ex_div_remainder,
        
        DIV_SIGN => ex_div_sign,
        DIV_EN => ex_div_en,
        DIV_DONE => ex_div_done
    );
    
    divider_inst: divider
    port map
    (
        CLK => CLK,
        RST => RST,

        DIVIDEND => ex_div_dividend,
        DIV => ex_div_div,

        QUOTIENT => ex_div_quotient,
        REMAINDER => ex_div_remainder,

        SIGN => ex_div_sign,
        EN => ex_div_en,
        CANCEL => '0', -- TODO
        STALL => stall(stage_mem),
        DONE => ex_div_done
    );
    
    ex_mem_reg_inst: ex_mem_reg
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO

        EX_COMMON => ex_common_o,
        EX_MEM => ex_mem_o,
        EX_WB => ex_wb_o,
        
        MEM_COMMON => mem_common,
        MEM_MEM => mem_mem,
        MEM_WB => mem_wb
    );
    
    memory_access_inst: memory_access
    port map
    (
        RST => comb_rst,
        
        STALL_REQ => mem_stall_req,

        COMMON => mem_common,
        MEM => mem_mem,
        WB => mem_wb,

        COMMON_O => mem_common_o,
        WB_O => mem_wb_o,
        
        BUS_REQ => DATA_BUS_REQ,
        BUS_RES => DATA_BUS_RES,
        LOADED_DATA => mem_loaded_data
    );
    
    mem_wb_reg_inst: mem_wb_reg
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO

        MEM_COMMON => mem_common_o,
        MEM_WB => mem_wb_o,
        
        WB_COMMON => wb_common,
        WB_WB => wb_wb
    );
end;