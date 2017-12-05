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

entity vga_ctrl_480 is
	Port(
		clk : in std_logic; -- clock forced to be 50M
		rst : in std_logic;
		
		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync
		
		fontROMAddr : out std_logic_vector (10 downto 0);
		fontROMData : in std_logic_vector (7 downto 0);

		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		instruction : in std_logic_vector(15 downto 0);

		-- Concatenated color definition for input
		color : in std_logic_vector (8 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end vga_ctrl_480;

architecture Behavioral of vga_ctrl_480 is

component vga_sweep is
	port(
		vga_clk : in std_logic; -- vga_clock
		rst : in std_logic;
		
		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync
		
		pos_x, pos_y : out integer
	);
end component;

component vga_verbose is
port(
		-- if the current pixel is colored in this app
		occupy_flag	: out std_logic;
		color				: out std_logic_vector (8 downto 0);
		
		vga_clk	: in std_logic;
		rst				: in std_logic;
		x, y	: in integer;

		fontROMAddr : out std_logic_vector (10 downto 0);
		fontROMData : in std_logic_vector (7 downto 0);
		
		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		instruction : in std_logic_vector(15 downto 0)
	);
end component;

-- clock used in computation
signal vga_clk_c : std_logic := '0';

-- column/x and row/y coordinates
signal x, y : integer range 0 to 4048;

-- Hs, Vs used in computation
signal Hs_c, Vs_c : std_logic := '0';

-- verbose module variables
signal color_verbose : std_logic_vector (8 downto 0) := "000000000";
signal ocp_verbose : std_logic := '0';

begin
	-- halve the 50M clock
	vga_clk_producer : process (clk)
	begin
		if clk'event and clk = '1' then
			vga_clk_c <= not vga_clk_c;
		end if;
	end process;
	
	-- get sweep
	sweep_screen : vga_sweep port map(
		vga_clk => vga_clk_c,
		rst => rst,
		Hs => Hs,
		Vs => Vs,
		pos_x => x,
		pos_y => y
	);

	-- show variables
	verbose_variable : vga_verbose port map(
		-- out
		occupy_flag => ocp_verbose,
		color => color_verbose,
		-- in
		vga_clk =>vga_clk_c,
		rst => rst,
		x => x,
		y => y,
		fontROMAddr => fontROMAddr,
		fontROMData => fontROMData,
		r0=>r0,
		r1=>r1,
		r2=>r2,
		r3=>r3,
		r4=>r4,
		r5=>r5,
		r6=>r6,
		r7=>r7,
		PC => PC, -- : in std_logic_vector(15 downto 0);
		CM => CM, -- in std_logic_vector(15 downto 0);
		Tdata => TData, -- : in std_logic_vector(15 downto 0);
		SPdata => SPdata, -- : in std_logic_vector(15 downto 0);
		IHdata => IHdata, --: in std_logic_vector(15 downto 0);
		instruction => instruction
	);
	
	-- mux pixel color
	process(vga_clk_c, rst)
	begin
		if rst = '0' or x > vga480_w or y > vga480_h then
			R <= "000";
			G <= "000";
			B <= "000";
		else
			if ocp_verbose = '1' then
				R <= color_verbose(8 downto 6);
				G <= color_verbose(5 downto 3);
				B <= color_verbose(2 downto 0);
			end if;
		end if;
	end process;

end Behavioral;

