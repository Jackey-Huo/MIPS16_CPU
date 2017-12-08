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
library IEEE, BASIC;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use BASIC.HELPER.ALL;
use BASIC.INTERFACE.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    port (
        click : in std_logic;
        clk_50M : in std_logic;
        rst : in std_logic;

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

        --digits
        dyp0            : out  STD_LOGIC_VECTOR (6 downto 0) := "1111111";
        dyp1            : out  STD_LOGIC_VECTOR (6 downto 0) := "1111111";

        -- ps2 keyboard
        ps2_clk          : in std_logic;
        ps2_data         : in std_logic;

        --VGA
        Hs                  : out std_logic;   -- line sync
        Vs                  : out std_logic;   -- field sync
        VGA_R, VGA_G, VGA_B : out std_logic_vector (2 downto 0) := "000";
          
        --flash
        flash_addr : out std_logic_vector (22 downto 0);
        flash_data : inout std_logic_vector (15 downto 0);
        flash_byte : out std_logic;            -- BYTE#
        flash_vpen : out std_logic;
        flash_ce   : out std_logic;
        flash_oe   : out std_logic;
        flash_we   : out std_logic;
        flash_rp   : out std_logic;
        
        -- led
        led : out std_logic_vector(15 downto 0);

        -- feed in instruct
        instruct : in std_logic_vector (15 downto 0)
    );
end cpu;

architecture Behavioral of cpu is
    -- register
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := zero16;
    signal SP, IH, T : std_logic_vector(15 downto 0) := zero16;

    -- Exception or interrupt
    signal EPC, Cause : std_logic_vector (15 downto 0) := zero16;

    -- clocks
    -- main clock
    signal clk : std_logic;
    -- vga_clk
    signal clk50 : std_logic;
    -- pc
    signal pc                              : std_logic_vector (15 downto 0) := zero16;
    signal pc_real                         : std_logic_vector (15 downto 0) := zero16;
    -- help signal
     
    -- IF/ID pipeline storage
    signal ifid_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal ifid_instruc_mem                : std_logic_vector (15 downto 0) := zero16;
    
    -- Control Unit
    signal ctrl_mux_reg_a, ctrl_mux_reg_b  : std_logic_vector (2 downto 0)  := "000";
    signal ctrl_mux_bypass                 : std_logic_vector (2 downto 0)  := "000";
    signal ctrl_insert_bubble              : std_logic                      := '0';

    -- branch signal
    signal id_pc_branch                    : std_logic                      := '0';
    signal id_branch_value                 : std_logic_vector (15 downto 0) := zero16;

    signal id_instruc                      : std_logic_vector (15 downto 0) := zero16;

    -- ID/EX
    signal idex_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_a_data                 : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_a_data_real            : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_b_data                 : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_b_data_real            : std_logic_vector (15 downto 0) := zero16;
    signal idex_bypass                     : std_logic_vector (15 downto 0) := zero16;
    signal idex_bypass_real                : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    
    -- EX layer variables
    signal ex_reg_a_data, ex_reg_b_data    : std_logic_vector (15 downto 0) := zero16;
    signal ex_alu_op                       : std_logic_vector (3 downto 0)  := "0000";
    
    -- EX/MEM pipeline storage
    signal exme_instruc                    : std_logic_vector (15 downto 0)  := zero16;
     -- NOTICE: carry and overflow is not required
    signal exme_carry, exme_zero, exme_ovr : std_logic                      := '0';
    signal exme_result                     : std_logic_vector (15 downto 0) := zero16;
    signal exme_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    signal exme_bypass                     : std_logic_vector (15 downto 0) := zero16;
    
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

    --MEM/WB pipeline storage
    signal mewb_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal mewb_result                     : std_logic_vector (15 downto 0) := zero16;
    signal mewb_readout                    : std_logic_vector (15 downto 0) := zero16;
    signal mewb_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    signal mewb_bypass                     : std_logic_vector (15 downto 0) := zero16;

    signal wb_reg_data                     : std_logic_vector (15 downto 0) := zero16;

    -- VGA signals
    signal ctrl_R, ctrl_G, ctrl_B : std_logic_vector(2 downto 0) := "000";

    -- ps2 signals
    signal ps2_data_ready       : std_logic := '0';
    signal ps2_hold_key_value   : std_logic_vector (15 downto 0) := zero16;

    -- flash signals
    signal clk_flash : std_logic := '0';
    signal boot_finish : std_logic := '0';
    signal boot_write_addr : std_logic_vector(17 downto 0) := zero18;
    signal boot_write_data : std_logic_vector(15 downto 0) := zero16;
    signal boot_write_enable, boot_read_enable : std_logic := '0';

    -- INT module signals
    signal hard_int_flag     : std_logic := '0';                         -- if there is INT op
    -- absolute interrupt headle address, changed by the kernel development
    constant delint_addr   : std_logic_vector (15 downto 0) := x"0006";
    -- memory address containing keyboard ascii code when hardware interrupt occur
    constant hardint_keyboard_addr    : std_logic_vector (15 downto 0) := x"BFF0";

begin
    ------------- Clock selector ----------
    clk_selector   : clock_select port map(
        click => click,
        clk_50M => clk_50M,
        selector => instruct(2 downto 0), --25M
        clk => clk,
        clk_flash => clk_flash
    );

    -- bootloader : load monitor program from flash
    bl  :   bootloader port map(
            not_boot => instruct(15),
            clk => clk_flash,
            rst => rst,
            boot_finish_flag => boot_finish,
            flash_byte => flash_byte, --: out  std_logic;
            flash_vpen =>flash_vpen, --: out  std_logic;
            flash_ce => flash_ce, --: out  std_logic;
            flash_oe => flash_oe, --: out  std_logic;
            flash_we => flash_we, --: out  std_logic;
            flash_rp => flash_rp, --: out  std_logic;
            flash_addr => flash_addr, -- : out  std_logic_vector (22 downto 0);
            flash_data => flash_data, --: inout  std_logic_vector (15 downto 0);

            memory_address => boot_write_addr, -- : out std_logic_vector(17 downto 0);
            memory_data_bus => boot_write_data, --: inout std_logic_vector(15 downto 0);

            memory_write_enable => boot_write_enable, -- : out std_logic;
            memory_read_enable => boot_read_enable, --: out std_logic;
            digit => dyp0 --: out  STD_LOGIC_VECTOR (6 downto 0)
    );
 
    ------------- VGA control : show value of Registers, PC, Memory operation address, etc ----
    vga_disp : vga_ctrl port map(
        clk => clk_50M,
        rst => rst,
        Hs => Hs,
        Vs => Vs,
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
        color => "000000000",
        R => VGA_R,
        G => VGA_G,
        B => VGA_B
    );

    ------------- PS2 Keyboard Control -----------
    ps2_keyboard : keyboard_ctrl port map (
        rst => rst,
        clk => clk,
        ps2_clk => ps2_clk,
        ps2_data => ps2_data,
        data_ready => ps2_data_ready,
        hold_key_value => ps2_hold_key_value
    );

    ---------------- INT -------------------------
    INT_unit : int_ctrl port map (
        clk => clk,
        rst => rst,
        cur_pc => pc,
        cur_instruc => ifid_instruc,
        IH => IH,
        ps2_data_ready => ps2_data_ready,
        hard_int_flag => hard_int_flag,
        epc => EPC,
        cause => Cause
    );

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
        seri1_ctrl_read_en => seri1_ctrl_read_en  
    );

    ---------------- IF --------------------------
    IF_unit: process(clk, rst)
    begin
        if (rst = '0' or boot_finish = '0') then
            pc <= zero16;
        elsif ( clk'event and clk='1' ) then
            if (ctrl_insert_bubble = '1') then
                ifid_instruc <= ifid_instruc;
                pc <= pc_real;
            elsif ((me_read_enable = '1') or (me_write_enable = '1')) then
                ifid_instruc <= ifid_instruc_mem;     -- actually, it's a NOP
                pc <= pc_real;
            elsif ((seri1_read_enable = '1') or (seri1_write_enable = '1')) then
                ifid_instruc <= ifid_instruc_mem;     -- actually, it's a NOP
                pc <= pc_real;
            elsif (hard_int_flag = '1') then          -- TODO, in fact, we need consider of MEM/IF conflict here
                ifid_instruc <= INT_op & "0000000" & "1000";   -- 8 is for keyboard interrupt
                pc <= pc_real;
            else
                ifid_instruc <= ifid_instruc_mem;
                pc <= pc_real + 1;
            end if;
        end if;
    end process IF_unit;

    -- mux for real pc
    pc_real <= zero16 when (rst = '0') else
               id_branch_value when ((id_pc_branch = '1') and (ctrl_insert_bubble = '0')) else
               pc;



    ---------------- ID --------------------------

    ID_unit: ID port map (
        clk                  => clk,
        rst                  => rst,
        boot_finish          => boot_finish,

        -- IF/ID pipeline storage
        ifid_instruc         => ifid_instruc,

        -- Control Unit
        ctrl_insert_bubble   => ctrl_insert_bubble,

        -- hard keyboard interrupt
        ps2_hold_key_value   => ps2_hold_key_value,

        -- branch signal
        id_pc_branch         => id_pc_branch,

        -- current id instruction, output for control unit
        id_instruc           => id_instruc,

        -- ID/EX
        idex_instruc         => idex_instruc,
        idex_reg_a_data      => idex_reg_a_data,
        idex_reg_a_data_real => idex_reg_a_data_real,
        idex_reg_b_data      => idex_reg_b_data,
        idex_reg_b_data_real => idex_reg_b_data_real,
        idex_bypass          => idex_bypass,
        idex_bypass_real     => idex_bypass_real,
        idex_reg_wb          => idex_reg_wb,

        r0=>r0, r1=>r1, r2=>r2, r3=>r3,
        r4=>r4, r5=>r5, r6=>r6, r7=>r7, 
        SP=>SP, IH=>IH, T =>T,
        EPC=>EPC, Cause=>Cause,
        pc_real => pc_real
     );

    ---- combination logic multiplexer unit for branch
    process(pc, id_instruc, idex_reg_b_data_real, idex_reg_a_data_real)
    begin
        if (id_pc_branch = '1') then
            case id_instruc(15 downto 11) is
                when BNEZ_op =>
                    if (idex_reg_a_data_real /= zero16) then
                        id_branch_value <= pc - 1 + idex_reg_b_data_real;
                    else
                        id_branch_value <= pc;
                    end if;
                when BEQZ_op =>
                    if (idex_reg_a_data_real = zero16) then
                        id_branch_value <= pc - 1 + idex_reg_b_data_real;
                    else
                        id_branch_value <= pc;
                    end if;
                when B_op =>
                    id_branch_value <= pc - 1 + idex_reg_a_data_real;
                when INT_op =>
                    id_branch_value <= delint_addr;
                when EXTEND_TSP_op =>
                    case id_instruc(10 downto 8) is
                        when EX_BTNEZ_pf_op =>
                            if (idex_reg_a_data_real /= zero16) then
                                id_branch_value <= pc - 1 + idex_reg_b_data_real;
                            else
                                id_branch_value <= pc;
                            end if;
                        when EX_BTEQZ_pf_op =>
                            if (idex_reg_a_data_real = zero16) then
                                id_branch_value <= pc -1 + idex_reg_b_data_real;
                            else
                                id_branch_value <= pc;
                            end if;
                        when others =>
                            id_branch_value <= zero16;
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case id_instruc(4 downto 0) is
                        when EX_PC_sf_op =>
                            case id_instruc(7 downto 5) is
                                when EX_JR_sf_diff_op =>
                                    id_branch_value <= idex_reg_a_data_real;
                                when others =>
                                    id_branch_value <= zero16;
                            end case;
                        when others =>
                            id_branch_value <= zero16;
                    end case;
                when others =>
                    id_branch_value <= zero16;
            end case;
        end if;
    end process;
 
    -- combination logic multiplexer unit for conflict solve
    -- multiplexer map
    Rg_A_mux: mux7to1 port map (idex_reg_a_data_real, ctrl_mux_reg_a, idex_reg_a_data, exme_result,
                        mewb_result, mewb_readout, wb_reg_data, exme_bypass, mewb_bypass);
    Rg_B_mux: mux7to1 port map (idex_reg_b_data_real, ctrl_mux_reg_b, idex_reg_b_data, exme_result,
                        mewb_result, mewb_readout, wb_reg_data, exme_bypass, mewb_bypass);
    Rg_bypass: mux7to1 port map (idex_bypass_real, ctrl_mux_bypass, idex_bypass, exme_result,
                        mewb_result, mewb_readout, wb_reg_data, exme_bypass, mewb_bypass);


--                 ---                                  ---                                  ---
--    idex_reg_a--|   |                    idex_reg_b--|   |     ^_^           idex_bypass--|   |
--    alu_result--| M |                    alu_result--| M |                    alu_result--| M |
--   mewb_result--|   |                   mewb_result--|   |                   mewb_result--|   |
--  mewb_readout--| U |--ex_alu_reg_a    mewb_readout--| U |--ex_alu_reg_b    mewb_readout--| U |--ex_bypass
--   wb_reg_data--|   |                   wb_reg_data--|   |                   wb_reg_data--|   |
--   exme_bypass--| X |                   exme_bypass--| X |                   exme_bypass--| X |
--   mewb_bypass--|   |                   mewb_bypass--|   |                   mewb_bypass--|   |
--                 ---                                  ---                                  ---                

    

    EX_unit: EXE port map (
            clk                   => clk,
            rst                   => rst,

            boot_finish           => boot_finish,
            ctrl_insert_bubble    => ctrl_insert_bubble,

            -- ID/EX
            idex_instruc          => idex_instruc,
            idex_reg_a_data_real  => idex_reg_a_data_real,
            idex_reg_b_data_real  => idex_reg_b_data_real,
            idex_bypass_real      => idex_bypass_real,
            idex_reg_wb           => idex_reg_wb,

            -- EX layer variables
            ex_reg_a_data         => ex_reg_a_data,
            ex_reg_b_data         => ex_reg_b_data,
            ex_alu_op             => ex_alu_op,

            -- EX/MEM pipeline storage
            exme_instruc          => exme_instruc,
            exme_reg_wb           => exme_reg_wb,
            exme_bypass           => exme_bypass
    );

    -- alu map
    ALU_comp: alu port map (rst, ex_reg_a_data, ex_reg_b_data, ex_alu_op, exme_result,
                                exme_carry, exme_zero, exme_ovr);


    ---------------- ME --------------------------
    ME_unit: MEM port map (
            clk                     => clk,
            rst                     => rst,

            boot_finish             => boot_finish,
            boot_write_addr         => boot_write_addr,
            boot_write_data         => boot_write_data,
            boot_write_enable       => boot_write_enable,
            boot_read_enable        => boot_read_enable,

            -- EX/MEM pipeline storage
            exme_instruc            => exme_instruc,
            exme_result             => exme_result,
            exme_reg_wb             => exme_reg_wb,
            exme_bypass             => exme_bypass,

            -- MEM variables           -- MEM variables
            me_read_enable          => me_read_enable,
            me_write_enable         => me_write_enable,
            me_write_enable_real    => me_write_enable_real,
            me_read_addr            => me_read_addr,
            me_write_addr           => me_write_addr,
            me_write_data           => me_write_data,

            seri_wrn_t              => seri_wrn_t,
            seri_rdn_t              => seri_rdn_t,
            seri1_read_enable       => seri1_read_enable,
            seri1_write_enable      => seri1_write_enable,
            seri1_write_enable_real => seri1_write_enable_real,
            seri1_ctrl_read_en      => seri1_ctrl_read_en,

            --MEM/WB pipeline storage
            mewb_instruc            => mewb_instruc,
            mewb_result             => mewb_result,
            mewb_reg_wb             => mewb_reg_wb,
            mewb_bypass             => mewb_bypass
    );


    WB_unit: WB port map (
            clk => clk,  rst => rst,

            boot_finish  => boot_finish,

            --MEM/WB pipeline storage
            mewb_instruc => mewb_instruc,
            mewb_result  => mewb_result,
            mewb_readout => mewb_readout,
            mewb_reg_wb  => mewb_reg_wb,
            mewb_bypass  => mewb_bypass,

            wb_reg_data => wb_reg_data,

            -- register
            r0=>r0, r1=>r1, r2=>r2, r3=>r3,
            r4=>r4, r5=>r5, r6=>r6, r7=>r7,
            SP=>SP, IH=>IH, T =>T
    );


    ---------------- WB --------------------------
    --WB_unit: process(clk, rst)
        --variable wb_data : std_logic_vector(15 downto 0);
        --variable wb_enable : boolean := false;
    --begin
          --if rst = '0' or boot_finish = '0' then
                --r0 <= zero16;
                --r1 <= zero16;
                --r2 <= zero16;
                --r3 <= zero16;
                --r4 <= zero16;
                --r5 <= zero16;
                --r6 <= zero16;
                --r7 <= zero16;
                --SP <= zero16;
                --IH <= zero16;
                --T <= zero16;
                --wb_enable := false;
        --elsif (clk'event and clk='1') then
            --case mewb_instruc(15 downto 11) is
                --when ADDIU_op | ADDIU3_op | EXTEND_RRI_op =>
                    --wb_data := mewb_result;
                    --wb_enable := true;
                --when EXTEND_ALU3_op => -- ADDU, SUBU
                    --wb_data := mewb_result;
                    --wb_enable := true;
                --when LI_op =>
                    --wb_data := mewb_bypass;
                    --wb_enable := true;
                --when LW_op | LW_SP_op =>
                    --wb_data := mewb_readout;
                    --wb_enable := true;
                --when EXTEND_TSP_op =>
                    --case mewb_instruc(10 downto 8) is
                        --when EX_ADDSP_pf_op =>
                            --wb_data := mewb_result;
                            --wb_enable := true;
                        --when EX_MTSP_pf_op =>
                            --wb_data := mewb_bypass;
                            --wb_enable := true;
                        --when others =>
                            --wb_enable := false;
                    --end case;
                --when EXTEND_ALUPCmix_op =>
                    --case mewb_instruc(4 downto 0) is
                        --when EX_AND_sf_op | EX_OR_sf_op | EX_NEG_sf_op | EX_NOT_sf_op | EX_SRLV_sf_op | EX_CMP_sf_op =>
                            --wb_data := mewb_result;
                            --wb_enable := true;
                        --when EX_PC_sf_op =>
                            --case mewb_instruc(7 downto 5) is
                                --when EX_MFPC_sf_diff_op =>
                                    --wb_data := mewb_bypass;
                                    --wb_enable := true;
                                --when others =>
                            --end case;
                        --when others =>
                            --wb_enable := false;
                    --end case;
                --when EXTEND_IH_op =>
                    --case exme_instruc(7 downto 0) is
                        --when EX_MFIH_sf_op | EX_MTIH_sf_op | EX_MFEPC_sf_op | EX_MFCAS_sf_op =>
                            --wb_data := mewb_bypass;
                            --wb_enable := true;
                        --when others =>
                    --end case;
                --when NOP_op =>
                    --wb_enable := false;
                --when others =>
                    --wb_enable := false;
            --end case;
            --if (wb_enable = true) then
                --wb_reg_data <= wb_data;
                --case mewb_reg_wb is
                    --when "0000" =>
                        --r0 <= wb_data;
                    --when "0001" =>
                        --r1 <= wb_data;
                    --when "0010" =>
                        --r2 <= wb_data;
                    --when "0011" =>
                        --r3 <= wb_data;
                    --when "0100" =>
                        --r4 <= wb_data;
                    --when "0101" =>
                        --r5 <= wb_data;
                    --when "0110" =>
                        --r6 <= wb_data;
                    --when "0111" =>
                        --r7 <= wb_data;
                    --when "1000" =>
                        --SP <= wb_data;
                    --when "1001" =>
                        --IH <= wb_data;
                    --when "1010" =>
                        --T <= wb_data;
                    --when others =>
                        ---- for INT register EPC and Cause, they will be assigned 
                        ---- at INT module, that is, no instruction can write them
                --end case;
            --else
                --wb_reg_data <= zero16;
            --end if;

        --end if;
    --end process WB_unit;


    ------------ Control Unit --------------------
    Control_unit: process(clk, rst)
        variable ctrl_wb_reg_0      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_wb_reg_1      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_wb_reg_2      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_wb_reg_3      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_rd_reg_a      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_rd_reg_b      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_rd_bypass     : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_instruc_0     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_instruc_1     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_instruc_2     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_instruc_3     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_fake_nop      : boolean                        := false;
    begin
        if (rst = '0' or boot_finish = '0') then
            ctrl_wb_reg_0  := reg_none;
            ctrl_wb_reg_1  := reg_none;
            ctrl_wb_reg_2  := reg_none;
            ctrl_wb_reg_3  := reg_none;
            ctrl_rd_reg_a  := reg_none;
            ctrl_rd_reg_b  := reg_none;
            ctrl_rd_bypass := reg_none;
            ctrl_instruc_0 := NOP_instruc;
            ctrl_instruc_1 := NOP_instruc;
            ctrl_instruc_2 := NOP_instruc;
            ctrl_instruc_3 := NOP_instruc;
            ctrl_insert_bubble <= '0';
            ctrl_fake_nop  := false;
        elsif (clk'event and clk='1') then
            ctrl_fake_nop  := false;
            ctrl_wb_reg_3  := ctrl_wb_reg_2;
            ctrl_wb_reg_2  := ctrl_wb_reg_1;
            ctrl_wb_reg_1  := ctrl_wb_reg_0;
            ctrl_instruc_3 := ctrl_instruc_2;
            ctrl_instruc_2 := ctrl_instruc_1;
            ctrl_instruc_1 := ctrl_instruc_0;
            if (ctrl_insert_bubble = '1') then        -- if the last instruction need insert bubble
                ctrl_instruc_0 := id_instruc;         -- grab id_instruc, for ifid_instruc currently contain
            else                                      -- next instruction
                ctrl_instruc_0 := ifid_instruc;
            end if;
            case ctrl_instruc_0(15 downto 11) is
                when EXTEND_ALU3_op => -- ADDU, SUBU
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(4 downto 2);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_bypass := reg_none;
                when ADDIU_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when ADDIU3_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when LI_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := reg_none;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when EXTEND_RRI_op =>  -- SLL, SRA, SRL
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when EXTEND_TSP_op => -- ADDSP, BTEQZ, BTNEZ, MTSP
                    case ctrl_instruc_0(10 downto 8) is
                        when EX_BTEQZ_pf_op | EX_BTNEZ_pf_op =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := T_index;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                        when EX_ADDSP_pf_op =>
                            ctrl_wb_reg_0  := SP_index;
                            ctrl_rd_reg_a  := SP_index;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                        when EX_MTSP_pf_op =>
                            ctrl_wb_reg_0  := SP_index;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := "0" & ctrl_instruc_0(7 downto 5);
                        when others =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case ctrl_instruc_0(4 downto 0) is
                        when EX_AND_sf_op | EX_OR_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_bypass := reg_none;
                        when EX_CMP_sf_op =>
                            ctrl_wb_reg_0  := T_index;
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_bypass := reg_none;
                        when EX_NEG_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_bypass := reg_none;
                        when EX_NOT_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                        when EX_SRLV_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_bypass := reg_none;
                        when EX_PC_sf_op =>
                            case ctrl_instruc_0(7 downto 5) is
                                when EX_JR_sf_diff_op =>
                                    ctrl_wb_reg_0  := reg_none;
                                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                                    ctrl_rd_reg_b  := reg_none;
                                    ctrl_rd_bypass := reg_none;
                                when EX_MFPC_sf_diff_op =>
                                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                                    ctrl_rd_reg_a  := reg_none;
                                    ctrl_rd_reg_b  := reg_none;
                                    ctrl_rd_bypass := reg_none;
                                when others =>
                                    ctrl_wb_reg_0  := reg_none;
                                    ctrl_rd_reg_a  := reg_none;
                                    ctrl_rd_reg_b  := reg_none;
                                    ctrl_rd_bypass := reg_none;
                            end case;
                        when others =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                    end case;
                when EXTEND_IH_op =>
                    case ctrl_instruc_0(7 downto 0) is
                        when EX_MFIH_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := IH_index;
                        when EX_MTIH_sf_op =>
                            ctrl_wb_reg_0  := IH_index;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := "0" & ctrl_instruc_0(10 downto 8);
                        when EX_MFEPC_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := EPC_index;
                        when EX_MFCAS_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := Case_index;
                        when others =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                    end case;
                when LW_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when LW_SP_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := SP_index;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when SW_op =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := "0" & ctrl_instruc_0(7 downto 5);
                when SW_SP_op =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := SP_index;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := "0" & ctrl_instruc_0(10 downto 8);
                --when INT_op =>                 -- TODO, add INT hard int control
                    --case 
                when BNEZ_op | BEQZ_op =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when others =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := reg_none;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
            end case;
            conflict_detect(ctrl_fake_nop, ctrl_mux_reg_a, ctrl_mux_reg_b, ctrl_mux_bypass,
                            ctrl_rd_reg_a, ctrl_rd_reg_b, ctrl_rd_bypass, ctrl_wb_reg_1, ctrl_wb_reg_2, ctrl_wb_reg_3,
                            ctrl_instruc_0, ctrl_instruc_1, ctrl_instruc_2, ctrl_instruc_3);
            
            -- INTTERUPPT : insert bubble
            if hard_int_flag = '1' then   -- TODO: int_flag will use for hardware interrupt, not insert_bubble
                ctrl_insert_bubble <= '1';
            elsif (ctrl_fake_nop = true) then
                ctrl_insert_bubble <= '1';
                ctrl_wb_reg_0 := reg_none;
                ctrl_instruc_0 := NOP_instruc;
            else
                ctrl_insert_bubble <= '0';
            end if;

        end if;
    end process Control_unit;

    dyp1 <= "1111111";

    led <= r0    when (instruct(14 downto 11) = r0_index) else
           r1    when (instruct(14 downto 11) = r1_index) else
           r2    when (instruct(14 downto 11) = r2_index) else
           r3    when (instruct(14 downto 11) = r3_index) else
           r4    when (instruct(14 downto 11) = r4_index) else
           r5    when (instruct(14 downto 11) = r5_index) else
           r6    when (instruct(14 downto 11) = r6_index) else
           r7    when (instruct(14 downto 11) = r7_index) else
           SP    when (instruct(14 downto 11) = SP_index) else
           IH    when (instruct(14 downto 11) = IH_index) else
           T     when (instruct(14 downto 11) = T_index) else
           EPC   when (instruct(14 downto 11) = EPC_index) else
           Cause when (instruct(14 downto 11) = Case_index) else
           ps2_hold_key_value when (instruct(14 downto 11) = "1101") else
           seri_wrn_t & seri_rdn_t & seri_tbre & seri_tsre & seri_data_ready & "00000000000"
           when (instruct(14 downto 11) = reg_none);

end Behavioral;

