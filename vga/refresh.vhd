----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:04:08 12/07/2017 
-- Design Name: 
-- Module Name:    refresh - Behavioral 
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

entity refresh is
    port (
		click : in std_logic;
		clk : in std_logic;
		rst : in std_logic;
        
        addr        : out std_logic_vector (17 downto 0);
        data        : out std_logic_vector (15 downto 0);
        ram2_write_enable   : out std_logic
    );
end refresh;

architecture Behavioral of refresh is

type refresh_state_machine is (idle, refresh, write_ram, done);

shared variable state : refresh_state_machine := idle;
shared variable intern_addr : std_logic_vector (17 downto 0) := zero18;
shared variable intern_data : std_logic_vector (15 downto 0) := zero16;
begin

    process(rst, click)
    begin
        if rst = '0' then
            state := idle;
            intern_addr := zero18;
            ram2_write_enable <= '0';
        elsif click = '0' then
            state := refresh;
            intern_addr := zero18;
            intern_data := x"0000";
        elsif clk'event and clk = '1' then
            if state = refresh then
                -- get data
                
                -- set addr
                data <= intern_data;
                addr <= intern_addr;
                ram2_write_enable <= '0';
                state := write_ram;
            elsif state = write_ram then
                ram2_write_enable <= '1';
                intern_addr := intern_addr + 1;
                intern_data := intern_data + 1;
                if intern_addr > "111111111111111110" then
                    ram2_write_enable <= '1';
                    state := idle;
                else
                    state := refresh;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

