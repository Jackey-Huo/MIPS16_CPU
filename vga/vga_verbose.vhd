----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:42:26 12/05/2017 
-- Design Name: 
-- Module Name:    vga_verbose - Behavioral 
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

entity vga_verbose is
port(
		-- if the current pixel is colored in this app
		occupy_flag	: out std_logic;
		color				: out std_logic_vector (8 downto 0);
		
		vga_clk	: in std_logic;
		rst				: in std_logic;
		x, y			: in integer;

		fontROMAddr : out std_logic_vector (10 downto 0);
		fontROMData : in std_logic_vector (7 downto 0);

		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		instruction : in std_logic_vector(15 downto 0)
	);
end vga_verbose;

architecture Behavioral of vga_verbose is

signal rt, gt, bt : std_logic_vector (2 downto 0) := "000";

shared variable dx : integer range 0 to 7;
shared variable inty,tmp : integer range 0 to 500;

begin
	color <= rt & gt & bt;
	occupy_flag <= '1' when (rt /= "000" or gt /= "000" or bt /= "000") else '0';

	-- Set character
	character : process(vga_clk, rst)
	begin
		if rst = '0' then
			rt <= "000";
			gt <= "000";
			bt <= "000";
		elsif(vga_clk'event and vga_clk='1')then 
			if (x >= 39 and x <= 47) then
				if (y >= 64 and y <= 71) or (y >= 80 and y <= 87) or (y >= 96 and y <= 103) or (y >= 112 and y <= 119)
					or (y >= 128 and y <= 135) or (y >= 144 and y <= 151) or (y >= 160 and y <= 167) or (y >= 176 and y<= 183)
					then
					if x = 39 then
						inty := y;
						fontROMAddr <= conv_std_logic_vector(82 * 8 + inty mod 8,11);--R
					else
						dx := 7 - (x - 40);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 49 and x <= 57) then
				if (y >= 64 and y <= 71) or (y >= 80 and y <= 87) or (y >= 96 and y <= 103) or (y >= 112 and y <= 119)
					or (y >= 128 and y <= 135) or (y >= 144 and y <= 151) or (y >= 160 and y <= 167) or (y >= 176 and y<= 183)
					then -- 0 ~ 7
					if (x = 49) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector(((inty - 64) / 16  + 48) * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 50);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 69 and x <= 77) then
				if (y >= 64 and y <= 71) then -- r0 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r0(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r1(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r2(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r3(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r4(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r5(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r6(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 3
					if (x = 69) then 
						inty := y;
						tmp := conv_integer(r7(15 downto 12));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 70);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 79 and x <= 87) then
				if (y >= 64 and y <= 71) then -- r0 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r0(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r1(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r2(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r3(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r4(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r5(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r6(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 2
					if (x = 79) then 
						inty := y;
						tmp := conv_integer(r7(11 downto 8));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 80);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 89 and x <= 97) then
				if (y >= 64 and y <= 71) then -- r0 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r0(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r1(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r2(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r3(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r4(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r5(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r6(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 1
					if (x = 89) then 
						inty := y;
						tmp := conv_integer(r7(7 downto 4));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 90);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 99 and x <= 107) then
				if (y >= 64 and y <= 71) then -- r0 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r0(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r1(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r2(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r3(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r4(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r5(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r6(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 0
					if (x = 99) then 
						inty := y;
						tmp := conv_integer(r7(3 downto 0));
						if ( tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							fontROMAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 100);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 149 and x <= 157) then 
				if ( y >= 64 and y <= 71) then --PC的P
					if (x = 149) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 80 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 150);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 80 and y <= 87) then -- CM的C
					if (x = 149) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 67 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 150);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif( y>= 112 and y <= 119) then -- SP的S
					if (x = 149) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 83 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 150);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif( y>= 128 and y <= 135) then -- IH的I
					if (x = 149) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 73 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 150);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif( y >= 144 and y <= 151) then -- OP's O
					if (x = 149) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 79 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 150);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 159 and x <= 167) then 
				if ( y >= 64 and y <= 71) then --PC的C
					if (x = 159) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 67 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 160);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then -- CM的M
					if (x = 159) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 77 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 160);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y <= 103) then --T
					if (x = 159) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 84 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 160);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 112 and y <= 119) then --SP的P
					if (x = 159) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 80 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 160);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 128 and y <= 135) then --IH的H
					if (x = 159) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 72 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 160);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 144 and y <= 151) then --OP's P
					if (x = 159) then
						inty := y;
						fontROMAddr <= conv_std_logic_vector( 80 * 8 + inty mod 8, 11);
					else
						dx := 7 - (x - 160);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 179 and x <= 187) then 
				if ( y >= 64 and y <= 71) then --PC 3
					if (x = 179) then
						inty := y;
						tmp := conv_integer(PC(15 downto 12));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 180);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then -- CM 3
					if (x = 179) then
						inty := y;
						tmp := conv_integer(CM(15 downto 12));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 180);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y <= 103) then -- T 3
					if (x = 179) then
						inty := y;
						tmp := conv_integer(Tdata(15 downto 12));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 180);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 112 and y <= 119) then -- SP 3
					if (x = 179) then
						inty := y;
						tmp := conv_integer(SPdata(15 downto 12));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 180);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 128 and y <= 135) then -- IH 3
					if (x = 179) then
						inty := y;
						tmp := conv_integer(IHData(15 downto 12));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 180);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- OP 3
					if (x = 179) then
						inty := y;
						tmp := conv_integer(instruction(15 downto 12));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 180);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 189 and x <= 197) then
				if ( y >= 64 and y <= 71) then --PC 2
					if (x = 189) then
						inty := y;
						tmp := conv_integer(PC(11 downto 8));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 190);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --CM 2
					if (x = 189) then
						inty := y;
						tmp := conv_integer(CM(11 downto 8));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 190);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 96 and y <= 103) then --T 2
					if (x = 189) then
						inty := y;
						tmp := conv_integer(Tdata(11 downto 8));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 190);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 112 and y <= 119) then --SP 2
					if (x = 189) then
						inty := y;
						tmp := conv_integer(SPdata(11 downto 8));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 190);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 128 and y <= 135) then --IH 2
					if (x = 189) then
						inty := y;
						tmp := conv_integer(IHdata(11 downto 8));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 190);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- OP 2
					if (x = 189) then
						inty := y;
						tmp := conv_integer(instruction(11 downto 8));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 190);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 199 and x <= 207) then
				if ( y >= 64 and y <= 71) then --PC 1
					if (x = 199) then
						inty := y;
						tmp := conv_integer(PC(7 downto 4));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 200);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 80 and y <= 87) then -- CM 1
					if (x = 199) then
						inty := y;
						tmp := conv_integer(CM(7 downto 4));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 200);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 96 and y <= 103) then -- T 1
					if (x = 199) then
						inty := y;
						tmp := conv_integer(Tdata(7 downto 4));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 200);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 112 and y <= 119) then -- SP 1
					if (x = 199) then
						inty := y;
						tmp := conv_integer(SPdata(7 downto 4));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 200);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 128 and y <= 135) then -- IH 1
					if (x = 199) then
						inty := y;
						tmp := conv_integer(IHdata(7 downto 4));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 200);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- OP 1
					if (x = 199) then
						inty := y;
						tmp := conv_integer(instruction(7 downto 4));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 200);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 209 and x<= 217) then
				if ( y >= 64 and y <= 71) then --PC 0
					if (x = 209) then
						inty := y;
						tmp := conv_integer(PC(3 downto 0));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 210);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 80 and y <= 87) then -- CM 0
					if (x = 209) then
						inty := y;
						tmp := conv_integer(CM(3 downto 0));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 210);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 96 and y <= 103) then --T 0
					if (x = 209) then
						inty := y;
						tmp := conv_integer(Tdata(3 downto 0));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 210);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 112 and y <= 119) then --SP 0
					if (x = 209) then
						inty := y;
						tmp := conv_integer(SPdata(3 downto 0));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 210);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif ( y >= 128 and y <= 135) then --IH 0
					if (x = 209) then
						inty := y;
						tmp := conv_integer(IHdata(3 downto 0));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 210);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- OP 0
					if (x = 209) then
						inty := y;
						tmp := conv_integer(instruction(3 downto 0));
						if (tmp <= 9) then
							fontROMAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							fontROMAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (x - 210);
						rt <= (others => fontROMData(dx));
						gt <= (others => fontROMData(dx));
						bt <= (others => fontROMData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			else
				rt <= (others => '0');
				gt <= (others => '0');
				bt <= (others => '0');
			end if;
			
		end if;
	end process;

end Behavioral;

