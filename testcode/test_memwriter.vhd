----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:45:33 12/06/2017 
-- Design Name: 
-- Module Name:    test_memwriter - Behavioral 
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

entity test_memwriter is
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        wea     : out std_logic;
        addr    : out std_logic_vector (17 downto 0);
        data    : out std_logic_vector (15 downto 0)
    );
end test_memwriter;

architecture Behavioral of test_memwriter is

signal state : std_logic_vector (3 downto 0) := "0000";
signal intern_addr : std_logic_vector (17 downto 0);
begin
	addr <= intern_addr;
	
    process(clk, rst)
    begin
        if rst = '0' then
            state <= "0000";
            intern_addr <= "00" & "111" & "1000000000000";
        elsif clk'event and clk = '1' then
            case state is
                when "0000" =>
                    -- white
                    data <= "0000000" & "111111111";
                    state <= "0001";
                    wea <= '1';
                when "0001" =>
                    intern_addr <= intern_addr + 1;
                    data <= "0000000" & "111000000";
                    state <= "0010";
                    wea <= '1';
                when "0010" =>
                    intern_addr <= intern_addr + 1;
                    data <= "0000000" & "000111000";
                    state <= "0011";
                    wea <= '1';
                when "0011" =>
                    -- screeen starts from 1000000000000
                    intern_addr <= intern_addr + 1;
                    data <= "0000000" & "000000111";
                    state <= "0100";
                    wea <= '1';
                when others =>
                    intern_addr <= "00" & "111" & "1000000000000";
                    state <= "0000";
                    wea <= '0';
            end case;
        end if; 
    end process;


end Behavioral;

