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
library basic;
use basic.helper.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_vga is
	port(
		click : in std_logic;
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
	Port(
		clk : in std_logic; -- clock forced to be 50M
		rst : in std_logic;
		
		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync

		disp_en		: in std_logic;
		-- mem_addr is (17 downto 0) , mem_addr <= "00" & "111" & disp_addr
		disp_addr	: in std_logic_vector (12 downto 0);
		disp_data	: in std_logic_vector (15 downto 0);

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

component test_memwriter is
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        wea     : out std_logic;
        addr    : out std_logic_vector (17 downto 0);
        data    : out std_logic_vector (15 downto 0)
    );
end component;

-- signal ctrl_Hs, ctrl_Vs : std_logic := '0';
signal ctrl_R, ctrl_G, ctrl_B : std_logic_vector(2 downto 0) := "000";
signal ctrl_color : std_logic_vector (8 downto 0) := "000000000";
signal R_r, G_r, B_r : std_logic_vector(2 downto 0) := "000";

-- simulated signals for debugging
signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := x"10AF";
signal SP, IH, T, CM, PC : std_logic_vector(15 downto 0) := x"0000";

signal WE_ram1 : std_logic := '0';
signal testmem_wea : std_logic := '0';
signal addr_ram1 : std_logic_vector(17 downto 0);
signal disp_addr : std_logic_vector (12 downto 0) := "0000000000000";
signal disp_data : std_logic_vector (15 downto 0) := x"0000";
begin

	ctrl_color <= "000000111";

	test_mem : test_memwriter port map(
		clk => click,
		rst => rst,
		wea => WE_ram1,
		addr => addr_ram1,
		data => disp_data
	);

	disp_addr <= addr_ram1 (12 downto 0);
	vga_ctrl_comp : vga_ctrl port map(
		clk => clk,
		rst => rst,
		Hs => Hs,
		Vs => Vs,
		disp_en => WE_ram1,
		disp_addr => disp_addr,
		disp_data => disp_data,
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
		Tdata => T, -- : in std_logic_vector(15 downto 0);
		SPdata => SP, -- : in std_logic_vector(15 downto 0);
		IHdata => IH, --: in std_logic_vector(15 downto 0);
		color => "000000000",
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

	led(15 downto 8) <= addr_ram1(7 downto 0);
	led(7 downto 0) <= disp_data(7 downto 0);
	
end Behavioral;

