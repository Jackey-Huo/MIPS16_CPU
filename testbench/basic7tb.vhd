--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:59:00 11/20/2017
-- Design Name:   
-- Module Name:   /home/jackey/My_project/VHDL/cpu/testbench/basic7tb.vhd
-- Project Name:  cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY basic7tb IS
END basic7tb;
 
ARCHITECTURE behavior OF basic7tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         data_ram1 : INOUT  std_logic_vector(15 downto 0);
         addr_ram1 : OUT  std_logic_vector(17 downto 0);
         OE_ram1 : OUT  std_logic;
         WE_ram1 : OUT  std_logic;
         EN_ram1 : OUT  std_logic;
         data_ram2 : INOUT  std_logic_vector(15 downto 0);
         addr_ram2 : OUT  std_logic_vector(17 downto 0);
         OE_ram2 : OUT  std_logic;
         WE_ram2 : OUT  std_logic;
         EN_ram2 : OUT  std_logic;
         seri_rdn : OUT  std_logic;
         seri_wrn : OUT  std_logic;
         seri_data_ready : IN  std_logic;
         seri_tbre : IN  std_logic;
         seri_tsre : IN  std_logic;
         dyp0 : OUT  std_logic_vector(6 downto 0);
         dyp1 : OUT  std_logic_vector(6 downto 0);
         led : OUT  std_logic_vector(15 downto 0);
         instruct : IN  std_logic_vector(15 downto 0);
			dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7 : out std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal seri_data_ready : std_logic := '0';
   signal seri_tbre : std_logic := '0';
   signal seri_tsre : std_logic := '0';
   signal instruct : std_logic_vector(15 downto 0) := (others => '0');

	--BiDirs
   signal data_ram1 : std_logic_vector(15 downto 0);
   signal data_ram2 : std_logic_vector(15 downto 0);

 	--Outputs
   signal addr_ram1 : std_logic_vector(17 downto 0);
   signal OE_ram1 : std_logic;
   signal WE_ram1 : std_logic;
   signal EN_ram1 : std_logic;
   signal addr_ram2 : std_logic_vector(17 downto 0);
   signal OE_ram2 : std_logic;
   signal WE_ram2 : std_logic;
   signal EN_ram2 : std_logic;
   signal seri_rdn : std_logic;
   signal seri_wrn : std_logic;
   signal dyp0 : std_logic_vector(6 downto 0);
   signal dyp1 : std_logic_vector(6 downto 0);
   signal led : std_logic_vector(15 downto 0);

	signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := x"0000";
  signal pc_real : std_logic_vector(15 downto 0) := x"0000";
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
          clk => clk,
          rst => rst,
          data_ram1 => data_ram1,
          addr_ram1 => addr_ram1,
          OE_ram1 => OE_ram1,
          WE_ram1 => WE_ram1,
          EN_ram1 => EN_ram1,
          data_ram2 => data_ram2,
          addr_ram2 => addr_ram2,
          OE_ram2 => OE_ram2,
          WE_ram2 => WE_ram2,
          EN_ram2 => EN_ram2,
          seri_rdn => seri_rdn,
          seri_wrn => seri_wrn,
          seri_data_ready => seri_data_ready,
          seri_tbre => seri_tbre,
          seri_tsre => seri_tsre,
          dyp0 => dyp0,
          dyp1 => dyp1,
          led => led,
          instruct => instruct,
			 dr0=>r0,
			 dr1=>r1,
			 dr2=>r2,
			 dr3=>r3,
			 dr4=>r4,
			 dr5=>r5,
			 dr6=>r6,
			 dr7=>r7,
       dpc_real=>pc_real
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	begin
      -- hold reset state for 100 ns.
      wait for 70 ns;	

      wait for clk_period*10;

		rst <= '0';
		rst <= '0';
		wait for clk_period;
		rst <= '1';
		wait for clk_period;

		instruct <= "0110100000001000"; -- [0000] LI R0 0x08
		wait for clk_period; --IF
		instruct <= "0110100100001100"; -- [0001] LI R1 0x0C
		wait for clk_period; --ID
		instruct <= "0110101100000100"; -- [0002] LI R3 0x04
		wait for clk_period; --EX
		instruct <= "1110000000111001"; -- [0003] ADDU R0 R1 R6       R0=0x08  R1=0x0C
		wait for clk_period; --MEM
		instruct <= "1110011000111101"; -- [0004] ADDU R6 R1 R7       R1=0x0C  R6=0x14
		wait for clk_period; --WB
    assert r0 = x"0008" report "[0000] Failed" severity error;
		instruct <= "0100100101010000"; -- [0005] ADDIU R1 0x50
		wait for clk_period;
    assert r1 = x"000c" report "[0001] Failed" severity error;
		instruct <= "0100111101010000"; -- [0006] ADDIU R7 0x50     before R7=0x20; after R7=0x70
		wait for clk_period;
    assert r3 = x"0004" report "[0002] Failed" severity error;
    instruct <= "1110000001101011"; -- [0007] SUBU R0 R3 R2
    wait for clk_period;
    assert r6 = x"0014" report "[0003] Failed" severity error;
		instruct <= "0011001001010000"; -- [0008] SLL R2 R2 4
		wait for clk_period;
    assert r7 = x"0020" report "[0004] Failed" severity error;
		instruct <= "1001100000100001"; -- [0009] LW R0 R1 0x01
		wait for clk_period;
    assert r1 = x"005c" report "[0005] Failed" severity error;
		instruct <= "0100100101010000"; -- [000A] ADDIU R1 0x50
		wait for clk_period;
    assert r7 = x"0070" report "[0006] Failed" severity error;
		instruct <= "1101100000100001"; -- [000B] SW R0 R1 0x01
		wait for clk_period;
    assert r2 = x"0008" report "[0007] Failed" severity error;
		instruct <= "0010100000001000"; -- [000C] BNEZ R0 0x08
		wait for clk_period;
    assert r2 = x"0040" report "[0008] Failed" severity error;
		instruct <= "0000100000000000"; -- NOP
		wait for clk_period;
    -- [0009]
		instruct <= "0110100010111111"; -- LI R0 0xBF
		wait for clk_period;
    -- [000A]
		instruct <= "0011000000010000"; -- SLL R0 R0 0x00
		wait for clk_period;
    -- [000B]
		instruct <= "1101100000100001"; -- SW R0 R1 0x01
		wait for clk_period;
    -- [000C]
    assert 
    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    wait for clk_period;


		wait;
   end process;

END;
