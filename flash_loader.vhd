----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:16:12 12/07/2017 
-- Design Name: 
-- Module Name:    flash_loader - Behavioral 
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

entity flash_loader is
    port(
        clk : in  std_logic;
        rst : in  std_logic;

        load_done           : out std_logic;
        -- start addr in flash
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
end flash_loader;

architecture Behavioral of flash_loader is

    signal mem_write_en: std_logic;
    type flash_read_state is (flash_init, flash_read0, flash_read1, flash_read2, flash_read3, flash_read_done, mem_write, mem_write_done, load_finish);

    signal state: flash_read_state := flash_init;
    signal next_flash_addr : std_logic_vector (21 downto 0) := zero22;
    signal next_mem_addr: std_logic_vector(17 downto 0) := zero18;
    signal cur_flash_addr   : std_logic_vector (21 downto 0) := zero22;
    signal cur_mem_addr     : std_logic_vector (17 downto 0) := zero18;
    signal mem_addr: std_logic_vector(17 downto 0) := zero18;
    signal state_clk : std_logic := '0';

    signal end_addr : std_logic_vector (21 downto 0);
begin
    flash_ce <= '0';
    flash_byte <= '1';
    flash_vpen <= '1';
    flash_rp <= '1';
    state_clk <= clk;
    end_addr <= start_addr + load_len;
    load_done <= '1' when state = load_finish else '0';

    process (clk, rst)
    begin
        if rst = '0' then
            state <= flash_init;

            cur_mem_addr <= zero18;
            cur_flash_addr <= start_addr;

            flash_we <= '1';
            flash_oe <= '1';

            memory_read_enable <= '0';
            memory_write_enable <= '0';
        elsif (clk'event and clk = '1') then
            -- needed to load different content :
            -- change start_addr or load_len to make cur_flash_addr different
            if state = load_finish and cur_flash_addr /= end_addr then
                state <= flash_init;
            end if;

            case state is
                when flash_init =>
                    flash_we <= '1';
                    flash_oe <= '1';

                    memory_write_enable <= '0';
                    memory_read_enable <= '0';
                    
                    cur_flash_addr <= start_addr;
                    cur_mem_addr <= zero18;

                    state <= flash_read0;
                when flash_read0 =>
                    flash_we <= '0';
                    state <= flash_read1;
                when flash_read1 =>
                    flash_data <= x"00ff";
                    flash_we <= '1';
                    state <= flash_read2;
                when flash_read2 =>
                    flash_oe <= '0';
                    -- read : next flash
                    flash_addr <= cur_flash_addr & "0";
                    memory_write_enable <= '0';
                    memory_read_enable <= '0';
                    flash_data <= "ZZZZZZZZZZZZZZZZ";
                    state <= flash_read3;
                when flash_read3 =>
                    -- read : next mem
                    memory_data_bus <= flash_data;
                    memory_address <= cur_mem_addr;
                    state <= flash_read_done;
                when flash_read_done =>
                    flash_oe <= '1';
                    state <= mem_write;
                when mem_write =>
                    memory_write_enable <= '1';
                    memory_read_enable <= '0';
                    state <= mem_write_done;
                when mem_write_done =>
                    if cur_flash_addr < end_addr then
                        state <= flash_read2;
                        cur_mem_addr <= cur_mem_addr + 1;
                        cur_flash_addr <= cur_flash_addr + 1;
                    else
                        state <= load_finish;
                    end if;
                when load_finish =>
                    memory_write_enable <= '0';
                    memory_read_enable <= '0';
                when others =>
                    flash_we <= '1';
                    flash_oe <= '1';
                    memory_read_enable <= '0';
                    memory_write_enable <= '0';
                    state <= load_finish;
            end case;
        end if;
    end process;

end Behavioral;

