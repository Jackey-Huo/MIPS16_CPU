----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:55:17 12/05/2017 
-- Design Name: 
-- Module Name:    test_keyboard - Behavioral 
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

entity test_keyboard is
	port (
		rst: in std_logic;
		clk: in std_logic;
		
		ps2_clk: in std_logic;
		ps2_data: in std_logic;

		-- default to 0; set to 1 and last for 2 periods when data is ready
		data_ready: out std_logic; 

		key_value: out std_logic_vector (15 downto 0);

        led : out std_logic_vector (15 downto 0)
	);
end test_keyboard;

architecture Behavioral of test_keyboard is

component keyboard_ctrl is
	port (
		rst         : in std_logic;
		clk         : in std_logic;
		
		ps2_clk     : in std_logic;
		ps2_data    : in std_logic;

		-- default to 0; set to 1 and last for 2 periods when data is ready
		data_ready  : out std_logic; 

		cur_key_value   : out std_logic_vector(15 downto 0);
		hold_key_value	: out std_logic_vector(15 downto 0)
	);
end component;

signal kb_data_ready : std_logic := '0';
signal kb_key_value, kb_key_hold : std_logic_vector (15 downto 0) := x"0000";

begin
    keyboard_controller : keyboard_ctrl port map(
		rst => rst, 
		clk => clk,
		
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,

		-- default to 0; set to 1 and last for 2 periods when data is ready
		data_ready => kb_data_ready,

		hold_key_value => kb_key_hold
    );

    led <= kb_key_hold(7 downto 0) & x"00";

end Behavioral;

