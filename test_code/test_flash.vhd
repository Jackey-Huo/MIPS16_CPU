----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:15:29 11/21/2017 
-- Design Name: 
-- Module Name:    test_flash - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library basic;
use basic.helper.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_flash is
	port(
			clk : in std_logic;
			rst : in std_logic;

			flash_addr : out std_logic_vector (22 downto 1);
			flash_data : out std_logic_vector (15 downto 0);
			flash_byte : out std_logic;--BYTE#
			flash_vpen : out std_logic;
			flash_ce : out std_logic;
			flash_oe : out std_logic;
			flash_we : out std_logic;
			flash_rp : out std_logic;
			
			led : out std_logic_vector(15 downto 0)
		);
		
end test_flash;

architecture Behavioral of test_flash is

component flash_io is
    Port (
			addr : in  STD_LOGIC_VECTOR (22 downto 1);
			data_in : in  STD_LOGIC_VECTOR (15 downto 0);
			data_out : out  STD_LOGIC_VECTOR (15 downto 0);
			clk : in std_logic;
			reset : in std_logic;

			flash_byte : out std_logic;--BYTE#
			flash_vpen : out std_logic;
			flash_ce : out std_logic;
			flash_oe : out std_logic;
			flash_we : out std_logic;
			flash_rp : out std_logic;
			--flash_sts : in std_logic;
			flash_addr : out std_logic_vector(22 downto 1);
			flash_data : out std_logic_vector(15 downto 0);

			ctl_read : in  std_logic;
			ctl_write : in  std_logic;
			ctl_erase : in std_logic
	);
end component;

	signal bl_flash_addr	: std_logic_vector (22 downto 1) := "0000000000000000000000";
	signal bl_flash_datain	: std_logic_vector (15 downto 0) := zero16;
	signal bl_flash_dataout	: std_logic_vector (15 downto 0) := zero16;
	signal temp	: std_logic_vector (15 downto 0) := zero16;
	signal clk_flash 		: std_logic						 := '0';
begin
	read_flash : flash_io port map (
		addr => bl_flash_addr,
		data_in => bl_flash_datain,
		data_out => bl_flash_dataout,
		clk => clk,
		reset => rst,
		flash_byte => flash_byte,
		flash_vpen => flash_vpen,
		flash_ce => flash_ce,
		flash_oe => flash_oe,
		flash_we => flash_we,
		flash_rp => flash_rp,
		--flash_sts => flash_sts,
		flash_addr => flash_addr,
		flash_data => flash_data,
		ctl_read => '0',
		ctl_write => '1',
		ctl_erase => '1'
	);
	process(clk, rst)
	begin
		if (rst = '0') then
            bl_flash_addr <= "0000000000000000000000";
			bl_flash_datain <= zero16;
			bl_flash_dataout <= zero16;
        elsif ( clk'event and clk='1' ) then
            bl_flash_addr <= bl_flash_addr + 1;
			--led <= bl_flash_dataout;
        end if;
	end process;

	
end Behavioral;

