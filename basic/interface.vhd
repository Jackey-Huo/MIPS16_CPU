--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library BASIC;
use BASIC.HELPER.ALL;

package interface is

    component refresh is
        port (
            click : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            
            addr        : out std_logic_vector (17 downto 0);
            data        : out std_logic_vector (15 downto 0);
            ram2_write_enable   : out std_logic
        );
    end component;

    component flash_manager is
        port(
            not_boot            : in std_logic;
            clk                 : in  std_logic;
            event_clk           : in std_logic;
            rst                 : in  std_logic;

            load_finish_flag    : out std_logic;
            boot_finish_flag    : out std_logic := '0';
            flash_byte : out  std_logic;
            flash_vpen : out  std_logic;
            flash_ce : out  std_logic;
            flash_oe : out  std_logic;
            flash_we : out  std_logic;
            flash_rp : out  std_logic;
            flash_addr : out  std_logic_vector (22 downto 0);
            flash_data : inout  std_logic_vector (15 downto 0);

            ram1_addr, ram2_addr    : out std_logic_vector (17 downto 0);
            ram1_data, ram2_data    : inout std_logic_vector (15 downto 0);
            ram1_write_enable, ram1_read_enable : out std_logic;
            ram2_write_enable, ram2_read_enable : out std_logic;
            digit  : out std_logic_vector (6 downto 0)
        );
    end component;

    component memory_unit is
        port(
            clk         : in std_logic;
            rst         : in std_logic;

            -- ram1, Instruction memory
            data_ram1   : inout std_logic_vector(15 downto 0);
            addr_ram1   : out std_logic_vector(17 downto 0);
            OE_ram1     : out std_logic;
            WE_ram1     : out std_logic;
            EN_ram1     : out std_logic;

            -- ram2, Data memory
            data_ram2   : inout std_logic_vector(15 downto 0);
            addr_ram2   : out std_logic_vector(17 downto 0);
            OE_ram2     : out std_logic := '1';
            WE_ram2     : out std_logic := '1';
            EN_ram2     : out std_logic := '1';

            -- serial
            seri_rdn        : out std_logic := '1';
            seri_wrn        : out std_logic := '1';
            seri_data_ready : in std_logic;
            seri_tbre       : in std_logic;
            seri_tsre       : in std_logic;

            disp_en             : out std_logic;
            mewb_readout        : out std_logic_vector (15 downto 0);
            ifid_instruc_mem    : out std_logic_vector (15 downto 0);
            me_write_enable     : in std_logic;
            me_read_enable      : in std_logic;
            me_read_addr        : in std_logic_vector (17 downto 0);
            me_write_addr       : in std_logic_vector (17 downto 0);
            me_write_data       : in std_logic_vector (15 downto 0);
            pc_real             : in std_logic_vector (15 downto 0);
            seri1_write_enable  : in std_logic;
            seri1_read_enable   : in std_logic;
            seri1_ctrl_read_en  : in std_logic;
            
            ram2_readout        : out std_logic_vector (15 downto 0);
            ram2_write_enable   : in std_logic;
            ram2_read_enable    : in std_logic;
            ram2_read_addr      : in std_logic_vector (17 downto 0);
            ram2_write_addr     : in std_logic_vector (17 downto 0);
            ram2_write_data		: in std_logic_vector (15 downto 0)
        );
    end component;


    component ID is
        port (
            clk, rst                        : in std_logic;

            -- boot finish flag
            boot_finish                     : in std_logic;

            -- Control Unit
            ctrl_insert_bubble              : in std_logic;

            -- hard keyboard interrupt
            hard_int_flag                   : in std_logic;
            ps2_hold_key_value              : in std_logic_vector (15 downto 0);

            -- IF/ID pipeline storage
            ifid_instruc                    : in std_logic_vector (15 downto 0);

            -- branch signal
            id_pc_branch                    : out std_logic                      := '0';

            id_instruc                      : out std_logic_vector (15 downto 0) := zero16;

            -- ID/EX
            idex_instruc                    : out std_logic_vector (15 downto 0) := zero16;
            idex_reg_a_data                 : out std_logic_vector (15 downto 0) := zero16;
            idex_reg_a_data_real            : in  std_logic_vector (15 downto 0) := zero16;
            idex_reg_b_data                 : out std_logic_vector (15 downto 0) := zero16;
            idex_reg_b_data_real            : in  std_logic_vector (15 downto 0) := zero16;
            idex_bypass                     : out std_logic_vector (15 downto 0) := zero16;
            idex_bypass_real                : in  std_logic_vector (15 downto 0) := zero16;
            idex_reg_wb                     : out std_logic_vector (3 downto 0)  := "0000";

            -- Register
            r0, r1, r2, r3, r4, r5, r6, r7  : in  std_logic_vector (15 downto 0) := zero16;
            SP, IH, T                       : in  std_logic_vector (15 downto 0) := zero16;
            EPC, Cause                      : in  std_logic_vector (15 downto 0) := zero16;
            pc_real                         : in  std_logic_vector (15 downto 0)
            );
    end component;

    component EXE is
        port (
            clk, rst                        : in std_logic;

            -- Control unit signal
            ctrl_insert_bubble              : in  std_logic;
            -- boot loader
            boot_finish                     : in  std_logic;

            -- ID/EX
            idex_instruc                    : in  std_logic_vector (15 downto 0);
            idex_reg_a_data_real            : in  std_logic_vector (15 downto 0);
            idex_reg_b_data_real            : in  std_logic_vector (15 downto 0);
            idex_bypass_real                : in  std_logic_vector (15 downto 0);
            idex_reg_wb                     : in  std_logic_vector (3 downto 0) ;

            -- EX layer variables
            ex_reg_a_data, ex_reg_b_data    : out std_logic_vector (15 downto 0) := zero16;
            ex_alu_op                       : out std_logic_vector (3 downto 0)  := "0000";

            -- EX/MEM pipeline storage
            exme_instruc                    : out std_logic_vector (15 downto 0)  := zero16;
            -- NOTICE: carry and overflow is not required
            exme_reg_wb                     : out std_logic_vector (3 downto 0)  := "0000";
            exme_bypass                     : out std_logic_vector (15 downto 0) := zero16
        );
    end component;


    component MEM is
        port (
            clk, rst                        : in std_logic;

            -- flash load
            flash_load_finish               : in std_logic;
            boot_ram2_read_enable           : in std_logic;
            boot_ram2_write_enable          : in std_logic;
            boot_ram2_write_addr            : in std_logic_vector (17 downto 0);
            boot_ram2_write_data            : in std_logic_vector (15 downto 0);

            -- vga
            vga_ram2_read_addr              : in std_logic_vector;
            vga_ram2_read_enable            : in std_logic;

            boot_finish                     : in std_logic;
            boot_write_addr                 : in std_logic_vector (17 downto 0);
            boot_write_data                 : in std_logic_vector (15 downto 0);
            boot_write_enable               : in std_logic;
            boot_read_enable                : in std_logic;

            -- EX/MEM pipeline storage
            exme_instruc                    : in std_logic_vector (15 downto 0);
            exme_result                     : in std_logic_vector (15 downto 0);
            exme_reg_wb                     : in std_logic_vector (3 downto 0) ;
            exme_bypass                     : in std_logic_vector (15 downto 0);

            -- MEM variables
            me_read_enable                  : out std_logic                      := '0';
            me_write_enable                 : out std_logic                      := '0';
            me_read_addr                    : out std_logic_vector (17 downto 0) := zero18;
            me_write_addr                   : out std_logic_vector (17 downto 0) := zero18;
            me_write_data                   : out std_logic_vector (15 downto 0) := zero16;

            ram2_read_enable                : out std_logic                      := '0';
            ram2_write_enable               : out std_logic                      := '0';
            ram2_read_addr, ram2_write_addr : out std_logic_vector (17 downto 0) := zero18;
            ram2_write_data                 : out std_logic_vector (15 downto 0) := zero16;

            seri1_read_enable               : out std_logic                      := '0';
            seri1_write_enable              : out std_logic                      := '0';
            seri1_ctrl_read_en              : out std_logic                      := '0';

            -- hard int address
            hardint_keyboard_addr           : in std_logic_vector (15 downto 0);

            --MEM/WB pipeline storage
            mewb_instruc                    : out std_logic_vector (15 downto 0) := zero16;
            mewb_result                     : out std_logic_vector (15 downto 0) := zero16;
            mewb_reg_wb                     : out std_logic_vector (3 downto 0)  := "0000";
            mewb_bypass                     : out std_logic_vector (15 downto 0) := zero16

        );
    end component;


    component WB is
        port (
            clk, rst                        : in std_logic;

            boot_finish                     : in std_logic;

            --MEM/WB pipeline storage
            mewb_instruc                    : in std_logic_vector (15 downto 0);
            mewb_result                     : in std_logic_vector (15 downto 0);
            mewb_readout                    : in std_logic_vector (15 downto 0);
            mewb_reg_wb                     : in std_logic_vector (3 downto 0);
            mewb_bypass                     : in std_logic_vector (15 downto 0);

            wb_reg_data                     : out std_logic_vector (15 downto 0) := zero16;

            -- register
            r0, r1, r2, r3, r4, r5, r6, r7  : out std_logic_vector (15 downto 0) := zero16;
            SP, IH, T                       : out std_logic_vector (15 downto 0) := zero16
        );
    end component;

    component Control is
        port (
            clk, rst                   : in std_logic;

            id_instruc                 : in std_logic_vector (15 downto 0);
            ifid_instruc               : in std_logic_vector (15 downto 0);

            boot_finish                : in std_logic;

            -- hard int signal
            hard_int_flag              : in std_logic;
            hard_int_insert_bubble     : out std_logic;

            -- Control Unit output
            ctrl_mux_reg_a             : out std_logic_vector (2 downto 0) := "000";
            ctrl_mux_reg_b             : out std_logic_vector (2 downto 0) := "000";
            ctrl_mux_bypass            : out std_logic_vector (2 downto 0) := "000";
            ctrl_insert_bubble         : out std_logic                     := '0'

        );
    end component;



    -- component
    component alu is
        port (
            rst                             : in std_logic;
            reg_a, reg_b                    : in std_logic_vector(15 downto 0);
            alu_op                          : in std_logic_vector(3 downto 0);
            result                          : out std_logic_vector(15 downto 0);
            carry_flag, zero_flag, ovr_flag : out std_logic
        );
    end component alu;

    component mux7to1 is
        port (
            output       : out std_logic_vector (15 downto 0) := zero16;
            ctrl_mux     : in std_logic_vector (2 downto 0);
            default_data : in std_logic_vector (15 downto 0);
            alu_result   : in std_logic_vector (15 downto 0);
            mewb_result  : in std_logic_vector (15 downto 0);
            mewb_readout : in std_logic_vector (15 downto 0);
            wb_reg_data  : in std_logic_vector (15 downto 0);
            exme_bypass  : in std_logic_vector (15 downto 0);
            mewb_bypass  : in std_logic_vector (15 downto 0)
        );
    end component mux7to1;

    component bootloader is
        Port (
            not_boot  : in std_logic;
            clk : in  std_logic;
            rst : in  std_logic;
            boot_finish_flag : out std_logic;
            flash_byte : out  std_logic;
            flash_vpen : out  std_logic;
            flash_ce : out  std_logic;
            flash_oe : out  std_logic;
            flash_we : out  std_logic;
            flash_rp : out  std_logic;
            flash_addr : out  std_logic_vector (22 downto 0);
            flash_data : inout  std_logic_vector (15 downto 0);

            memory_address : out std_logic_vector(17 downto 0);
            memory_data_bus : inout std_logic_vector(15 downto 0);

            memory_write_enable : out std_logic;
            memory_read_enable : out std_logic;
            digit : out  std_logic_vector (6 downto 0)
        );
    end component;

    component vga_ctrl is
        Port(
            clk			: in std_logic; -- clock forced to be 50M
            rst			: in std_logic;

            disp_mode	: in std_logic_vector (2 downto 0);

            Hs			: out std_logic; -- line sync
            Vs			: out std_logic; -- field sync
            cache_wea	: out std_logic;
            ram2_read_enable		: out std_logic;
            
            cache_WE	: in std_logic;
            -- mem_addr is (17 downto 0) , mem_addr <= "00" & "111" & disp_addr
            disp_addr	: out std_logic_vector (17 downto 0);
            disp_data	: inout std_logic_vector (15 downto 0);

            r0, r1, r2, r3, r4, r5, r6, r7 : in std_logic_vector(15 downto 0);

            PC : in std_logic_vector(15 downto 0);
            CM : in std_logic_vector(15 downto 0);
            Tdata : in std_logic_vector(15 downto 0);
            SPdata : in std_logic_vector(15 downto 0);
            IHdata : in std_logic_vector(15 downto 0);
            instruction : in std_logic_vector(15 downto 0);

            -- Separate color definition for output
            R : out std_logic_vector(2 downto 0);
            G : out std_logic_vector(2 downto 0);
            B : out std_logic_vector(2 downto 0)
        );
    end component;

    component clock_select is
        port(
            click       : in std_logic;
            clk_50M : in std_logic;
            selector    : in std_logic_vector(2 downto 0);
            clk     : out std_logic;
            clk_flash: out std_logic
        );
    end component;

    component int_ctrl is
        port(
            clk             : in std_logic;
            rst             : in std_logic;
            -- current instruction for software INT
            cur_pc          : in std_logic_vector (15 downto 0);
            -- current instruction for software INT
            cur_instruc     : in std_logic_vector (15 downto 0);
            -- interrupt control regitster
            IH              : in std_logic_vector (15 downto 0);

            -- for hardware interrupt trigger
            ps2_data_ready  : in std_logic;
            hard_int_flag   : out std_logic;

            epc             : out std_logic_vector (15 downto 0);
            cause           : out std_logic_vector (15 downto 0)
        );
    end component;

    component keyboard_ctrl is
        port (
            rst             : in std_logic;
            clk             : in std_logic;
            ps2_clk         : in std_logic;
            ps2_data        : in std_logic;

            -- default to 0; set 1 and last for 2 periods when data is ready
            data_ready      : out std_logic;
            hold_key_value  : out std_logic_vector (15 downto 0)
        );
    end component;

end interface;

package body interface is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end interface;
