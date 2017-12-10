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
        clk                 : in std_logic;
        event_clk           : in std_logic_vector (3 downto 0);
        disp_mode           : in std_logic_vector (2 downto 0);
        rst                 : in std_logic;
        
        load_finish_flag    : out std_logic;
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
        ram1_data, ram2_data    : inout std_logic_vector (15 downto 0);
        ram1_write_enable, ram1_read_enable : out std_logic;
        ram2_write_enable, ram2_read_enable : out std_logic;
        digit : out  std_logic_vector (6 downto 0)
    );
end flash_manager;

architecture Behavioral of flash_manager is

component flash_loader is
    port(
        clk : in  std_logic;
        rst : in  std_logic;

        load_done           : out std_logic;

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

signal ppt_slide_index : std_logic_vector (4 downto 0) := "00000";

signal state : flash_manager_state_machine := not_booted;
signal manager_state : flash_manager_state_machine := not_booted;
signal start_addr : std_logic_vector (21 downto 0) := zero22;
signal load_len   : std_logic_vector (17 downto 0) := zero18;
signal ram_choose   : std_logic := '0';

signal mem_addr_real : std_logic_vector (17 downto 0) := zero18;
signal mem_data_real : std_logic_vector (15 downto 0) := x"0000";
signal mem_write_enable_real, mem_read_enable_real : std_logic := '0';

signal load_done    : std_logic := '0';

begin
    process (state, clk, event_clk, rst)
        variable ppt_addr_index : std_logic_vector (21 downto 0) := zero22;
        variable bg_loaded      : std_logic := '0';
    begin
        if rst = '0' then
            bg_loaded := '0';
            ppt_addr_index := zero22;
            ppt_slide_index <= "00000";
            boot_finish_flag <= '0';
            state <= not_booted;
            start_addr <= zero22;
            load_len <= zero18;
        elsif clk'event and clk = '1' then
            if state = not_booted then
                boot_finish_flag <= '0';
                start_addr <= zero22;
                load_len <= "00" & x"0FFF";
                state <= booting;
                -- use ram1
                ram_choose <= '0';
            elsif state = booting then
                ram_choose <= '0';
                if load_done = '1' then
                    state <= booted;
                end if;
            elsif state = booted then
                state <= idle;
            elsif state = idle then
                if disp_mode = "001" then
                    -- forward PPT
                    if event_clk /= "0000" then
                        -- loading image
                        load_finish_flag <= '0';

                        ram_choose <= '1'; --chose ram2
                        -- "11" & "d860"
                        load_len <= "11" & x"FFFF"; -- load on the whole ram2

                        if ppt_slide_index = "00000" then
                            digit <= not "0000001";
                            ppt_addr_index := "00" & x"00000";
                            ppt_slide_index <= ppt_slide_index + 1;
                        elsif ppt_slide_index = "00001" then
                            digit (4 downto 0) <= ppt_slide_index;
                            digit (6 downto 5) <= "00";
                            if event_clk = "0001" then
                                ppt_addr_index := "00" & x"40000";
                                ppt_slide_index <= ppt_slide_index + 1;
                            elsif event_clk = "0010" then
                                ppt_addr_index := "00" & x"00000";
                                ppt_slide_index <= "00000";
                            end if;
                            start_addr <= ppt_addr_index;
                        --elsif ppt_slide_index = "00001" then
                        --    digit <= not "1001111";
                        --    start_addr <= "00" & x"01000";
                        --    ppt_slide_index <= ppt_slide_index + 1;
                        elsif ppt_slide_index < "11111" then
                            digit (4 downto 0) <= ppt_slide_index;
                            digit (6 downto 5) <= "00";
                            if event_clk = "0001" then -- forward
                                ppt_slide_index <= ppt_slide_index + 1;
                                ppt_addr_index := ppt_addr_index + x"40000";
                            elsif event_clk = "0010" then-- backward
                                ppt_slide_index <= ppt_slide_index - 1;
                                ppt_addr_index := ppt_addr_index - x"40000";
                            end if;
                            start_addr <= ppt_addr_index;
                        else
                            ppt_slide_index <= "00000";
                            digit <= not "0000001";
                        end if;
                        state <= loading;
                    else
                        load_finish_flag <= '1';
                        boot_finish_flag <= '1';
                    end if;
                elsif disp_mode = "010" then
                    
                    boot_finish_flag <= '1';
                    if bg_loaded = '0' then
                        bg_loaded := '1';
                        load_finish_flag <= '0';
                        start_addr <= "00" & x"01000";
                        load_len <= "11" & x"FFFF";
                        state <= loading;      
                    else   
                        load_finish_flag <= '1';
                    end if;
                else
                    boot_finish_flag <= '1';
                    load_finish_flag <= '1';
                end if;
            elsif state = loading then
                ram_choose <= '1';
                load_finish_flag <= '0';
                if load_done = '1' then
                    state <= loaded;
                end if;
            elsif state = loaded then
                state <= idle;
            end if;
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
        load_done   => load_done,
        start_addr  => start_addr,
        load_len    => load_len,

        flash_byte  => flash_byte, --: out  std_logic;
        flash_vpen  => flash_vpen, --: out  std_logic;
        flash_ce    => flash_ce, --: out  std_logic;
        flash_oe    => flash_oe, --: out  std_logic;
        flash_we    => flash_we, --: out  std_logic;
        flash_rp    => flash_rp, --: out  std_logic;
        flash_addr  => flash_addr, -- : out  std_logic_vector (22 downto 0);
        flash_data  => flash_data, --: inout  std_logic_vector (15 downto 0);

        memory_address => mem_addr_real, -- : out std_logic_vector(17 downto 0);
        memory_data_bus => mem_data_real, --: inout std_logic_vector(15 downto 0);

        memory_write_enable => mem_write_enable_real, -- : out std_logic;
        memory_read_enable => mem_read_enable_real --: out std_logic;
    );

end Behavioral;

