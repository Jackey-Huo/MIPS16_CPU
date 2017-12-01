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
			clock	: in std_logic;
			rst : in std_logic;

			rdn,wrn : out std_logic;

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

component clk_1152
Port ( clk : in  STD_LOGIC;--ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½à¾§ï¿½ï¿
		clk_flash : out std_logic
	);
end component;

component flash_io is
    port (
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
	signal bl_flash_addr_r	: std_logic_vector (22 downto 1) := "0000000000000000000000";
	
	signal bl_flash_datain	: std_logic_vector (15 downto 0) := zero16;
	signal bl_flash_dataout	: std_logic_vector (15 downto 0) := zero16;
	signal bl_flash_dataout_r : std_logic_vector (15 downto 0) := zero16;
	signal clk_flash : std_logic := '0';
	signal temp_clock : std_logic := '0';
	signal clk10 : std_logic := '0';

	signal ctrl_read, ctrl_write, ctrl_erease : std_logic := '1';
begin
--	clk_producer : process(clock, rst)
--		variable cnt : integer := 0;
--	begin
--		if rst = '0' then
--			cnt := 0;
--			clk_flash <= '0';
--		elsif (clock'event and clock = '0') then
--			cnt := cnt + 1;
--			if cnt = 4 then
--				cnt := 0;
--				clk_flash <= not clk_flash;
--			end if;
--		end if;
--	end process;
	wrn <= '1';
	rdn <= '1';

	clk_producer: clk_1152 PORT MAP (
		clk => clock,
		clk_flash => clk_flash);

	read_flash : flash_io port map (
		addr => bl_flash_addr,
		data_in => bl_flash_datain,
		data_out => bl_flash_dataout,
		clk => clk_flash,
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
		ctl_read => ctrl_read,
		ctl_write => ctrl_write,
		ctl_erase => ctrl_erease
	);

	process(clk, rst)
		variable cnt : integer := 0;
	begin
		--bl_flash_dataout <= sig_flash_dataout and rst;
		if (rst = '0') then
			ctrl_erease <= '1';
			ctrl_write <= '1';
			ctrl_read <= '1';
			bl_flash_dataout_r <= zero16;
			bl_flash_addr <= "0000000000000000000001";
			bl_flash_datain <= zero16;
		elsif ( clk'event and clk = '1') then
			ctrl_erease <= '1';
			ctrl_write <= '1';
			ctrl_read <= not ctrl_read;
			if cnt = 10 then
				cnt := 0;
				bl_flash_addr <= bl_flash_addr + 1;
			else
				cnt := cnt + 1;
			end if;
			bl_flash_dataout_r <= bl_flash_dataout;
			bl_flash_addr_r <= bl_flash_addr;
		end if;
	end process;

	led(7 downto 0) <= bl_flash_dataout_r(7 downto 0);
	led(8) <= ctrl_read;
	led(9) <= clk10;
	led(15 downto 10) <= bl_flash_addr_r(6 downto 1);
end Behavioral;

