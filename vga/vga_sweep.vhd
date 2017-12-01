----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:41:41 12/01/2017 
-- Design Name: 
-- Module Name:    vga_sweep - Behavioral 
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

entity vga_sweep is
	port(
		clk : in std_logic; -- clock forced to be 50M
		rst : in std_logic;
		
		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync
		
		pos_x, pos_y : out integer
	);
end vga_sweep;

architecture Behavioral of vga_sweep is

-- clock used in synchronization
signal vga_clk : std_logic := '0';
-- clock used in computation
signal vga_clk_c : std_logic := '0';

-- column/x and row/y coordinates
signal x, y : integer range 0 to 4048;

-- Hs, Vs used in computation
signal Hs_c, Vs_c : std_logic := '0';

begin
	pos_x <= x;
	pos_y <= y;
	vga_clk <= vga_clk_c;

	-- halve the 50M clock
	vga_clk_producer : process (clk)
	begin
		if clk'event and clk = '1' then
			vga_clk_c <= not vga_clk_c;
		end if;
	end process;
		

	-- sweep x and y
	coor_sweep : process (vga_clk, rst)
	begin
		if rst = '0' then
			x <= 0;
			y <= 0;
		elsif vga_clk'event and vga_clk = '1' then
			if x = vga480_full_w then
				x <= 0;
				if y = vga480_full_h then
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
			if x >= vga480_hs_start and x < vga480_hs_end then
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
			if y >= vga480_vs_start and y < vga480_vs_end then
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


end Behavioral;

