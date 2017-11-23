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

entity vga_ctrl is
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
end vga_ctrl;

architecture Behavioral of vga_ctrl is

component vga_ctrl_480 is 
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
end component;

component vga_ctrl_768 is
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
end component;

-- Hs, Vs used in computation
signal Hs_c, Vs_c : std_logic := '0';
signal ctrl_R, ctrl_G, ctrl_B : std_logic_vector (2 downto 0) := "000";
begin

	vga768_disp : vga_ctrl_768 port map(
		clk => clk,
		rst => rst,
		Hs => Hs,
		Vs => Vs,
		color => color,
		R => R,
		G => G,
		B => B
	);
end Behavioral;

