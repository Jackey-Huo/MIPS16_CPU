--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:07:46 11/23/2017
-- Design Name:   
-- Module Name:   D:/CPU/cpu/testbench/tf.vhd
-- Project Name:  cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clk_1152
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
 
ENTITY tf IS
END tf;
 
ARCHITECTURE behavior OF tf IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clk_1152
    PORT(
         clk : IN  std_logic;
         clk_flash : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';

 	--Outputs
   signal clk_flash : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk_flash_period : time := 10 ns;
   constant clk5000_period : time := 10 ns;
   constant clk10_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clk_1152 PORT MAP (
          clk => clk,
          clk_flash => clk_flash
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

      wait for clk_period*256;

      -- insert stimulus here 


      wait;
   end process;

END;
