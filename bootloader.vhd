----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    13:44:00 11/25/2017
-- Design Name:
-- Module Name:    boot - Behavioral
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
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use IEEE.std_logic_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bootloader is
    Port (
			click	: in std_logic;
			clk : in  std_logic;
			rst : in  std_logic;
			
			flash_byte : out  std_logic;
			flash_vpen : out  std_logic;
			flash_ce : out  std_logic;
			flash_oe : out  std_logic;
			flash_we : out  std_logic;
			flash_rp : out  std_logic;
			flash_addr : out  std_logic_vector (22 downto 0);
			flash_data : inout  std_logic_vector (15 downto 0);

			memory_address : out std_logic_vector(17 downto 0);
			memory_data_bus : inout std_logic_vector(15 downto 0);

			memory_write_enable : out std_logic;
			memory_read_enable : out std_logic;
			digit : out  STD_LOGIC_VECTOR (6 downto 0)
		);
end bootloader;

architecture Behavioral of bootloader is
	signal clk: std_logic;
	signal mem_write_en: std_logic;
	type boot_state is (flash_prepare, flash_will_set, flash_set, flash_will_read, flash_read, flash_read_finish, mem_write, boot_finish);
	signal state: boot_state := flash_prepare;
	signal next_state: boot_state;
	signal addr: std_logic_vector(15 downto 0) := x"0000";
	signal next_addr: std_logic_vector(15 downto 0);
	signal mem_addr: std_logic_vector(15 downto 0);
	signal data: std_logic_vector(15 downto 0) := x"0000";
	
begin
	flash_ce <= '0';
	flash_byte <= '1';
	flash_vpen <= '1';
	flash_rp <= '1';

	-- first test in click
	process (click, rst)
	begin
		if rst = '0' then
			state <= flash_prepare;
			addr <= x"0000";
		elsif rising_edge(clk) then
			state <= next_state;
			addr <= next_addr;
		end if;
	end process;
	
	process (state, addr)
	begin
		case state is
			when flash_prepare =>
				next_state <= flash_will_set;
				digit <= not "1000000";
			when flash_will_set =>
				next_state <= flash_set;
				digit <= not "1111001";
			when flash_set =>
				next_state <= flash_will_read;
				digit <= not "0100100";
			when flash_will_read =>
				next_state <= flash_read;
				digit <= not "0110000";
			when flash_read =>
				next_state <= flash_read_finish;
				digit <= not "0011001";
			when flash_read_finish =>
				next_state <= mem_write;
				digit <= not "0010010";
			when mem_write =>
				if addr < x"01f3" then
					next_state <= flash_will_read;
				else
					next_state <= boot_finish;
				end if;
				digit <= not "0000010";
			when boot_finish =>
				next_state <= boot_finish;
				digit <= not "1111000";
			when others =>
				next_state <= flash_prepare;
				digit <= not "1111111";
		end case;
		if state = mem_write then
			next_addr <= addr + x"0001";
		else
			next_addr <= addr;
		end if;
	end process;
	
	process (clk, rst)
	begin
		if rst = '0' then
			flash_we <= '1';
			flash_oe <= '1';
			memory_read_enable <= '0';
			memory_write_enable <= '0';
			led <= x"0000";
		elsif rising_edge(clk) then
			case next_state is
				when flash_prepare =>
					flash_we <= '1';
					flash_oe <= '1';
					mem_write_en <= '0';
					led <= x"0000";
				when flash_will_set =>
					flash_we <= '0';
				when flash_set =>
					flash_data <= x"00ff";
					flash_we <= '1';
				when flash_will_read =>
					flash_oe <= '0';
					flash_addr <= "000000" & next_addr & "0";
					memory_write_enable <= '0';
					memory_read_enable <= '0';
					flash_data <= "ZZZZZZZZZZZZZZZZ";
					led <= next_addr;
				when flash_read =>
					led <= flash_data;
					data <= flash_data;
					mem_addr <= next_addr;
				when flash_read_finish =>
					flash_oe <= '1';
				when mem_write =>
					mem_write_en <= '1';
				when boot_finish =>
					mem_write_en <= '0';
				when others =>
					flash_we <= '1';
					flash_oe <= '1';
					mem_write_en <= '0';
					led <= x"0000";
			end case;
		end if;
	end process;

end Behavioral;

