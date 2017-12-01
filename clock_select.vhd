----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:45:18 11/28/2017 
-- Design Name: 
-- Module Name:    clock_select - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_select is
	port(
		click		: in std_logic;
		clk_50M	: in std_logic;
		selector	: in std_logic_vector(2 downto 0);
		clk		: out std_logic;
		clk_flash: out std_logic
	);
end clock_select;

architecture Behavioral of clock_select is

signal clk_125, clk_25 : std_logic := '0';
-- flash uses 256 divide frequency
signal clk_flash_c : std_logic := '0';
begin
	clk_flash <= clk_flash_c;
	process(clk_50M)
	begin
		case selector is
			when "000" => clk <= clk_50M;
			when "001" => clk <= click;
			when "010" => clk <= clk_25;
			when "011" => clk <= clk_125;
			when others => clk <= click;
		end case;
	end process;

	process(clk_50M)
		variable cnt_125, cnt_25, cnt_flash : integer := 0;
	begin
		if clk_50M'event and clk_50M = '1' then
			-- four divide
			if cnt_125 = 3 then
				clk_125 <= not clk_125;
				cnt_125 := 0;
			else
				cnt_125 := cnt_125 + 1;
			end if;
			-- two divide
			if cnt_25 = 1 then
				clk_25 <= not clk_25;
				cnt_25 := 0;
			else
				cnt_25 := cnt_25 + 1;
			end if;
			-- 256 divide for flash
			if cnt_flash = 255 then
				cnt_flash := 0;
				clk_flash_c <= not clk_flash_c;
			else
				cnt_flash := cnt_flash + 1;
			end if;
		end if;
	end process;
end Behavioral;

