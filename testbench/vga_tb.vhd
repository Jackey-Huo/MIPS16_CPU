--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:09:49 11/28/2017
-- Design Name:   
-- Module Name:   C:/Users/jianjinxu/Desktop/cpu/testbench/vga_tb.vhd
-- Project Name:  cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: test_vga
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
 
ENTITY vga_tb IS
END vga_tb;
 
ARCHITECTURE behavior OF vga_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT test_vga
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         Hs : OUT  std_logic;
         Vs : OUT  std_logic;
         R : OUT  std_logic_vector(2 downto 0);
         G : OUT  std_logic_vector(2 downto 0);
         B : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal Hs : std_logic;
   signal Vs : std_logic;
   signal R : std_logic_vector(2 downto 0);
   signal G : std_logic_vector(2 downto 0);
   signal B : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: test_vga PORT MAP (
          clk => clk,
          rst => rst,
          Hs => Hs,
          Vs => Vs,
          R => R,
          G => G,
          B => B
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
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		rst <= '0';
		wait for clk_period;
		rst <= '1';

      wait;
   end process;

END;
