----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:15:13 12/05/2017 
-- Design Name: 
-- Module Name:    keyboard_driver - Behavioral 
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

entity keyboard_driver is
	port (
        clk         : in std_logic;
        rst         : in std_logic;

		ps2_clk     : in std_logic;
		ps2_data    : in std_logic;

        key_code    : out std_logic_vector(7 downto 0)
	);
end keyboard_driver;

architecture Behavioral of keyboard_driver is
    -- filtered ps2 clk
    signal clean_clk : std_logic; 
    -- filtered ps2 data
    signal clean_data : std_logic;
    signal last_clean_clk : std_logic;
    signal clk1, clk2, check : std_logic; -- 临时时钟，校验位
    signal keyboard_state : std_logic_vector(3 downto 0);
    signal data : std_logic_vector(7 downto 0);
    signal paral_data : std_logic_vector(7 downto 0);
    signal count : integer range 0 to 1000000;
begin
	clk1 <= ps2_clk when rising_edge(clk);
	clk2 <= clk1 when rising_edge(clk);
	clean_clk <= (not clk1) and clk2;
	clean_data <= ps2_data when rising_edge(clk);
	key_code <= paral_data;
	process(clk)
	begin
		if rst = '0' then
			keyboard_state <= "0000";
			check <= '1';
			paral_data <= (others => '0');
			last_clean_clk <= clean_clk;
			count <= 0;
		elsif clk'event and clk = '1' then
			last_clean_clk <= clean_clk;
			if count > 0 then
				if count = 1000000 then
					keyboard_state <= "0000";
					check <= '1';
					-- paral_data <= (others => '0');
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
			
			if last_clean_clk = '0' and clean_clk = '1' then
				case keyboard_state is
					when "0000" => --read ps2 data
						if clean_data = '0' then
							keyboard_state <= "0010";
							check <= '1';
							-- paral_data <= (others => '0');
							count <= 1;
						else
							keyboard_state <= "0000";
						end if;
					when "0010" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(0) <= clean_data;
						keyboard_state <= "0011";
					when "0011" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(1) <= clean_data;
						keyboard_state <= "0100";
					when "0100" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(2) <= clean_data;
						keyboard_state <= "0101";
					when "0101" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(3) <= clean_data;
						keyboard_state <= "0110";
					when "0110" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(4) <= clean_data;
						keyboard_state <= "0111";
					when "0111" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(5) <= clean_data;
						keyboard_state <= "1000";
					when "1000" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(6) <= clean_data;
						keyboard_state <= "1001";
					when "1001" => --read ps2 data
						if clean_data = '1' then
							check <= not check;
						end if;
						data(7) <= clean_data;
						keyboard_state <= "1010";
					when "1010" => --check ps2 data
						if check = clean_data then
							keyboard_state <= "1011";
						else
							keyboard_state <= "0000";
							count <= 0;
						end if;
					when "1011" => -- end state
						if clean_data = '1' then
							paral_data <= data;
							count <= 0;
						end if;
						keyboard_state <= "0000";
					when others => 
						keyboard_state <= "0000";
				end case;
			end if;
		end if;
	end process;
end Behavioral;

