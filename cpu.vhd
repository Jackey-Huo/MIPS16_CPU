----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:24:18 11/16/2017 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity cpu is
    port (
        clk : in std_logic;
        rst : in std_logic;
        led : out std_logic_vector(15 downto 0);

        -- ram1
        data_ram1 : inout std_logic_vector(15 downto 0);
        addr_ram1 : out std_logic_vector(17 downto 0);
        OE_ram1   : out std_logic;
        WE_ram1   : out std_logic;
        EN_ram1   : out std_logic;

        -- ram2
        data_ram2 : inout std_logic_vector(15 downto 0);
        addr_ram2 : out std_logic_vector(17 downto 0);
        OE_ram2   : out std_logic;
        WE_ram2   : out std_logic;
        EN_ram2   : out std_logic;

        -- serial
        seri_rdn : out std_logic;
        seri_wrn : out std_logic;
        seri_data_ready : in std_logic;
        seri_tbre       : in std_logic;
        seri_tsre       : in std_logic;

        --digits
        digit1  :   out  STD_LOGIC_VECTOR (6 downto 0) := "1111111";
        digit2  :   out  STD_LOGIC_VECTOR (6 downto 0) := "1111111"
    )
end cpu;

architecture Behavioral of cpu is

begin

    ---------------- IF --------------------------
    IF_unit: process(clk, rst)
    begin

    end process IF_unit;

    ---------------- ID --------------------------
    ID_unit: process(clk, rst)
    begin
    end process ID_unit;

    ---------------- EX --------------------------
    EX_unit: process(clk, rst)
    begin
    end process EX_unit;

    ---------------- ME --------------------------
    ME_unit: process(clk, rst)
    begin
    end process ME_unit;

    ---------------- WB --------------------------
    WB_unit: process(clk, rst)
    begin
    end process WB_unit;

    ------------ Control Unit --------------------
    Control_unit: process(clk, rst)
    begin
    end process Control_unit;



end Behavioral;

