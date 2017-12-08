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

    component flash_manager is
        port(
            not_boot            : in std_logic;
            clk                 : in  std_logic;
            event_clk           : in std_logic;
            rst                 : in  std_logic;
            
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
            ram1_data, ram2_data    : out std_logic_vector (15 downto 0);
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
    		disp_mode			: in std_logic; -- select between different display app
            
            Hs			: out std_logic; -- line sync
            Vs			: out std_logic; -- field sync
            cache_wea	: out std_logic;
		    ram2_read_enable 	: out std_logic;
            cache_WE		: in std_logic;
            -- mem_addr is (17 downto 0) , mem_addr <= "00" & "111" & disp_addr
            disp_addr	: out std_logic_vector (17 downto 0);
            disp_data	: in std_logic_vector (15 downto 0);

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
            int_flag        : out std_logic;
            epc             : out std_logic_vector (15 downto 0);
            cause           : out std_logic_vector (15 downto 0)
        );
    end component;
-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

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
