----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:55:42 12/05/2017 
-- Design Name: 
-- Module Name:    kerboard_ctrl - Behavioral 
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

entity keyboard_ctrl is
	port (
		rst         : in std_logic;
		clk         : in std_logic;
		
		ps2_clk     : in std_logic;
		ps2_data    : in std_logic;

		-- default to 0; set to 1 and last for 2 periods when data is ready
		data_ready  : out std_logic; 

		hold_key_value	: out std_logic_vector (15 downto 0)
	);
end keyboard_ctrl;

architecture Behavioral of keyboard_ctrl is

component keyboard_driver
port(
	clk, rst : in std_logic;
	ps2_clk, ps2_data : in std_logic;
	key_code : out std_logic_vector(7 downto 0)
);
end component;

signal keyboard_state : std_logic_vector(1 downto 0);
signal key_code_hold : std_logic_vector(7 downto 0);
signal key_code : std_logic_vector(7 downto 0);
-- Convert key_value to standard code
signal stable_key_code : std_logic_vector(7 downto 0);
signal tmp_key_value : std_logic_vector(5 downto 0);
signal hold_time : integer range 0 to 15;

begin
	hold_key_value <= get_ascii_keycode(stable_key_code);

	get_keyboard_data : keyboard_driver port map(
		rst => rst,
		clk => clk,
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		key_code => key_code
	);
	
	process(rst, clk)
	begin
		if rst = '0' then
			keyboard_state <= "00";
			data_ready <= '0';
			stable_key_code <= (others => '0');
		elsif clk'event and clk = '1' then
			if hold_time > 0 then
				hold_time <= hold_time - 1;
				data_ready <= '1';
			else
				data_ready <= '0';
			end if;
			case keyboard_state is
				when "00" =>
					if key_code = "11110000" then
						keyboard_state <= "01";
					end if;
				when "01" =>
					if key_code = "11110000" then
						keyboard_state <= "01";
					else
						if not(key_code = "00000000") then
							stable_key_code <= key_code;
							keyboard_state <= "00";
							hold_time <= 8;
						end if;
					end if;
				when others =>
			end case;
		end if;
	end process;

end Behavioral;

