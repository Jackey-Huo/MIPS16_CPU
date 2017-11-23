----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:58:41 10/29/2011 
-- Design Name: 
-- Module Name:    clk_1152 - Behavioral 
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_1152 is
    Port ( clk : in  STD_LOGIC;-- ‰»Î◊Û≤‡æß’Ò
			  clk_flash : out std_logic --256∑÷∆µ
	 );
end clk_1152;

architecture Behavioral of clk_1152 is
	signal clk256_tmp : std_logic := '0';
	signal count64 : std_logic_vector(5 downto 0);
	--signal clk256_tmp : std_logic;
begin
	clk_flash <= clk256_tmp;
	process(clk)
		variable cnt : integer := 0;
	begin
		if (clk'event and clk = '1') then
			if (cnt = 256) then
				cnt := 0;
				clk256_tmp <= not clk256_tmp;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
end Behavioral;

