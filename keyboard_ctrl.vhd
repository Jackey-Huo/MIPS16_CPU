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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

		key_value   : out std_logic_vector(15 downto 0)
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
-- Convert key_value to standard code
signal stable_key_code : std_logic_vector(7 downto 0);
signal tmp_key_value : std_logic_vector(5 downto 0);
signal hold_time : integer range 0 to 15;

begin
	--debug_key_code_hold <= key_code_hold;
	key_value(15 downto 6) <= (others => '0');
	--key_value(15 downto 8) <= key_code_hold;
	with stable_key_code select
		key_value(5 downto 0) <= 
			"000001" when "00011100" , -- a
			"000010" when "00110010" , 
			"000011" when "00100001" , 
			"000100" when "00100011" , 
			"000101" when "00100100" , 
			"000110" when "00101011" , 
			"000111" when "00110100" , 
			"001000" when "00110011" , 
			"001001" when "01000011" , 
			"001010" when "00111011" , 
			"001011" when "01000010" , 
			"001100" when "01001011" , 
			"001101" when "00111010" , 
			"001110" when "00110001" , 
			"001111" when "01000100" , 
			"010000" when "01001101" , 
			"010001" when "00010101" , 
			"010010" when "00101101" , 
			"010011" when "00011011" , 
			"010100" when "00101100" , 
			"010101" when "00111100" , 
			"010110" when "00101010" , 
			"010111" when "00011101" , 
			"011000" when "00100010" , 
			"011001" when "00110101" , 
			"011010" when "00011010" , -- z
			"011011" when "01000001" , -- ,
			"011100" when "01001001" , -- .
			
			"110000" when "01000101" , -- 0
			"110001" when "00010110" , 
			"110010" when "00011110" , 
			"110011" when "00100110" , 
			"110100" when "00100101" , 
			"110101" when "00101110" , 
			"110110" when "00110110" , 
			"110111" when "00111101" , 
			"111000" when "00111110" , 
			"111001" when "01000110" , -- 9
			
			"100100" when "01001110" , -- -
			"100101" when "01010101" , -- =
			"100110" when "01110110" , -- ESC
			"100111" when "01100110" , -- BKSP
			"011110" when "01011010" , -- ENTER
			"000000" when "00101001" , -- SPACE
			"111111" when others;

	get_keyboard_data : keyboard_driver port map(
		rst => rst,
		clk => clk,
		ps2clk => ps2clk,
		ps2data => ps2data,
		key_code => key_code_hold
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
					if key_code_hold = "11110000" then
						keyboard_state <= "01";
					end if;
				when "01" =>
					if key_code_hold = "11110000" then
						keyboard_state <= "01";
					else
						if not(key_code_hold = "00000000") then
							stable_key_code <= key_code_hold;
							keyboard_state <= "00";
							hold_time <= 8;
						end if;
					end if;
				when others =>
			end case;
		end if;
	end process;

end Behavioral;

