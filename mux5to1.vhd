----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:36:43 11/23/2017 
-- Design Name: 
-- Module Name:    mux5to1 - Behavioral 
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
library basic;
use basic.helper.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux5to1 is
    port (
        output       : out std_logic_vector (15 downto 0) := zero16;
        ctrl_mux     : in std_logic_vector (2 downto 0);
        idex_reg     : in std_logic_vector (15 downto 0);
        alu_result   : in std_logic_vector (15 downto 0);
        mewb_result  : in std_logic_vector (15 downto 0);
        mewb_readout : in std_logic_vector (15 downto 0);
        wb_reg_data  : in std_logic_vector (15 downto 0)
    );
end mux5to1;

architecture Behavioral of mux5to1 is

begin

    with ctrl_mux select
        output <= idex_reg     when chs_idex_reg,
                  alu_result   when chs_alu_result,
                  mewb_result  when chs_mewb_result,
                  mewb_readout when chs_mewb_readout,
                  wb_reg_data  when chs_wb_reg_data,
                  idex_reg     when others;

end Behavioral;

