----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:15:29 11/21/2017 
-- Design Name: 
-- Module Name:    test_flash - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library basic;
use basic.helper.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_flash is
	port(
			click		: in std_logic;
			clk_50M	: in std_logic;
			rst		: in std_logic;

			-- ram1, Instruction memory
			data_ram1 : inout std_logic_vector(15 downto 0);
			addr_ram1 : out std_logic_vector(17 downto 0);
			OE_ram1   : out std_logic;
			WE_ram1   : out std_logic;
			EN_ram1   : out std_logic;
			
			-- serial
			seri_rdn        : out std_logic := '1';
			seri_wrn        : out std_logic := '1';
			seri_data_ready : in std_logic;
			seri_tbre       : in std_logic;
			seri_tsre       : in std_logic;

			-- VGA
			Hs 					: out std_logic; -- line sync
			Vs 					: out std_logic; -- field sync
			VGA_R, VGA_G, VGA_B : out std_logic_vector (2 downto 0) := "000";

			flash_addr : out std_logic_vector (22 downto 0);
			flash_data : out std_logic_vector (15 downto 0);
			flash_byte : out std_logic;--BYTE#
			flash_vpen : out std_logic;
			flash_ce : out std_logic;
			flash_oe : out std_logic;
			flash_we : out std_logic;
			flash_rp : out std_logic;
			
			led : out std_logic_vector(15 downto 0)
		);
		
end test_flash;

architecture Behavioral of test_flash is

component vga_ctrl is
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
		instruction : in std_logic_vector(15 downto 0);
		
		-- Concatenated color definition for input
		color : in std_logic_vector (8 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end component;

component clock_select is
	port(
		click		: in std_logic;
		clk_50M	: in std_logic;
		selector	: in std_logic_vector(2 downto 0);
		clk		: out std_logic;
		clk_flash: out std_logic
	);
end component;
    -- MEM variables
    signal me_read_enable, me_write_enable : std_logic                      := '0';
    signal me_write_enable_real            : std_logic                      := '0';
    signal me_read_addr, me_write_addr     : std_logic_vector (17 downto 0) := zero18;
    signal me_write_data                   : std_logic_vector (15 downto 0) := zero16;

    signal seri_wrn_t, seri_rdn_t          : std_logic                      := '0';
    signal seri1_read_enable               : std_logic                      := '0';
    signal seri1_write_enable              : std_logic                      := '0';
    signal seri1_write_enable_real         : std_logic                      := '0';
    signal seri1_ctrl_read_en              : std_logic                      := '0';

	signal bl_flash_addr	: std_logic_vector (22 downto 1) := "0000000000000000000000";
	signal bl_flash_addr_r	: std_logic_vector (22 downto 1) := "0000000000000000000000";
	
	signal bl_flash_datain	: std_logic_vector (15 downto 0) := zero16;
	signal bl_flash_dataout	: std_logic_vector (15 downto 0) := zero16;
	signal bl_flash_dataout_r : std_logic_vector (15 downto 0) := zero16;
	signal clk_flash : std_logic := '0';
	
	signal clk : std_logic := '0';

	signal ctrl_read, ctrl_write, ctrl_erase : std_logic := '1';

    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := zero16;
    signal SP, IH, T : std_logic_vector(15 downto 0) := zero16;
begin
    me_write_enable_real <= '0' when (rst = '0') else (me_write_enable and clk);
    seri1_write_enable_real <= '0' when (rst = '0') else (seri1_write_enable and not(clk));

    -- TODO: serial read & write need further implementation, tbre tsre and data_ready not used now
    seri_rdn_t <= '1' when (rst = '0') else
                '0' when (seri1_read_enable = '1') else
                '1';
    seri_rdn <= seri_rdn_t;
    seri_wrn_t <= '1' when (rst = '0') else
                '0' when (seri1_write_enable_real = '1') else
                '1';
    seri_wrn <= seri_wrn_t;

	EN_ram1 <= '1' when ((rst = '0') or (seri1_read_enable = '1') or (seri1_write_enable = '1')) else '0';
	WE_ram1 <= '1' when (rst = '0') else
				'1' when ((seri1_read_enable = '1') or (seri1_write_enable = '1')) else
				'0' when (me_write_enable_real = '1') else
				'1' when (me_read_enable = '1') else '1';
	OE_ram1 <= '1' when (rst = '0') else
				'1' when ((seri1_read_enable = '1') or (seri1_write_enable = '1')) else
				'0' when (me_read_enable = '1') else
				'1' when (me_write_enable = '1') else '0';
	addr_ram1 <= zero18 when(rst = '0') else
					me_read_addr when (me_read_enable = '1') else
					me_write_addr when (me_write_enable = '1') else
					(others => '0');
	data_ram1 <= me_write_data when ((me_write_enable_real = '1') or (seri1_write_enable = '1'))else "ZZZZZZZZZZZZZZZZ";
	
	 ------------- VGA control : show value of Registers, PC, Memory operation address, etc ----
	vga_disp : vga_ctrl port map(
		clk => clk_50M,
		rst => rst,
		Hs => Hs,
		Vs => Vs,
		-- read addr
		r0=>zero16,
		r1=>bl_flash_addr(16 downto 1),
		r2=>r2,
		r3=>r3,
		r4=>r4,
		r5=>r5,
		r6=>r6,
		r7=>r7,
		PC => bl_flash_dataout_r, -- : in std_logic_vector(15 downto 0);
		CM => zero16, -- in std_logic_vector(15 downto 0);
		Tdata => T, -- : in std_logic_vector(15 downto 0);
		SPdata => SP, -- : in std_logic_vector(15 downto 0);
		IHdata => IH, --: in std_logic_vector(15 downto 0);
		instruction => zero16,
		color => "000000000",
		R => VGA_R,
		G => VGA_G,
		B => VGA_B
	);

	clk_selector	: clock_select port map(
		click => click,
		clk_50M => clk_50M,
		selector => "000", --25M
		clk => clk,
		clk_flash => clk_flash
	);

	
	process (state, addr)
	begin
		case state is
			when flash_prepare =>
				next_state <= flash_will_set;
				digit <= not "1000000";
			when flash_will_set =>
				next_state <= flash_set;
				digit <= not "1111001";
			when flash_set =>
				next_state <= flash_will_read;
				digit <= not "0100100";
			when flash_will_read =>
				next_state <= flash_read;
				digit <= not "0110000";
			when flash_read =>
				next_state <= flash_read_finish;
				digit <= not "0011001";
			when flash_read_finish =>
				next_state <= mem_write;
				digit <= not "0010010";
			when mem_write =>
				if addr < x"01f3" then
					next_state <= flash_will_read;
				else
					next_state <= boot_finish;
				end if;
				digit <= not "0000010";
			when boot_finish =>
				next_state <= boot_finish;
				digit <= not "1111000";
			when others =>
				next_state <= flash_prepare;
				digit <= not "1111111";
		end case;
		if state = mem_write then
			next_addr <= addr + x"0001";
		else
			next_addr <= addr;
		end if;
	end process;

	led(2 downto 0) <= ctrl_erase & ctrl_write & ctrl_read;
	led(15 downto 3) <= (others => '0');
end Behavioral;

