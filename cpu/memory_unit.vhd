----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:44:45 12/07/2017 
-- Design Name: 
-- Module Name:    memory_unit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- Description: 
--
-- Dependencies: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library BASIC;
use BASIC.HELPER.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_unit is
    port (
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
end memory_unit;

architecture Behavioral of memory_unit is

    -- MEM variables
    signal me_write_enable_real            : std_logic                      := '0';
    signal ram2_write_enable_real          : std_logic                      := '0';
    signal seri_wrn_t, seri_rdn_t          : std_logic                      := '0';
    signal seri1_write_enable_real         : std_logic                      := '0';
    signal WE_ram1_t, WE_ram2_t, OE_ram2_t : std_logic                      := '0';
begin

    ------------- Memory and Serial Control Unit, pure combinational logic
    me_write_enable_real <= '0' when (rst = '0') else (me_write_enable and clk);
    ram2_write_enable_real <= '0' when (rst = '0') else (ram2_write_enable and clk);
    seri1_write_enable_real <= '0' when (rst = '0') else (seri1_write_enable and not(clk));

    -- TODO: serial read & write need further implementation, tbre tsre and data_ready not used now
    seri_rdn_t <= '1' when (rst = '0') else
                '0' when (seri1_read_enable = '1') else
                '1';
    seri_rdn <= seri_rdn_t;
    seri_wrn_t <= '1' when (rst = '0') else
                '0' when (seri1_write_enable_real = '1') else
                '1';
    seri_wrn <= seri_wrn_t;

    EN_ram1 <= '1' when ((rst = '0') or (seri1_read_enable = '1') or (seri1_write_enable = '1')) else '0';
    WE_ram1_t <= '1' when (rst = '0') else
               '1' when ((seri1_read_enable = '1') or (seri1_write_enable = '1')) else
               '0' when (me_write_enable_real = '1') else
               '1' when (me_read_enable = '1') else '1';
    WE_ram1 <= WE_ram1_t;
    disp_en <= WE_ram1_t when (me_write_addr(15 downto 13) = "111") else '1';

    OE_ram1 <= '1' when (rst = '0') else
               '1' when ((seri1_read_enable = '1') or (seri1_write_enable = '1')) else
               '0' when (me_read_enable = '1') else
               '1' when (me_write_enable = '1') else '0';
    addr_ram1 <= zero18 when(rst = '0') else
                 me_read_addr when (me_read_enable = '1') else
                 me_write_addr when (me_write_enable = '1') else
                 "00" & pc_real;
    data_ram1 <= me_write_data when ((me_write_enable_real = '1') or (seri1_write_enable = '1'))else "ZZZZZZZZZZZZZZZZ";
    mewb_readout <= data_ram1 when (me_read_enable = '1') else
                    "00000000" & data_ram1(7 downto 0) when (seri1_read_enable = '1') else
                    "00000000000000" &  seri_data_ready & (seri_tbre and seri_tsre) when (seri1_ctrl_read_en = '1') else
                    "ZZZZZZZZZZZZZZZZ";
    -- if MEM is using SRAM, insert a NOP into pipeline
    ifid_instruc_mem <= data_ram1 when ((me_read_enable = '0') and (me_write_enable = '0') and
                                        (seri1_read_enable = '0') and (seri1_write_enable = '0')) else NOP_instruc;

    --ifid_instruc_mem <= instruct when ((me_read_enable = '0') and (me_write_enable = '0') and
                                        --(seri1_read_enable = '0') and (seri1_write_enable = '0')) else NOP_instruc;

    -- RAM2 is specialized for VGA display
    EN_ram2 <= '1' when rst = '0' else '0';

    OE_ram2 <= OE_ram2_t;
    OE_ram2_t <= '1' when (rst = '0') else
               '0' when (ram2_read_enable = '1') else
               '1' when (ram2_write_enable = '1') else '0';
    
    WE_ram2 <= WE_ram2_t;
    WE_ram2_t <= '1' when (rst = '0') else
               '0' when (ram2_write_enable_real = '1') else   
               '1' when (ram2_read_enable = '1') else '1';

    addr_ram2 <= zero18 when(rst = '0') else
                ram2_read_addr when (ram2_read_enable = '1') else
                ram2_write_addr when (ram2_write_enable = '1') else
                "ZZZZZZZZZZZZZZZZZZ";

    ram2_readout <= data_ram2 when (ram2_read_enable = '1') else
                    "ZZZZZZZZZZZZZZZZ";
    data_ram2 <= ram2_write_data when ram2_write_enable_real = '1'
                                else "ZZZZZZZZZZZZZZZZ";
    
--    led(3) <= WE_ram2_t;
--    led(2) <= OE_ram2_t;
--    led(1) <= ram2_write_enable;
--    led(0) <= ram2_read_enable;
end Behavioral;

