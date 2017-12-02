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
		selector	: in std_logic_vector(1 downto 0);
		clk		: out std_logic
	);
end clock_select;

architecture Behavioral of clock_select is

signal clk4 : std_logic := '0';   -- four divide
signal clk2 : std_logic := '0';   -- two divide

begin
	process(clk_50M)
	begin
		case selector is
			when "00" => clk <= clk_50M;
			when "01" => clk <= click;
			when "10" => clk <= clk4;
			when "11" => clk <= clk2;
			when others => clk <= click;
		end case;
	end process;

	process(clk_50M)
		variable cnt4 : integer := 0;
	begin
		if clk_50M'event and clk_50M = '1' then
			-- four divide
			if cnt4 = 3 then
				clk4 <= not clk4;
				cnt4 := 0;
			else
				cnt4 := cnt4 + 1;
			end if;
			-- two divide
			clk2 <= not clk2;
		end if;
	end process;
end Behavioral;

