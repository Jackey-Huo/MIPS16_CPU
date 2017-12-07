----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  
-- 
-- Create Date:    20:26:01 12/07/2017 
-- Design Name: 
-- Module Name:    flash_manager - Behavioral 
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

entity flash_manager is
    port (
        not_boot            : in std_logic;
        clk                 : in  std_logic;
        event_clk           : in std_logic;
        rst                 : in  std_logic;
        
        boot_finish_flag    : out std_logic := '0';
        flash_byte : out  std_logic;
        flash_vpen : out  std_logic;
        flash_ce : out  std_logic;
        flash_oe : out  std_logic;
        flash_we : out  std_logic;
        flash_rp : out  std_logic;
        flash_addr : out  std_logic_vector (22 downto 0);
        flash_data : inout  std_logic_vector (15 downto 0);

        ram1_addr, ram2_addr    : out std_logic_vector (17 downto 0);
        ram1_data, ram2_data    : out std_logic_vector (15 downto 0);
        ram1_write_enable, ram1_read_enable : out std_logic;
        ram2_write_enable, ram2_read_enable : out std_logic
    );
end flash_manager;

architecture Behavioral of flash_manager is

component flash_loader is
    port(
        clk : in  std_logic;
        rst : in  std_logic;
        
        start_addr          : in std_logic_vector (21 downto 0);
        load_len            : in std_logic_vector (17 downto 0);

        flash_byte          : out  std_logic;
        flash_vpen          : out  std_logic;
        flash_ce            : out  std_logic;
        flash_oe            : out  std_logic;
        flash_we            : out  std_logic;
        flash_rp            : out  std_logic;
        flash_addr          : out  std_logic_vector (22 downto 0);
        flash_data          : inout  std_logic_vector (15 downto 0);

        memory_address      : out std_logic_vector(17 downto 0);
        memory_data_bus     : inout std_logic_vector(15 downto 0);

        memory_write_enable : out std_logic;
        memory_read_enable  : out std_logic
    );
end component;

type flash_manager_state_machine is (not_booted, booting, booted, idle, loading, loaded);

signal state_clk : std_logic := '0';
signal state : flash_manager_state_machine := not_booted;
signal manager_state : flash_manager_state_machine := not_booted;
signal start_addr : std_logic_vector (21 downto 0) := zero22;
signal load_len   : std_logic_vector (17 downto 0) := zero18;
signal ram_choose   : std_logic := '0';

signal mem_addr_real : std_logic_vector (17 downto 0) := zero18;
signal mem_data_real : std_logic_vector (15 downto 0) := x"0000";
signal mem_write_enable_real, mem_read_enable_real : std_logic := '0';

begin
    state_clk <= event_clk;
    -- first test in click
    process (state_clk, rst)
    begin
        if rst = '0' then
            boot_finish_flag <= '0';
            state <= not_booted;
            start_addr <= zero22;
            load_len <= zero18;
        elsif state /= not_booted then
            boot_finish_flag <= '0';
            start_addr <= zero22;
            load_len <= "00" & x"0200";
            ram_choose <= '0'; --chose ram1
        elsif state = idle and state_clk'event and state_clk = '1' then
            -- loading image
            -- !NOTICE : problematic
            boot_finish_flag <= '0';

            ram_choose <= '1'; --chose ram2
            start_addr <= "0000000000000000000000"; -- the addr of first image
            load_len <= "11" & x"FFFF"; -- load on the whole ram2
        end if;
    end process;

    -- mux the databus
    process(ram_choose)
    begin
        if ram_choose = '0' then
            ram1_addr <= mem_addr_real;
            ram1_data <= mem_data_real;
            ram1_write_enable <= mem_write_enable_real;
            ram1_read_enable  <= mem_read_enable_real;
        else
            ram2_addr <= mem_addr_real;
            ram2_data <= mem_data_real;
            ram2_write_enable <= mem_write_enable_real;
            ram2_read_enable  <= mem_read_enable_real;
        end if;
    end process;

    flash_reader : flash_loader port map(
        clk => clk,
        rst => rst,

        start_addr  => start_addr,
        load_len    => load_len,

        flash_byte => flash_byte, --: out  std_logic;
        flash_vpen =>flash_vpen, --: out  std_logic;
        flash_ce => flash_ce, --: out  std_logic;
        flash_oe => flash_oe, --: out  std_logic;
        flash_we => flash_we, --: out  std_logic;
        flash_rp => flash_rp, --: out  std_logic;
        flash_addr => flash_addr, -- : out  std_logic_vector (22 downto 0);
        flash_data => flash_data, --: inout  std_logic_vector (15 downto 0);

        memory_address => mem_addr_real, -- : out std_logic_vector(17 downto 0);
        memory_data_bus => mem_data_real, --: inout std_logic_vector(15 downto 0);

        memory_write_enable => mem_write_enable_real, -- : out std_logic;
        memory_read_enable => mem_read_enable_real --: out std_logic;
    );

end Behavioral;

