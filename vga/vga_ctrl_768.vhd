----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:30:49 11/23/2017 
-- Design Name: 
-- Module Name:    vga_ctrl - Behavioral 
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
use BASIC.HELPER.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_ctrl_768 is
	Port(
		clk : in std_logic; -- clock forced to be 50M
		rst : in std_logic;

		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync

		-- Concatenated color definition for input
		color : in std_logic_vector (8 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end vga_ctrl_768;

architecture Behavioral of vga_ctrl_768 is

-- clock used in synchronization
signal vga_clk : std_logic := '0';
-- clock used in computation
signal vga_clk_c : std_logic := '0';

-- column/x and row/y coordinates
signal x, y : integer range 0 to 4048;

-- Hs, Vs used in computation
signal Hs_c, Vs_c : std_logic := '0';

begin

    vga_clk <= clk;
		
	-- sweep x and y
	coor_sweep : process (vga_clk, rst)
	begin
		if rst = '0' then
			x <= 0;
			y <= 0;
		elsif vga_clk'event and vga_clk = '1' then
			if x = vga768_full_w then
				x <= 0;
				if y = vga768_full_h then
	     			y <= 0;
	    		else
	     			y <= y + 1;
	    		end if;
			else
				x <= x + 1;
			end if;
		end if;
	end process;
 
	-- Synthesis Hs Sync signal
	Hs_synthesis : process (vga_clk, rst)
	begin
		if rst = '0' then
			Hs_c <= '1';
		elsif vga_clk'event and vga_clk = '1' then
			if x >= vga768_hs_start and x < vga768_hs_end then
				Hs_c <= '0';
			else
				Hs_c <= '1';
			end if;
		end if;
	end process;
 
	-- Synthesis Vs Sync signal
	Vs_synthesis : process (vga_clk, rst)
	begin
		if rst = '0' then
			Vs_c <= '1';
		elsif vga_clk'event and vga_clk = '1' then
			if y >= vga768_vs_start and y < vga768_vs_end then
				Vs_c <= '0';
			else
				Vs_c <= '1';
			end if;
		end if;
	end process;

	-- Connect computational signal to real signal
	process (vga_clk, rst)
	begin
		if rst = '0' then
			Hs <= '0';
			Vs <= '0';
		elsif vga_clk'event and vga_clk = '1' then
			Hs <= Hs_c;
			Vs <= Vs_c;
		end if;
	end process;

	-- Set color output
	color_output : process(vga_clk, rst)
	begin
		if x > vga768_w or y > vga768_h then
			R <= "000";
			G <= "000";
			B <= "000";
		else
			R <= color(8 downto 6);
			G <= color(5 downto 3);
			B <= color(2 downto 0);
		end if;
	end process;

end Behavioral;

