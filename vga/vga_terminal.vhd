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

		cache_wea		: out std_logic;
		cache_read_addr	: out std_logic_vector (12 downto 0);
		cache_read_data	: in std_logic_vector (7 downto 0);

		fontROMAddr 	: out std_logic_vector (10 downto 0);
		fontROMData 	: in std_logic_vector (7 downto 0)
    );
end vga_terminal;

architecture Behavioral of vga_terminal is

signal char_x, char_y : integer := 0;
signal vec_y			: std_logic_vector (7 downto 0);
signal rt, gt, bt : std_logic_vector (2 downto 0) := "000";
shared variable ascii_code : integer := 0;

constant line_char_num : integer := 40;

begin
	color <= rt & bt & gt;
	char_x <= x / 16;
	char_y <= y / 16;
	--vec_y <= conv_std_logic_vector(char_y, 8);
	
	process(vga_clk, rst)
		variable dx : integer range -10 to 10 := 0 ;
	begin
		if rst = '0' or x < 0 then
			dx := 0;
			cache_wea <= '0';
		elsif vga_clk'event and vga_clk = '1' and char_y < line_char_num and y - char_y * 16 < 8 then
			cache_wea <= '1';
			cache_read_addr <= conv_std_logic_vector(char_x + char_y * line_char_num, 13);
			ascii_code := conv_integer(cache_read_data);
			fontROMAddr <= conv_std_logic_vector(ascii_code * 8 + y - char_y * 16, 11);
			dx := 7 - (x - char_x * 16);

			if fontROMData(dx) = '1' then
				rt <= "000";
				gt <= "000";
				bt <= "000";
				occupy_flag <= '1';
			else
				rt <= "111";
				gt <= "111";
				bt <= "111";
				occupy_flag <= '0';
			end if;

		end if;
	end process;

end Behavioral;

