----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:23:49 12/05/2017 
-- Design Name: 
-- Module Name:    character_terminal - Behavioral 
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
library IEEE, BASIC;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use BASIC.HELPER.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_terminal is
    port(
		-- if the current pixel is colored in this app
		occupy_flag		: out std_logic;
		color			: out std_logic_vector (8 downto 0);
		
		vga_clk			: in std_logic;
		rst				: in std_logic;
		x, y			: in integer;

		fontROMAddr 	: out std_logic_vector (10 downto 0);
		fontROMData 	: in std_logic_vector (7 downto 0)
    );
end vga_terminal;

architecture Behavioral of vga_terminal is

component VGARAM IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

signal char_x, char_y : integer := 0;
signal rt, gt, bt : std_logic_vector (2 downto 0) := "000";
shared variable ascii_code : integer := 0;

begin
	color <= rt & bt & gt;
	occupy_flag <= '1' when (rt /= "000" or gt /= "000" or bt /="000") else '0';
	char_x <= x / 8;
	
	process(vga_clk, rst)
		variable dx : integer := 0;
	begin
		if rst = '0' or x < 0 then
			dx := 0;
		elsif vga_clk'event and vga_clk = '1' then
			fontROMAddr <= conv_std_logic_vector(ascii_code * 8 + y mod 8, 11);
			dx := 7 - x mod 8;
			rt <= (others => fontROMData(dx));
			gt <= (others => fontROMData(dx));
			bt <= (others => fontROMData(dx));
		end if;
	end process;

end Behavioral;

