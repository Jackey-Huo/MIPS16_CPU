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

begin
	clk <= clk_50M when (selector = "00") else click;
end Behavioral;

