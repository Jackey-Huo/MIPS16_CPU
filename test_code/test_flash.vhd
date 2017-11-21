----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:15:29 11/21/2017 
-- Design Name: 
-- Module Name:    test_flash - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_flash is
end test_flash;

architecture Behavioral of test_flash is

component flash_io is
    Port ( addr : in  STD_LOGIC_VECTOR (22 downto 1);
           data_in : in  STD_LOGIC_VECTOR (15 downto 0);
           data_out : out  STD_LOGIC_VECTOR (15 downto 0);
			  clk : in std_logic;--ÀÊ±„ ≤√¥ ±÷”
			  reset : in std_logic;
			  
			  flash_byte : out std_logic;--BYTE#
			  flash_vpen : out std_logic;
			  flash_ce : out std_logic;
			  flash_oe : out std_logic;
			  flash_we : out std_logic;
			  flash_rp : out std_logic;
			  --flash_sts : in std_logic;
			  flash_addr : out std_logic_vector(22 downto 1);
			  flash_data : inout std_logic_vector(15 downto 0);
			  
           ctl_read : in  STD_LOGIC;
           ctl_write : in  STD_LOGIC;
			  ctl_erase : in STD_LOGIC
	);
end component;

begin


end Behavioral;

