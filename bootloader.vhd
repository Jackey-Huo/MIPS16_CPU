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
			
			boot_finish_flag	: out std_logic := '0';
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
			digit : out  std_logic_vector (6 downto 0)
		);
end bootloader;

architecture Behavioral of bootloader is
	signal mem_write_en: std_logic;
	type boot_state is (flash_init, flash_read0, flash_read1, flash_read2, flash_read3, flash_read_done, mem_write, boot_finish);

	signal state: boot_state := flash_init;
	signal next_state: boot_state;
	signal addr: std_logic_vector(15 downto 0) := x"0000";
	signal next_addr: std_logic_vector(15 downto 0);
	signal mem_addr: std_logic_vector(15 downto 0);
	signal data: std_logic_vector(15 downto 0) := x"0000";
	signal state_clk : std_logic := '0';
	
begin
	flash_ce <= '0';
	flash_byte <= '1';
	flash_vpen <= '1';
	flash_rp <= '1';
	memory_data_bus <= data;
	memory_address <= "00" & mem_addr;
	state_clk <= clk; -- click;
	
	-- first test in click
	process (state_clk, rst)
	begin
		if rst = '0' then
			state <= flash_init;
			addr <= x"0000";
		elsif (state_clk'event and state_clk = '1') then
			state <= next_state;
			addr <= next_addr;
		end if;
	end process;
	
	process (state, addr)
	begin
		case state is
			when flash_init =>
				next_state <= flash_read0;
				digit <= not "0000001";
			when flash_read0 =>
				next_state <= flash_read1;
				digit <= not "1001111";
			when flash_read1 =>
				next_state <= flash_read2;
				digit <= not "0010010";
			when flash_read2 =>
				next_state <= flash_read3;
				digit <= not "0000110";
			when flash_read3 =>
				next_state <= flash_read_done;
				digit <= not "1001100";
			when flash_read_done =>
				next_state <= mem_write;
				digit <= not "0100100";
			when mem_write =>
				-- slightly larger than monitor program
				if addr < x"0200" then
					next_state <= flash_read2;
				else
					next_state <= boot_finish;
				end if;
				digit <= not "0100000";
			when boot_finish =>
				boot_finish_flag <= '1';
				next_state <= boot_finish;
				digit <= not "0001111";
			when others =>
				next_state <= flash_init;
				digit <= not "1111111";
		end case;
		if state = mem_write then
			next_addr <= addr + 1;
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
		elsif (clk'event and clk = '1') then
			case next_state is
				when flash_init =>
					flash_we <= '1';
					flash_oe <= '1';
					memory_write_enable <= '0';
					memory_read_enable <= '0';
				when flash_read0 =>
					flash_we <= '0';
				when flash_read1 =>
					flash_data <= x"00ff";
					flash_we <= '1';
				when flash_read2 =>
					flash_oe <= '0';
					flash_addr <= "000000" & next_addr & "0";
					memory_write_enable <= '0';
					memory_read_enable <= '0';
					flash_data <= "ZZZZZZZZZZZZZZZZ";
				when flash_read3 =>
					data <= flash_data;
					mem_addr <= next_addr;
				when flash_read_done =>
					flash_oe <= '1';
				when mem_write =>
					memory_write_enable <= '1';
					memory_read_enable <= '0';
				when boot_finish =>
					memory_write_enable <= '0';
					memory_read_enable <= '0';
				when others =>
					flash_we <= '1';
					flash_oe <= '1';
					memory_read_enable <= '0';
					memory_write_enable <= '0';
			end case;
		end if;
	end process;

end Behavioral;

