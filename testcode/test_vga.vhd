----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:13:15 11/23/2017 
-- Design Name: 
-- Module Name:    test_vga - Behavioral 
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

entity test_vga is
	port(
		clk : in std_logic;
		rst : in std_logic;

		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0);
		
		-- debug
		led : out std_logic_vector(15 downto 0)
	);

end test_vga;

architecture Behavioral of test_vga is

component vga_ctrl is
	port(
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
end component;

-- signal ctrl_Hs, ctrl_Vs : std_logic := '0';
signal ctrl_R, ctrl_G, ctrl_B : std_logic_vector(2 downto 0) := "000";
signal ctrl_color : std_logic_vector (8 downto 0) := "000000000";
signal R_r, G_r, B_r : std_logic_vector(2 downto 0) := "000";
begin

	ctrl_color <= "000000111";
	
	u1 : vga_ctrl port map(
		clk => clk,
		rst => rst,
		Hs => Hs, -- line sync
		Vs => Vs, -- field sync
		-- Concatenated color definition for input
		color => ctrl_color,
		-- Separate color definition for output
		R => ctrl_R,
		G => ctrl_G,
		B => ctrl_B
	);
	
	R <= ctrl_R;
	G <= ctrl_G;
	B <= ctrl_B;
	
	process(clk)
	begin
		if clk'event and clk = '1' then
			R_r <= ctrl_R;
			G_r <= ctrl_G;
			B_r <= ctrl_B;
		end if;
	end process;
	
	
	led(8 downto 0) <= R_r & G_r & B_r;
	led(15 downto 9) <= (others => '0');
end Behavioral;

