----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:11:45 12/06/2017 
-- Design Name: 
-- Module Name:    vga_image - Behavioral 
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

entity vga_image is
    port (
        -- if the current pixel is colored in this app
        occupy_flag		: out std_logic;
        color			: out std_logic_vector (8 downto 0);
        
        vga_clk			: in std_logic;
        rst				: in std_logic;
        x, y			: in integer;

        cache_wea   : out std_logic;
        cacheAddr	: out std_logic_vector (12 downto 0);
        cacheData	: in std_logic_vector (15 downto 0)
    );
end vga_image;

architecture Behavioral of vga_image is

signal intern_color : std_logic_vector (8 downto 0) := "000000000";

begin
    color <= intern_color;
    occupy_flag <= '1' when (intern_color /= "000000000") else '0';
    process(vga_clk, rst)
        variable bx, by, ind : integer := 0;
    begin
        if rst = '0' then
            intern_color <= "000000000";
            cache_wea <= '0';
        elsif vga_clk'event and vga_clk = '1' then
            if x >= vga480_center_x - half_width and vga480_center_x + half_width > x and
                y >= vga480_center_y - half_height and vga480_center_y + half_width > y then
                bx := (x - vga480_center_x + half_width) / disp_scale_factor;
                by := (y - vga480_center_y + half_height) / disp_scale_factor;
                -- in window :
                ind := by * half_width * 2 + bx;
                cache_wea <= '1';
                cacheAddr <= conv_std_logic_vector(ind, 13);
                intern_color <= cacheData (8 downto 0);
                --intern_color <= "111000000";
            else
                cache_wea <= '0';
                intern_color <= "000000000";
            end if;
            
        end if;
    end process;


end Behavioral;

