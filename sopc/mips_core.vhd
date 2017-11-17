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
    
    component if_id is
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
            
            READ_ADDR_0: out reg_addr_t;
            READ_DATA_0: in word_t;
            
            READ_ADDR_1: out reg_addr_t;
            READ_DATA_1: in word_t;
            
            PC_O: out word_t;
            OP: out op_t;
            FUNCT: out funct_t;
            ALU_OP: out alu_op_t;
            OPERAND_0: out word_t;
            OPERAND_1: out word_t;
            WRITE_EN: out std_logic;
            WRITE_ADDR: out reg_addr_t;
            WRITE_MEM_DATA: out word_t;
            IS_LOAD: out std_logic;
            
            EX_IS_LOAD: in std_logic;
            EX_WRITE_ADDR: in reg_addr_t;
        
            BRANCH_EN: out std_logic;
            BRANCH_PC: out word_t
        );
    end component;
    
    component id_ex is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;
            FLUSH: in std_logic;

            ID_PC: in word_t;
            ID_OP: in op_t;
            ID_FUNCT: in funct_t;
            ID_ALU_OP: in alu_op_t;
            ID_OPERAND_0: in word_t;
            ID_OPERAND_1: in word_t;
            ID_WRITE_EN: in std_logic;
            ID_WRITE_ADDR: in reg_addr_t;
            ID_WRITE_MEM_DATA: in word_t;
            ID_IS_LOAD: in std_logic;

            EX_PC: out word_t;
            EX_OP: out op_t;
            EX_FUNCT: out funct_t;
            EX_ALU_OP: out alu_op_t;
            EX_OPERAND_0: out word_t;
            EX_OPERAND_1: out word_t;
            EX_WRITE_EN: out std_logic;
            EX_WRITE_ADDR: out reg_addr_t;
            EX_WRITE_MEM_DATA: out word_t;
            EX_IS_LOAD: out std_logic
        );
    end component;

    component execute is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            PC: in word_t;
            OP: in op_t;
            FUNCT: in funct_t;
            ALU_OP: in alu_op_t;
            OPERAND_0: in word_t;
            OPERAND_1: in word_t;
            WRITE_EN: in std_logic;
            WRITE_ADDR: in reg_addr_t;
            WRITE_MEM_DATA: in word_t;
            HI: in word_t;
            LO: in word_t;
            
            PC_O: out word_t;
            OP_O: out op_t;
            FUNCT_O: out funct_t;
            ALU_RESULT: out word_t;
            WRITE_EN_O: out std_logic;
            WRITE_ADDR_O: out reg_addr_t;
            WRITE_DATA: out word_t;
            WRITE_MEM_DATA_O: out word_t;
            HI_WRITE_EN: out std_logic;
            HI_WRITE_DATA: out word_t;
            LO_WRITE_EN: out std_logic;
            LO_WRITE_DATA: out word_t;
            
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
    
    component ex_mem is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;
            FLUSH: in std_logic;

            EX_PC: in word_t;
            EX_OP: in op_t;
            EX_FUNCT: in funct_t;
            EX_ALU_RESULT: in word_t;
            EX_WRITE_EN: in std_logic;
            EX_WRITE_ADDR: in reg_addr_t;
            EX_WRITE_DATA: in word_t;
            EX_WRITE_MEM_DATA: in word_t;
            EX_HI_WRITE_EN: in std_logic;
            EX_HI_WRITE_DATA: in word_t;
            EX_LO_WRITE_EN: in std_logic;
            EX_LO_WRITE_DATA: in word_t;
            
            MEM_PC: out word_t;
            MEM_OP: out op_t;
            MEM_FUNCT: out funct_t;
            MEM_ALU_RESULT: out word_t;
            MEM_WRITE_EN: out std_logic;
            MEM_WRITE_ADDR: out reg_addr_t;
            MEM_WRITE_DATA: out word_t;
            MEM_WRITE_MEM_DATA: out word_t;
            MEM_HI_WRITE_EN: out std_logic;
            MEM_HI_WRITE_DATA: out word_t;
            MEM_LO_WRITE_EN: out std_logic;
            MEM_LO_WRITE_DATA: out word_t
        );
    end component;
 
    component memory_access is
        port
        (
            RST: in std_logic;
            
            STALL_REQ: out std_logic;

            PC: in word_t;
            OP: in op_t;
            FUNCT: in funct_t;
            ALU_RESULT: in word_t;
            WRITE_EN: in std_logic;
            WRITE_ADDR: in reg_addr_t;
            WRITE_DATA: in word_t;
            WRITE_MEM_DATA: in word_t;
            HI_WRITE_EN: in std_logic;
            HI_WRITE_DATA: in word_t;
            LO_WRITE_EN: in std_logic;
            LO_WRITE_DATA: in word_t;
            
            PC_O: out word_t;
            OP_O: out op_t;
            FUNCT_O: out funct_t;
            WRITE_EN_O: out std_logic;
            WRITE_ADDR_O: out reg_addr_t;
            WRITE_DATA_O: out word_t;
            HI_WRITE_EN_O: out std_logic;
            HI_WRITE_DATA_O: out word_t;
            LO_WRITE_EN_O: out std_logic;
            LO_WRITE_DATA_O: out word_t;
            
            -- bus
            BUS_REQ: out bus_request_t;
            BUS_RES: in bus_response_t
        );
    end component;

    component mem_wb is
        port
        (
            CLK: in std_logic;
            RST: in std_logic;
            
            STALL: in stall_t;
            FLUSH: in std_logic;

            MEM_PC: in word_t;
            MEM_OP: in op_t;
            MEM_FUNCT: in funct_t;
            MEM_WRITE_EN: in std_logic;
            MEM_WRITE_ADDR: in reg_addr_t;
            MEM_WRITE_DATA: in word_t;
            MEM_HI_WRITE_EN: in std_logic;
            MEM_HI_WRITE_DATA: in word_t;
            MEM_LO_WRITE_EN: in std_logic;
            MEM_LO_WRITE_DATA: in word_t;
            
            WB_PC: out word_t;
            WB_OP: out op_t;
            WB_FUNCT: out funct_t;
            WB_WRITE_EN: out std_logic;
            WB_WRITE_ADDR: out reg_addr_t;
            WB_WRITE_DATA: out word_t;
            WB_HI_WRITE_EN: out std_logic;
            WB_HI_WRITE_DATA: out word_t;
            WB_LO_WRITE_EN: out std_logic;
            WB_LO_WRITE_DATA: out word_t
        );
    end component;
 
    signal comb_rst: std_logic;
    
    signal reg_read_addr_0: reg_addr_t;
    signal reg_read_data_0: word_t;
    signal reg_read_addr_1: reg_addr_t;
    signal reg_read_data_1: word_t;
    
    signal hilo_hi, hilo_lo: word_t;
    
    signal if_stall_req: std_logic;
    signal id_stall_req: std_logic;
    signal ex_stall_req: std_logic;
    signal mem_stall_req: std_logic;
    signal stall: stall_t;

    signal if_pc, if_pc_4, if_pc_o, if_ins: word_t;
    
    signal id_pc, id_ins, id_pc_o: word_t;
    
    signal id_read_addr_0: reg_addr_t;
    signal id_read_data_0: word_t;
    signal id_read_addr_1: reg_addr_t;
    signal id_read_data_1: word_t;
    
    signal id_op: op_t;
    signal id_funct: funct_t;
    signal id_alu_op: alu_op_t;
    signal id_operand_0: word_t;
    signal id_operand_1: word_t;
    signal id_write_en: std_logic;
    signal id_write_addr: reg_addr_t;
    signal id_write_mem_data: word_t;
    signal id_branch_en: std_logic;
    signal id_branch_pc: word_t;
    signal id_is_load: std_logic;
    
    signal ex_pc: word_t;
    signal ex_op: op_t;
    signal ex_funct: funct_t;
    signal ex_alu_op: alu_op_t;
    signal ex_operand_0: word_t;
    signal ex_operand_1: word_t;
    signal ex_write_en: std_logic;
    signal ex_write_addr: reg_addr_t;
    signal ex_write_mem_data: word_t;
    signal ex_hi: word_t;
    signal ex_lo: word_t;
    signal ex_is_load: std_logic;
    
    signal ex_pc_o: word_t;
    signal ex_op_o: op_t;
    signal ex_funct_o: funct_t;
    signal ex_alu_result: word_t;
    signal ex_write_en_o: std_logic;
    signal ex_write_addr_o: reg_addr_t;
    signal ex_write_data: word_t;
    signal ex_write_mem_data_o: word_t;
    signal ex_hi_write_en: std_logic;
    signal ex_hi_write_data: word_t;
    signal ex_lo_write_en: std_logic;
    signal ex_lo_write_data: word_t;
    
    signal ex_div_dividend: word_t;
    signal ex_div_div: word_t;
    signal ex_div_quotient: word_t;
    signal ex_div_remainder: word_t;
    signal ex_div_sign: std_logic;
    signal ex_div_en: std_logic;
    signal ex_div_done: std_logic;

    signal mem_pc: word_t;
    signal mem_op: op_t;
    signal mem_funct: funct_t;
    signal mem_alu_result: word_t;
    signal mem_write_en: std_logic;
    signal mem_write_addr: reg_addr_t;
    signal mem_write_data: word_t;
    signal mem_write_mem_data: word_t;
    signal mem_hi_write_en: std_logic;
    signal mem_hi_write_data: word_t;
    signal mem_lo_write_en: std_logic;
    signal mem_lo_write_data: word_t;
    
    signal mem_pc_o: word_t;
    signal mem_op_o: op_t;
    signal mem_funct_o: funct_t;
    signal mem_write_en_o: std_logic;
    signal mem_write_addr_o: reg_addr_t;
    signal mem_write_data_o: word_t;
    signal mem_hi_write_en_o: std_logic;
    signal mem_hi_write_data_o: word_t;
    signal mem_lo_write_en_o: std_logic;
    signal mem_lo_write_data_o: word_t;

    signal wb_pc: word_t;
    signal wb_op: op_t;
    signal wb_funct: funct_t;
    signal wb_write_en: std_logic;
    signal wb_write_addr: reg_addr_t;
    signal wb_write_data: word_t;
    signal wb_hi_write_en: std_logic;
    signal wb_hi_write_data: word_t;
    signal wb_lo_write_en: std_logic;
    signal wb_lo_write_data: word_t;
begin
    comb_rst <= '0';
    
    testen <= wb_write_en;
    test_0 <= wb_write_addr;
    test_1 <= wb_write_data;
    
    reg_file_inst: reg_file
    port map
    (
        CLK => CLK,
        RST => RST,

        READ_ADDR_0 => reg_read_addr_0,
        READ_DATA_0 => reg_read_data_0,
        READ_ADDR_1 => reg_read_addr_1,
        READ_DATA_1 => reg_read_data_1,

        WRITE_EN => wb_write_en,
        WRITE_ADDR => wb_write_addr,
        WRITE_DATA => wb_write_data
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
        EX_WRITE_EN => ex_write_en_o,
        EX_WRITE_ADDR => ex_write_addr_o,
        EX_WRITE_DATA => ex_write_data,
        
        -- mem
        MEM_WRITE_EN => mem_write_en_o,
        MEM_WRITE_ADDR => mem_write_addr_o,
        MEM_WRITE_DATA => mem_write_data_o,
        
        -- wb
        WB_WRITE_EN => wb_write_en,
        WB_WRITE_ADDR => wb_write_addr,
        WB_WRITE_DATA => wb_write_data
    );
    
    hilo_inst: hilo
    port map
    (
        CLK => CLK,
        RST => RST,
        
        HI_WRITE_EN => wb_hi_write_en,
        HI_WRITE_DATA => wb_hi_write_data,
        LO_WRITE_EN => wb_lo_write_en,
        LO_WRITE_DATA => wb_lo_write_data,
        
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
        MEM_HI_WRITE_EN => mem_hi_write_en_o,
        MEM_HI_WRITE_DATA => mem_hi_write_data_o,
        MEM_LO_WRITE_EN => mem_lo_write_en_o,
        MEM_LO_WRITE_DATA => mem_lo_write_data_o,
        
        -- wb
        WB_HI_WRITE_EN => wb_hi_write_en,
        WB_HI_WRITE_DATA => wb_hi_write_data,
        WB_LO_WRITE_EN => wb_lo_write_en,
        WB_LO_WRITE_DATA => wb_lo_write_data,
        
        -- HILO content for ex
        EX_HI => ex_hi,
        EX_LO => ex_lo
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
        RST => RST,
        
        STALL_REQ => if_stall_req,
        
        PC => if_pc,
        PC_4 => if_pc_4,
        
        PC_O => if_pc_o,
        INS => if_ins,
        
        BUS_REQ => INS_BUS_REQ,
        BUS_RES => INS_BUS_RES
    );
    
    if_id_inst: if_id
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
        
        PC_O => id_pc_o,
        OP => id_op,
        FUNCT => id_funct,
        ALU_OP => id_alu_op,
        OPERAND_0 => id_operand_0,
        OPERAND_1 => id_operand_1,
        WRITE_EN => id_write_en,
        WRITE_ADDR => id_write_addr,
        WRITE_MEM_DATA => id_write_mem_data,
        IS_LOAD => id_is_load,
        
        EX_IS_LOAD => ex_is_load,
        EX_WRITE_ADDR => ex_write_addr,
		  
        BRANCH_EN => id_branch_en,
        BRANCH_PC => id_branch_pc
    );
    
    id_ex_inst: id_ex
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO

        ID_PC => id_pc_o,
        ID_OP => id_op,
        ID_FUNCT => id_funct,
        ID_ALU_OP => id_alu_op,
        ID_OPERAND_0 => id_operand_0,
        ID_OPERAND_1 => id_operand_1,
        ID_WRITE_EN => id_write_en,
        ID_WRITE_ADDR => id_write_addr,
        ID_WRITE_MEM_DATA => id_write_mem_data,
        ID_IS_LOAD => id_is_load,
        
        EX_PC => ex_pc,
        EX_OP => ex_op,
        EX_FUNCT => ex_funct,
        EX_ALU_OP => ex_alu_op,
        EX_OPERAND_0 => ex_operand_0,
        EX_OPERAND_1 => ex_operand_1,
        EX_WRITE_EN => ex_write_en,
        EX_WRITE_ADDR => ex_write_addr,
        EX_WRITE_MEM_DATA => ex_write_mem_data,
        EX_IS_LOAD => ex_is_load
    );
    
    execute_inst: execute
    port map
    (
        RST => comb_rst,
        
        STALL_REQ => ex_stall_req,

        PC => ex_pc,
        OP => ex_op,
        FUNCT => ex_funct,
        ALU_OP => ex_alu_op,
        OPERAND_0 => ex_operand_0,
        OPERAND_1 => ex_operand_1,
        WRITE_EN => ex_write_en,
        WRITE_ADDR => ex_write_addr,
        WRITE_MEM_DATA => ex_write_mem_data,
        HI => ex_hi,
        LO => ex_lo,
        
        PC_O => ex_pc_o,
        OP_O => ex_op_o,
        FUNCT_O => ex_funct_o,
        ALU_RESULT => ex_alu_result,
        WRITE_EN_O => ex_write_en_o,
        WRITE_ADDR_O => ex_write_addr_o,
        WRITE_DATA => ex_write_data,
        WRITE_MEM_DATA_O => ex_write_mem_data_o,
        HI_WRITE_EN => ex_hi_write_en,
        HI_WRITE_DATA => ex_hi_write_data,
        LO_WRITE_EN => ex_lo_write_en,
        LO_WRITE_DATA => ex_lo_write_data,
        
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
    
    ex_mem_inst: ex_mem
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO

        EX_PC => ex_pc_o,
        EX_OP => ex_op_o,
        EX_FUNCT => ex_funct_o,
        EX_ALU_RESULT => ex_alu_result,
        EX_WRITE_EN => ex_write_en_o,
        EX_WRITE_ADDR => ex_write_addr_o,
        EX_WRITE_DATA => ex_write_data,
        EX_WRITE_MEM_DATA => ex_write_mem_data_o,
        EX_HI_WRITE_EN => ex_hi_write_en,
        EX_HI_WRITE_DATA => ex_hi_write_data,
        EX_LO_WRITE_EN => ex_lo_write_en,
        EX_LO_WRITE_DATA => ex_lo_write_data,
        
        MEM_PC => mem_pc,
        MEM_OP => mem_op,
        MEM_FUNCT => mem_funct,
        MEM_ALU_RESULT => mem_alu_result,
        MEM_WRITE_EN => mem_write_en,
        MEM_WRITE_ADDR => mem_write_addr,
        MEM_WRITE_DATA => mem_write_data,
        MEM_WRITE_MEM_DATA => mem_write_mem_data,
        MEM_HI_WRITE_EN => mem_hi_write_en,
        MEM_HI_WRITE_DATA => mem_hi_write_data,
        MEM_LO_WRITE_EN => mem_lo_write_en,
        MEM_LO_WRITE_DATA => mem_lo_write_data
    );
    
    memory_access_inst: memory_access
    port map
    (
        RST => comb_rst,
        
        STALL_REQ => mem_stall_req,

        PC => mem_pc,
        OP => mem_op,
        FUNCT => mem_funct,
        ALU_RESULT => mem_alu_result,
        WRITE_EN => mem_write_en,
        WRITE_ADDR => mem_write_addr,
        WRITE_DATA => mem_write_data,
        WRITE_MEM_DATA => mem_write_mem_data,
        HI_WRITE_EN => mem_hi_write_en,
        HI_WRITE_DATA => mem_hi_write_data,
        LO_WRITE_EN => mem_lo_write_en,
        LO_WRITE_DATA => mem_lo_write_data,
        
        PC_O => mem_pc_o,
        OP_O => mem_op_o,
        FUNCT_O => mem_funct_o,
        WRITE_EN_O => mem_write_en_o,
        WRITE_ADDR_O => mem_write_addr_o,
        WRITE_DATA_O => mem_write_data_o,
        HI_WRITE_EN_O => mem_hi_write_en_o,
        HI_WRITE_DATA_O => mem_hi_write_data_o,
        LO_WRITE_EN_O => mem_lo_write_en_o,
        LO_WRITE_DATA_O => mem_lo_write_data_o,
        
        BUS_REQ => DATA_BUS_REQ,
        BUS_RES => DATA_BUS_RES
    );
    
    mem_wb_inst: mem_wb
    port map
    (
        CLK => CLK,
        RST => RST,
        
        STALL => stall,
        FLUSH => '0', -- TODO

        MEM_PC => mem_pc_o,
        MEM_OP => mem_op_o,
        MEM_FUNCT => mem_funct_o,
        MEM_WRITE_EN => mem_write_en_o,
        MEM_WRITE_ADDR => mem_write_addr_o,
        MEM_WRITE_DATA => mem_write_data_o,
        MEM_HI_WRITE_EN => mem_hi_write_en_o,
        MEM_HI_WRITE_DATA => mem_hi_write_data_o,
        MEM_LO_WRITE_EN => mem_lo_write_en_o,
        MEM_LO_WRITE_DATA => mem_lo_write_data_o,
        
        WB_PC => wb_pc,
        WB_OP => wb_op,
        WB_FUNCT => wb_funct,
        WB_WRITE_EN => wb_write_en,
        WB_WRITE_ADDR => wb_write_addr,
        WB_WRITE_DATA => wb_write_data,
        WB_HI_WRITE_EN => wb_hi_write_en,
        WB_HI_WRITE_DATA => wb_hi_write_data,
        WB_LO_WRITE_EN => wb_lo_write_en,
        WB_LO_WRITE_DATA => wb_lo_write_data
    );
end;