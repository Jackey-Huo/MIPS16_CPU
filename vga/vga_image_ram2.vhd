----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:46:17 12/07/2017 
-- Design Name: 
-- Module Name:    vga_image_ram2 - Behavioral 
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

entity vga_image_ram2 is
    port (
        -- if the current pixel is colored in this app
        occupy_flag		: out std_logic;
        color			: out std_logic_vector (8 downto 0);
        
        vga_clk			: in std_logic;
        rst				: in std_logic;
        x, y			: in integer;

        ram2_read_enable: out std_logic;
        cacheAddr	: out std_logic_vector (17 downto 0);
        cacheData	: in std_logic_vector (15 downto 0)
    );
end vga_image_ram2;

architecture Behavioral of vga_image_ram2 is

signal intern_color : std_logic_vector (8 downto 0) := "000000000";

begin
    color <= intern_color;
    --occupy_flag <= '1' when (intern_color /= "000000000") else '0';
    process(vga_clk, rst)
        variable bx, by, ind : integer := 0;
    begin
        if rst = '0' then
            intern_color <= "000000000";
            ram2_read_enable <= '0';
        elsif vga_clk'event and vga_clk = '1' then
            occupy_flag <= '1';
            if x >= 100 and vga480_w > x and y >= 200 and vga480_h > y then
                bx := x / disp_scale_factor;
                by := y / disp_scale_factor;
                ind := by * vga480_w + bx;
                ram2_read_enable <= '1';
                cacheAddr <= conv_std_logic_vector(ind, 18);
                intern_color <= cacheData (8 downto 0);
            else
                ram2_read_enable <= '0';
                intern_color <= "000000000";
            end if;
        end if;
    end process;

end Behavioral;

