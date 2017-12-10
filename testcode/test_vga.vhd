----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:13:15 11/23/2017 
-- Design Name: 
-- Module Name:    test_vga - Behavioral 
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
use basic.interface.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_vga is
	port(
		click : in std_logic;
		clk : in std_logic;
		rst : in std_logic;

		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync

        -- ram1, Instruction memory
        data_ram1 : inout std_logic_vector(15 downto 0);
        addr_ram1 : out std_logic_vector(17 downto 0);
        OE_ram1   : out std_logic;
        WE_ram1   : out std_logic;
        EN_ram1   : out std_logic;

        -- ram2, Data memory
        data_ram2 : inout std_logic_vector(15 downto 0);
        addr_ram2 : out std_logic_vector(17 downto 0);
        OE_ram2   : out std_logic := '1';
        WE_ram2   : out std_logic := '1';
        EN_ram2   : out std_logic := '1';

        -- serial
        seri_rdn        : out std_logic := '1';
        seri_wrn        : out std_logic := '1';
        seri_data_ready : in std_logic;
        seri_tbre       : in std_logic;
        seri_tsre       : in std_logic;

		-- Separate color definition for output
		VGA_R : out std_logic_vector(2 downto 0);
		VGA_G : out std_logic_vector(2 downto 0);
		VGA_B : out std_logic_vector(2 downto 0);
		
		-- debug
		led : out std_logic_vector(15 downto 0);
        instruct : in std_logic_vector (15 downto 0)
	);

end test_vga;

architecture Behavioral of test_vga is

    -- IF/ID pipeline storage
    signal ifid_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal ifid_instruc_mem                : std_logic_vector (15 downto 0) := zero16;
    signal pc_real                         : std_logic_vector (15 downto 0) := zero16;
    signal mewb_result                     : std_logic_vector (15 downto 0) := zero16;
    signal mewb_readout                    : std_logic_vector (15 downto 0) := zero16;
	
	-- signal ctrl_Hs, ctrl_Vs : std_logic := '0';
	signal ctrl_R, ctrl_G, ctrl_B : std_logic_vector(2 downto 0) := "000";
	signal ctrl_color : std_logic_vector (8 downto 0) := "000000000";
	signal R_r, G_r, B_r : std_logic_vector(2 downto 0) := "000";

	-- simulated signals for debugging
	signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := x"10AF";
	signal SP, IH, T, CM, PC : std_logic_vector(15 downto 0) := x"0000";

	-- VGA signals
	signal disp_mode : std_logic_vector ( 2 downto 0) := "000";
	signal cache_WE, cache_wea, disp_en       : std_logic := '0';
    signal ram2_readout        : std_logic_vector (15 downto 0);
    signal ram2_write_enable   : std_logic;
    signal ram2_read_enable    : std_logic;
    signal ram2_read_addr      : std_logic_vector (17 downto 0);
    signal ram2_write_addr     : std_logic_vector (17 downto 0);
    signal ram2_write_data     : std_logic_vector (15 downto 0);

    -- MEM variables
    signal me_read_enable, me_write_enable : std_logic                      := '0';
    signal me_write_enable_real            : std_logic                      := '0';
    signal me_read_addr, me_write_addr     : std_logic_vector (17 downto 0) := zero18;
    signal me_write_data                   : std_logic_vector (15 downto 0) := zero16;

    signal seri_wrn_t, seri_rdn_t          : std_logic                      := '0';
    signal seri1_read_enable               : std_logic                      := '0';
    signal seri1_write_enable              : std_logic                      := '0';
    signal seri1_write_enable_real         : std_logic                      := '0';
    signal seri1_ctrl_read_en              : std_logic                      := '0';
    component refresh is
        port (
            click : in std_logic;
            clk : in std_logic;
            rst : in std_logic;
            
            addr        : out std_logic_vector (17 downto 0);
            data        : out std_logic_vector (15 downto 0);
            ram2_write_enable   : out std_logic
        ); 
    end component;
    component memory_unit is
        port(
            clk         : in std_logic;
            rst         : in std_logic;

            -- ram1, Instruction memory
            data_ram1   : inout std_logic_vector(15 downto 0);
            addr_ram1   : out std_logic_vector(17 downto 0);
            OE_ram1     : out std_logic;
            WE_ram1     : out std_logic;
            EN_ram1     : out std_logic;

            -- ram2, Data memory
            data_ram2   : inout std_logic_vector(15 downto 0);
            addr_ram2   : out std_logic_vector(17 downto 0);
            OE_ram2     : out std_logic := '1';
            WE_ram2     : out std_logic := '1';
            EN_ram2     : out std_logic := '1';

            -- serial
            seri_rdn        : out std_logic := '1';
            seri_wrn        : out std_logic := '1';
            seri_data_ready : in std_logic;
            seri_tbre       : in std_logic;
            seri_tsre       : in std_logic;

            disp_en             : out std_logic;
            mewb_readout        : out std_logic_vector (15 downto 0);
            ifid_instruc_mem    : out std_logic_vector (15 downto 0);
            me_write_enable     : in std_logic;
            me_read_enable      : in std_logic;
            me_read_addr        : in std_logic_vector (17 downto 0);
            me_write_addr       : in std_logic_vector (17 downto 0);
            me_write_data       : in std_logic_vector (15 downto 0);
            pc_real             : in std_logic_vector (15 downto 0);
            seri1_write_enable  : in std_logic;
            seri1_read_enable   : in std_logic;
            seri1_ctrl_read_en  : in std_logic;
            
            ram2_readout        : out std_logic_vector (15 downto 0);
            ram2_write_enable   : in std_logic;
            ram2_read_enable    : in std_logic;
            ram2_read_addr      : in std_logic_vector (17 downto 0);
            ram2_write_addr     : in std_logic_vector (17 downto 0);
            ram2_write_data		: in std_logic_vector (15 downto 0)

        );
    end component;
begin
	disp_mode <= instruct(5 downto 3);
	
	ctrl_color <= "000000111";
    ------------- Memory and Serial Control Unit, pure combinational logic
    memory_IO : memory_unit port map(
        clk         => clk,
        rst         => rst,

        -- ram1, Instruction memory
        data_ram1   => data_ram1,
        addr_ram1   => addr_ram1,
        OE_ram1     => OE_ram1,
        WE_ram1     => WE_ram1,
        EN_ram1     => EN_ram1,

        -- ram2, Data memory
        data_ram2   => data_ram2,
        addr_ram2   => addr_ram2,
        OE_ram2     => OE_ram2, 
        WE_ram2     => WE_ram2, 
        EN_ram2     => EN_ram2, 

        -- serial
        seri_rdn        => seri_rdn       ,
        seri_wrn        => seri_wrn       ,
        seri_data_ready => seri_data_ready,
        seri_tbre       => seri_tbre      ,
        seri_tsre       => seri_tsre      ,
        -- useless
        disp_en            => disp_en             ,
        mewb_readout       => mewb_readout        , 
        ifid_instruc_mem   => ifid_instruc_mem    , 
        me_write_enable    => me_write_enable     , 
        me_read_enable     => me_read_enable      , 
        me_read_addr       => me_read_addr        , 
        me_write_addr      => me_write_addr       , 
        me_write_data      => me_write_data       ,
        pc_real            => pc_real             , 
        seri1_write_enable => seri1_write_enable  , 
        seri1_read_enable  => seri1_read_enable   , 
        seri1_ctrl_read_en => seri1_ctrl_read_en  ,
        ram2_readout       => ram2_readout        ,
        ram2_write_enable  => ram2_write_enable   ,
        ram2_read_enable   => ram2_read_enable    ,
        ram2_read_addr     => ram2_read_addr      ,
        ram2_write_addr    => ram2_write_addr     ,
        ram2_write_data    => ram2_write_data     
    );

    fresh_ram2 : refresh port map(
        click => click,
        clk => clk,
        rst => rst,
        addr                => me_write_addr,
        data                => me_write_data,
        ram2_write_enable   => me_write_enable
    );

    ------------- VGA control : show value of Registers, PC, Memory operation address, etc ----
    vga_disp : vga_ctrl port map(
        clk => clk,
        rst => rst,
        disp_mode => disp_mode,
        Hs => Hs,
        Vs => Vs,
        cache_wea => cache_wea,
        ram2_read_enable => ram2_read_enable,
        cache_WE => disp_en,
        cache_write_addr    => me_write_addr (12 downto 0),
        cache_write_data	=> me_write_data (7 downto 0),
        disp_addr => ram2_read_addr,
        disp_data => ram2_readout,
        r0=>r0,
        r1=>r1,
        r2=>r2,
        r3=>r3,
        r4=>r4,
        r5=>r5,
        r6=>r6,
        r7=>r7,
        PC => PC, -- : in std_logic_vector(15 downto 0);
        CM => me_read_addr(15 downto 0), -- in std_logic_vector(15 downto 0);
        Tdata => T, -- : in std_logic_vector(15 downto 0);
        SPdata => SP, -- : in std_logic_vector(15 downto 0);
        IHdata => IH, --: in std_logic_vector(15 downto 0);
        instruction => ifid_instruc,
        R => VGA_R,
        G => VGA_G,
        B => VGA_B
    );

    led(6 downto 0) <= ram2_readout(6 downto 0);
    led(15) <= seri_wrn_t;
    led(14) <= seri_rdn_t;
    led(13) <= seri_tbre;
    led(12) <= seri_tsre;
    led(11) <= seri_data_ready;
    led(10 downto 7) <= me_read_enable & me_write_enable & ram2_read_enable & ram2_write_enable;
	
end Behavioral;

