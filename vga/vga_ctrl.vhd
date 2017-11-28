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

		r0, r1, r2, r3, r4, r5, r6, r7 : in std_logic_vector(15 downto 0);

		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);

		-- Concatenated color definition for input
		color : in std_logic_vector (8 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end vga_ctrl;

architecture Behavioral of vga_ctrl is

component fontROM is
	port (
	clka: in std_logic;
	addra: in std_logic_vector(10 downto 0);
	douta: out std_logic_vector(7 downto 0));
end component;

component vga_ctrl_480 is 
	Port(
		clk : in std_logic; -- clock forced to be 50M
		rst : in std_logic;

		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync

		fontROMAddr : out std_logic_vector (10 downto 0);
		fontROMData : in std_logic_vector (7 downto 0);

		r0, r1, r2, r3, r4, r5, r6, r7 : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);

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

signal fontROMAddr : std_logic_vector (10 downto 0) := "00000000000";
signal fontROMData : std_logic_vector (7 downto 0) := x"00";
signal dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7 : std_logic_vector(15 downto 0) := x"0000";
signal dSP, dIH, dT, d_CM, dPC : std_logic_vector(15 downto 0) := x"0000";

begin

	dr0<=r0;
	dr1<=r1;
	dr2<=r2;
	dr3<=r3;
	dr4<=r4;
	dr5<=r5;
	dr6<=r6;
	dr7<=r7;

	get_font : fontROM port map(
		clka => clk,
		addra => fontROMAddr,
		douta => fontROMData
		);

	vga480_disp : vga_ctrl_480 port map(
		clk => clk,
		rst => rst,
		Hs => Hs,
		Vs => Vs,
		fontROMAddr => fontROMAddr,
		fontROMData => fontROMData,
		r0=>dr0,
		r1=>dr1,
		r2=>dr2,
		r3=>dr3,
		r4=>dr4,
		r5=>dr5,
		r6=>dr6,
		r7=>dr7,
		PC => PC, -- : in std_logic_vector(15 downto 0);
		CM => CM, -- in std_logic_vector(15 downto 0);
		Tdata => TData, -- : in std_logic_vector(15 downto 0);
		SPdata => SPdata, -- : in std_logic_vector(15 downto 0);
		IHdata => IHdata, --: in std_logic_vector(15 downto 0);
		color => color,
		R => R,
		G => G,
		B => B
	);
end Behavioral;

