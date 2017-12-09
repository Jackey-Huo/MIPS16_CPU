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
		clk					: in std_logic; -- clock forced to be 50M
		rst					: in std_logic;
		disp_mode			: in std_logic_vector (2 downto 0); -- select between different display app
		
		Hs 					: out std_logic; -- line sync
		Vs 					: out std_logic; -- field sync

		-- cache request
		cache_wea			: out std_logic;
		cache_read_addr		: out std_logic_vector (12 downto 0);
		cache_read_data		: in std_logic_vector (7 downto 0);

		fontROMAddr 		: out std_logic_vector (10 downto 0);
		fontROMData 		: in std_logic_vector (7 downto 0);

		-- ram2 request
		ram2_read_enable	: out std_logic;
		read_addr			: out std_logic_vector (17 downto 0);
		read_out			: inout std_logic_vector (15 downto 0);

		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		instruction : in std_logic_vector(15 downto 0);

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
		
		pos_x, pos_y : out integer range 0 to 4096
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

component vga_terminal is
    port(
		-- if the current pixel is colored in this app
		occupy_flag		: out std_logic;
		color			: out std_logic_vector (8 downto 0);
		
		vga_clk			: in std_logic;
		rst				: in std_logic;
		x, y			: in integer;
		
		cache_wea			: out std_logic;
		cache_read_addr	: out std_logic_vector (12 downto 0);
		cache_read_data	: in std_logic_vector (7 downto 0);

		fontROMAddr 	: out std_logic_vector (10 downto 0);
		fontROMData 	: in std_logic_vector (7 downto 0)
    );
end component;

component vga_image is 
    port (
        -- if the current pixel is colored in this app
        occupy_flag		: out std_logic;
        color			: out std_logic_vector (8 downto 0);
        
        vga_clk			: in std_logic;
        rst				: in std_logic;
        x, y			: in integer;

		cache_wea	: out std_logic;
        cacheAddr	: out std_logic_vector (12 downto 0);
        cacheData	: in std_logic_vector (15 downto 0)
    );
end component;

component vga_image_ram2 is
    port (
        -- if the current pixel is colored in this app
        occupy_flag		: out std_logic;
        color			: out std_logic_vector (8 downto 0);
        
        vga_clk			: in std_logic;
        rst				: in std_logic;
        x, y			: in integer;

        ram2_read_enable         : out std_logic;
        read_addr	: out std_logic_vector (17 downto 0);
        read_out : inout std_logic_vector (15 downto 0)
    );
end component;

-- clock used in computation
signal vga_clk_c : std_logic := '0';

-- column/x and row/y coordinates
signal x, y : integer range 0 to 4096;
signal right_x : integer range -2048 to 2048;

-- Hs, Vs used in computation
signal Hs_c, Vs_c : std_logic := '0';

-- verbose module variables
signal color_verbose : std_logic_vector (8 downto 0) := "000000000";
signal ocp_verbose : std_logic := '0';
-- terminal module variables
signal color_terminal : std_logic_vector (8 downto 0) := "000000000";
signal ocp_terminal : std_logic := '0';
-- image display
signal color_image		: std_logic_vector (8 downto 0) := "000000000";
signal ocp_image		: std_logic := '0';

signal fontROMAddr1, fontROMAddr2 : std_logic_vector (10 downto 0) := "00000000000";
begin
	-- Mux font ROM address access : 001 for debug
	fontROMAddr <= fontROMAddr1 when (disp_mode = "001") else fontROMAddr2;

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

--	-- show image : on the screen
--	vga_disp_image : vga_image port map(
--		occupy_flag => ocp_image,
--		color => color_image,
--		vga_clk => vga_clk_c,
--		rst => rst,
--		x => x,
--		y => y,
--		cache_wea => cache_wea,
--		cacheAddr => cacheAddr,
--		cacheData => cacheData
--	);
--

	vga_disp_image : vga_image_ram2 port map(
		occupy_flag => ocp_image,
		color => color_image,
		vga_clk => vga_clk_c,
		rst => rst,
		x => x,
		y => y,
		ram2_read_enable => ram2_read_enable,
		read_addr => read_addr,
		read_out  => read_out
	);

	-- show variables : on left side
	verbose_variable : vga_verbose port map(
		-- out
		occupy_flag => ocp_verbose,
		color => color_verbose,
		-- in
		vga_clk => vga_clk_c,
		rst => rst,
		x => x,
		y => y,
		fontROMAddr => fontROMAddr1,
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

	-- show terminal : on right side
	vga_character_terminal : vga_terminal port map(
		-- out
		occupy_flag => ocp_terminal,
		color => color_terminal,
		-- in
		vga_clk =>vga_clk_c,
		rst => rst,
		x => x,
		y => y,
		cache_wea => cache_wea,
		cache_read_addr => cache_read_addr,
		cache_read_data => cache_read_data,
		fontROMAddr => fontROMAddr2,
		fontROMData => fontROMData
	);
	
	-- mux pixel color
	process(vga_clk_c, rst)
	begin
		if rst = '0' or x > vga480_w or y > vga480_h then
			R <= "000";
			G <= "000";
			B <= "000";
		else
			if disp_mode = "001" and ocp_image = '1' then
				R <= color_image(8 downto 6);
				G <= color_image(5 downto 3);
				B <= color_image(2 downto 0);
			elsif disp_mode = "000" and ocp_verbose = '1' then
				R <= color_verbose(8 downto 6);
				G <= color_verbose(5 downto 3);
				B <= color_verbose(2 downto 0);
			elsif disp_mode = "010" then
				if ocp_terminal = '1' then
					R <= color_terminal(8 downto 6);
					G <= color_terminal(5 downto 3);
					B <= color_terminal(2 downto 0);
				else
					R <= color_image(8 downto 6);
					G <= color_image(5 downto 3);
					B <= color_image(2 downto 0);
				end if;
			else
				R <= "000";
				G <= "000";
				B <= "000";
			end if;
		end if;
	end process;

end Behavioral;

