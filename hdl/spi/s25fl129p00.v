//////////////////////////////////////////////////////////////////////////////
//  File name : s25fl129p00.v
//////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2008 Spansion, LLC.
//
//  MODIFICATION HISTORY :
//
//  version: |   author:      |  mod date: | changes made:
//    v1.0     J.Stoickov        08 Dec 10   Initial release
//
//////////////////////////////////////////////////////////////////////////////
//  PART DESCRIPTION:
//
//  Library:    FLASH
//  Technology: FLASH MEMORY
//  Part:       S25FL129P00
//
//  Description:128 Megabit Serial Flash Memory with 104 MHz SPI Bus Interface
//  Comments :
//      For correct simulation, simulator resolution should be set to 1 ps
//
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// MODULE DECLARATION                                                       //
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ps/1 ps
module s25fl129p00
(
    SCK      ,
    SI       ,

    CSNeg    ,
    HOLDNeg  ,
    WPNeg    ,
    SO
);
////////////////////////////////////////////////////////////////////////
// Port / Part SOIn Declarations
////////////////////////////////////////////////////////////////////////
    input  SCK     ;
    inout  SI      ;

    input  CSNeg   ;
    inout  HOLDNeg ;
    inout  WPNeg   ;
    inout  SO      ;

// interconnect path delay signals
    wire  SCK_ipd           ;
    wire  SI_ipd            ;

    wire  SI_in             ;
    assign SI_in = SI_ipd   ;

    wire  SI_out            ;
    assign SI_out = SI      ;

    wire  CSNeg_ipd    ;
    wire  HOLDNeg_ipd  ;
    wire  WPNeg_ipd    ;
    wire  SO_ipd       ;

    wire   HOLDNeg_in                ;
    assign HOLDNeg_in = HOLDNeg_ipd  ;

    wire   HOLDNeg_out               ;
    assign HOLDNeg_out = HOLDNeg     ;

    wire   WPNeg_in                  ;
    assign WPNeg_in = WPNeg_ipd      ;

    wire   WPNeg_out                 ;
    assign WPNeg_out = WPNeg         ;

    wire  SOIn               ;
    assign SOIn = SO_ipd     ;

    wire  SOut              ;
    assign SOut = SO        ;

//  internal delays
    reg PP_in       ;
    reg PP_out      ;
    reg PU_in       ;
    reg PU_out      ;
    reg SE_in       ;
    reg SE_out      ;
    reg BE_in       ;
    reg BE_out      ;
    reg PE_in       ;
    reg PE_out      ;
    reg WR_in       ;
    reg WR_out      ;
    reg DP_in       ;
    reg DP_out      ;
    reg EP_in       ;
    reg EP_out      ;
    reg RES_in      ;
    reg RES_out     ;

    reg SOut_zd = 1'bZ;
    reg SOut_z  = 1'bZ;

    wire    SI_z                ;
    wire    SO_z                ;

    reg     SIOut_zd = 1'bZ     ;
    reg     SIOut_z  = 1'bZ     ;

    reg     WPNegOut_zd   = 1'bZ  ;
    reg     HOLDNegOut_zd = 1'bZ  ;

    assign SI_z = SIOut_z;
    assign SO_z = SOut_z;

    parameter UserPreload       = 1;
    parameter mem_file_name     = "none";//"s25fl129p00.mem";
    parameter otp_file_name     = "none";//"s25fl129p00_secsi.mem";

    parameter TimingModel   = "DefaultTimingModel";

    parameter PartID        = "s25fl129p00";
    parameter MaxData       = 255;
    parameter SecSize       = 16'hFFFF;
    parameter SecSize_4     = 4095;
    parameter SecSize_8     = 8191;
    parameter SecNum        = 255;
    parameter PageNum       = 16'hFFFF;
    parameter OTPSize       = 511;
    parameter OTPLoAddr     = 9'h100;
    parameter OTPHiAddr     = 10'h2FF;
    parameter HiAddrBit     = 23;
    parameter AddrRANGE     = 24'hFFFFFF;
    parameter BYTE          = 8;
    parameter Manuf_ID      = 8'h01;
    parameter ES            = 8'h17;
    parameter Jedec_ID      = 8'h20; // first byte of Device ID
    parameter DeviceID      = 16'h2018;
    parameter ExtendedBytes = 8'h4D;
    parameter ExtendedID    = 8'h01;
    parameter DieRev        = 8'h01;
    parameter MaskRev       = 8'h00;

    // If speed simulation is needed uncomment following line

    //`define SPEEDSIM;

    // powerup
    reg PoweredUp;

    //FSM control signals
    reg PDONE    ; ////Prog. Done
    reg PSTART   ; ////Start Programming

    reg EDONE    ; ////Era. Done
    reg ESTART   ; ////Start Erasing

    reg WDONE    ; //// Writing Done
    reg WSTART   ; ////Start writing

    //Command Register
    reg write;
    reg read_out;

    //Status reg.
    reg[7:0] Status_reg      = 8'b0;
    reg[7:0] Status_reg_in   = 8'b0;
    reg[7:0] Sec_conf_reg    = 8'b0;
    reg[7:0] Sec_conf_reg_in = 8'b0;

    wire FREEZE;
    wire QUAD;
    wire TBPARAM;
    wire BPNV;
    wire LOCK;
    wire TBPROT;
    assign FREEZE   = Sec_conf_reg[0];
    assign QUAD     = Sec_conf_reg[1];
    assign TBPARAM  = Sec_conf_reg[2];
    assign BPNV     = Sec_conf_reg[3];
    assign LOCK     = Sec_conf_reg[4];
    assign TBPROT   = Sec_conf_reg[5];

    wire WIP;
    wire WEL;
    wire [2:0]BP;
    wire E_ERR;
    wire P_ERR;
    wire SRWD;
    assign WIP      = Status_reg[0];
    assign WEL      = Status_reg[1];
    assign BP       = Status_reg[4:3];
    assign E_ERR    = Status_reg[5];
    assign P_ERR    = Status_reg[6];
    assign SRWD     = Status_reg[7];

    integer SA        = 0;         // 0 TO SecNum+1
    integer Byte_number = 0;
    integer sect;

    //Address
    integer Address = 0;         // 0 - AddrRANGE
    reg  change_addr;
    reg  rd_fast;       // = 1'b1;
    reg  rd_slow;
    reg  change_BP = 0;
    reg  rd_dual;
    reg  dual;
    wire fast_rd;
    wire rd;

    wire RD_EQU_1;
    assign RD_EQU_1 = rd_slow;

    wire RD_EQU_0;
    assign RD_EQU_0 = ~rd_slow;

    reg  hold_mode;
    reg  mpm_mode = 0;
    wire hold;

    //Sector Protection Status
    reg [SecNum:0] Sec_Prot = 256'b0; //= SecNum'b0;

    // timing check violation
    reg Viol = 1'b0;

    integer Mem[0:AddrRANGE];
    integer OTPMem[OTPLoAddr: OTPHiAddr];

    integer WByte[0:255];
    integer WOTPByte;
    integer AddrLo;
    integer AddrHi;

    reg[7:0]  old_bit, new_bit;
    integer old_int, new_int;
    integer wr_cnt;
    integer cnt;

    integer read_cnt = 0;
    integer read_addr = 0;
    reg[7:0] data_out;
    reg[647:0] ident_out;

    reg oe = 1'b0;
    event oe_event;

    integer CFI_array[8'h07:8'h50];
    reg [591:0] CFI_array_tmp;
    reg [7:0] CFI_tmp;

    reg[15:0] PR_LOCK1;
    reg[15:0] PR_LOCK2;
    reg[15:0] PR_LOCK3;
///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////

 buf   (SCK_ipd, SCK);
 buf   (SI_ipd, SI);

 buf   (CSNeg_ipd, CSNeg);
 buf   (HOLDNeg_ipd, HOLDNeg);
 buf   (WPNeg_ipd, WPNeg);
 buf   (SO_ipd, SO);

///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////
    nmos   (SO,   SO_z , 1);

    nmos   (SI,   SI_z , 1);
    nmos   (HOLDNeg,   HOLDNegOut_zd , 1);
    nmos   (WPNeg,   WPNegOut_zd , 1);

    wire deg_pin;
    wire deg_sin;
    wire deg_holdin;
    //VHDL VITAL CheckEnable equivalents
    wire dual_wr;
    assign dual_wr = deg_holdin && QUAD;
    wire quad_wr;
    assign quad_wr = SRWD && WEL ;
    wire dual_rd;
    assign dual_rd = dual;
    wire power;
    assign power = PoweredUp;

 specify
        // tipd delays: interconnect path delays , mapped to input port delays.
        // In Verilog is not necessary to declare any tipd_ delay variables,
        // they can be taken from SDF file
        // With all the other delays real delays would be taken from SDF file

                        // tpd delays
     specparam           tpd_SCK_SO             =1;
     specparam           tpd_SCK_SI             =1;
     specparam           tpd_CSNeg_SO           =1;
     specparam           tpd_HOLDNeg_SO         =1;

     specparam           tsetup_SI_SCK          =1;   //tsuDAT /
     specparam           tsetup_CSNeg_SCK       =1;   // tCSS /
     specparam           tsetup_HOLDNeg_SCK     =1;   //tHD /
     specparam           tsetup_SCK_HOLDNeg     =1;   //tCH \
     specparam           tsetup_WPNeg_CSNeg     =1;   //tWPS \

                          // thold values: hold times
     specparam           thold_SI_SCK           =1; //thdDAT /
     specparam           thold_CSNeg_SCK        =1; //tCSH /
     specparam           thold_HOLDNeg_SCK      =1; //tCHHH /
     specparam           thold_SCK_HOLDNeg      =1; //tHC \
     specparam           thold_WPNeg_CSNeg      =1; //tWPH \

        // tpw values: pulse width
     specparam           tpw_SCK_fast_posedge    =1; //tWH
     specparam           tpw_SCK_posedge         =1; //tWH
     specparam           tpw_SCK_dual_posedge    =1; //tWH
     specparam           tpw_SCK_fast_negedge    =1; //tWL
     specparam           tpw_SCK_negedge         =1; //tWL
     specparam           tpw_SCK_dual_negedge    =1; //tWL
     specparam           tpw_CSNeg_read_posedge  =1; //tCS
     specparam           tpw_CSNeg_pgm_posedge   =1; //tCS

        // tperiod min (calculated as 1/max freq)
     specparam           tperiod_SCK_rd              =1; // fSCK = 40MHz
     specparam           tperiod_SCK_fast_rd         =1; // fSCK = 104MHz
     specparam           tperiod_SCK_dual_fast_rd    =1; // fSCK = 80MHz

        // tdevice values: values for internal delays
        `ifdef SPEEDSIM
            // Page Program Operation
            specparam   tdevice_PP                     = 3e7; //30 us;
                    //Page Program Operation (ACC=9V))
            specparam   tdevice_EP                     = 2.4e9; //2.4 ms;
                    //Sector Erase Operation
            specparam   tdevice_SE                     = 2e9; //2 ms;
                    //Bulk Erase Operation
            specparam   tdevice_BE                     = 256e9; //256 ms;
                    //Write Status Register Operation
            specparam   tdevice_WR                     = 1e9; // 1 ms;
                    //Software Protect Mode
            specparam   tdevice_DP                     = 10000000; // 10 us;
                    //Release from Software Protect Mode
            specparam   tdevice_RES                    = 30000000; // 30 us;
                    //Parameter block erase
            specparam   tdevice_PE                     = 800e6; //800 us;
                    //VCC (min) to CS# Low
            specparam   tdevice_PU                     = 15e9; //15 ms;
        `else
            // Page Program Operation
            specparam   tdevice_PP                     = 3e9; //3 ms;
                    //Page Program Operation (ACC=9V))
            specparam   tdevice_EP                     = 2.4e9; //2.4 ms;
                    //Sector Erase Operation
            specparam   tdevice_SE                     = 2e12; //2 s;
                    //Bulk Erase Operation
            specparam   tdevice_BE                     = 256e12; //256 sec;
                    //Write Status Register Operation
            specparam   tdevice_WR                     = 100e9; // 100 ms;
                    //Software Protect Mode
            specparam   tdevice_DP                     = 10000000; // 10 us;
                    //Release from Software Protect Mode
            specparam   tdevice_RES                    = 30000000; // 30 us;
                    //Parameter block erase
            specparam   tdevice_PE                     = 800e9; //800 ms;
                    //VCC (min) to CS# Low
            specparam   tdevice_PU                     = 15e9; //15 ms;
        `endif//SPEEDSIM

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////
  if (~dual) (SCK => SO) = tpd_SCK_SO;
  if (dual)  (SCK => SO) = tpd_SCK_SI;
  if (CSNeg)(CSNeg => SO) = tpd_CSNeg_SO;
  if (~dual) (HOLDNeg => SO) = tpd_HOLDNeg_SO;
  if (dual)  (HOLDNeg => SO) = tpd_HOLDNeg_SO;

  if (dual)(SCK => SI) = tpd_SCK_SI;
  if (dual && CSNeg)(CSNeg => SI) = tpd_CSNeg_SO;
  if (dual)(HOLDNeg => SI) = tpd_HOLDNeg_SO;

  if (dual && QUAD)(SCK => HOLDNeg) = tpd_SCK_SI;
  if (dual && CSNeg && QUAD)(CSNeg => HOLDNeg) = tpd_CSNeg_SO;

  if (dual && QUAD)(SCK => WPNeg) = tpd_SCK_SI;
  if (dual && CSNeg && QUAD)(CSNeg => WPNeg) = tpd_CSNeg_SO;
////////////////////////////////////////////////////////////////////////////////
// Timing Violation                                                           //
////////////////////////////////////////////////////////////////////////////////
        $setup ( SI             , posedge SCK &&& deg_sin,
                                                tsetup_SI_SCK, Viol);
        $setup ( negedge HOLDNeg, posedge SCK &&& dual_wr,
                                                tsetup_HOLDNeg_SCK, Viol);
        $setup ( posedge SCK    , posedge HOLDNeg &&& dual_wr,
                                                tsetup_SCK_HOLDNeg, Viol);
        $setup ( CSNeg          , posedge SCK &&& power,
                                                tsetup_CSNeg_SCK, Viol);
        $setup ( WPNeg          , negedge CSNeg &&& WPNeg,
                                                tsetup_WPNeg_CSNeg, Viol);

        $hold ( posedge SCK     , SI &&& deg_sin,
                                                thold_SI_SCK, Viol);
        $hold ( posedge HOLDNeg , posedge SCK &&& dual_wr,
                                                thold_SCK_HOLDNeg, Viol);
        $hold ( posedge SCK     , CSNeg &&& power,
                                                thold_CSNeg_SCK, Viol);
        $hold ( posedge CSNeg   , WPNeg &&& quad_wr,
                                                thold_WPNeg_CSNeg, Viol);
        $hold ( posedge SCK     , negedge HOLDNeg &&& dual_wr,
                                                thold_HOLDNeg_SCK, Viol);

        $width (posedge SCK &&& rd      , tpw_SCK_posedge);
        $width (posedge SCK &&& fast_rd , tpw_SCK_fast_posedge);
        $width (posedge SCK &&& dual_rd , tpw_SCK_dual_posedge);
        $width (negedge SCK &&& rd      , tpw_SCK_negedge);
        $width (negedge SCK &&& fast_rd , tpw_SCK_fast_negedge);
        $width (negedge SCK &&& dual_rd , tpw_SCK_dual_negedge);

        $width (posedge CSNeg &&& RD_EQU_0, tpw_CSNeg_pgm_posedge);
        $width (posedge CSNeg &&& RD_EQU_1, tpw_CSNeg_read_posedge);

        $period (posedge SCK &&& rd, tperiod_SCK_rd);
        $period (posedge SCK &&& fast_rd, tperiod_SCK_fast_rd);
        $period (posedge SCK &&& dual_rd, tperiod_SCK_dual_fast_rd);

    endspecify

            // Page Program Operation
            parameter   tdevice_PP                     = 3e7; //30 us;
                    //Page Program Operation (ACC=9V))
            parameter   tdevice_EP                     = 2.4e9; //2.4 ms;
                    //Sector Erase Operation
            parameter   tdevice_SE                     = 2e9; //2 ms;
                    //Bulk Erase Operation
            parameter   tdevice_BE                     = 256e9; //256 ms;
                    //Write Status Register Operation
            parameter   tdevice_WR                     = 1e9; // 1 ms;
                    //Software Protect Mode
            parameter   tdevice_DP                     = 10000000; // 10 us;
                    //Release from Software Protect Mode
            parameter   tdevice_RES                    = 30000000; // 30 us;
                    //Parameter block erase
            parameter   tdevice_PE                     = 800e6; //800 us;
                    //VCC (min) to CS# Low
            parameter   tdevice_PU                     = 15e9; //15 ms;
////////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                        //
////////////////////////////////////////////////////////////////////////////////
// FSM states
 parameter IDLE            =4'd0;
 parameter WRITE_SR        =4'd1;
 parameter DP_DOWN_WAIT    =4'd2;
 parameter DP_DOWN         =4'd3;
 parameter SECTOR_ER       =4'd4;
 parameter BULK_ER         =4'd5;
 parameter PAGE_PG         =4'd6;
 parameter OTP_PG          =4'd7;
 parameter P4_ER           =4'd8;
 parameter P8_ER           =4'd9;

 reg [3:0] current_state;
 reg [3:0] next_state;

// Instructions
 parameter NONE            =5'd0;
 parameter WREN            =5'd1;
 parameter WRDI            =5'd2;
 parameter WRR             =5'd3;
 parameter RDSR            =5'd4;
 parameter READ            =5'd5;
 parameter READ_ID         =5'd6;
 parameter RDID            =5'd7;
 parameter FAST_READ       =5'd8;
 parameter DUAL_READ       =5'd9;
 parameter QUAD_READ       =5'd10;
 parameter DH_READ         =5'd11;
 parameter QH_READ         =5'd12;
 parameter SE              =5'd13;
 parameter BE              =5'd14;
 parameter PP              =5'd15;
 parameter QPP             =5'd16;
 parameter DP              =5'd17;
 parameter RES_READ_ES     =5'd18;
 parameter CLSR            =5'd19;
 parameter RCR             =5'd20;
 parameter P4E             =5'd21;
 parameter P8E             =5'd22;
 parameter OTPP            =5'd23;
 parameter OTPR            =5'd24;
 reg [4:0] Instruct;

//Bus cycle states
 parameter STAND_BY        =3'd0;
 parameter CODE_BYTE       =3'd1;
 parameter ADDRESS_BYTES   =3'd2;
 parameter DUMMY_BYTES     =3'd3;
 parameter MODE_BYTE       =3'd4;
 parameter DATA_BYTES      =3'd5;

 reg [2:0] bus_cycle_state;

 reg deq_pin;
    always @(SOIn, SO_z)
    begin
      if (SOIn==SO_z)
        deq_pin=1'b0;
      else
        deq_pin=1'b1;
    end
    // chech when data is generated from model to avoid setuphold check in
    // those occasion
    assign deg_pin=deq_pin;

 reg deq_sin;
    always @(SI_in, SIOut_z)
    begin
      if (SI_in==SIOut_z)
        deq_sin=1'b0;
      else
        deq_sin=1'b1;
    end
    // chech when data is generated from model to avoid setuphold check in
    // those occasion
    assign deg_sin=deq_sin;

 reg deq_holdin;
    always @(HOLDNeg_in, HOLDNegOut_zd)
    begin
      if (HOLDNeg_in==HOLDNegOut_zd)
        deq_holdin=1'b0;
      else
        deq_holdin=1'b1;
    end
    // chech when data is generated from model to avoid setuphold check in
    // those occasion
    assign deg_holdin=deq_holdin;

    initial
    begin : Init

        write       = 1'b0;
        read_out    = 1'b0;
        Address     = 0;
        change_addr = 1'b0;

        PDONE       = 1'b1;
        PSTART      = 1'b0;

        EDONE       = 1'b1;
        ESTART      = 1'b0;

        WDONE       = 1'b1;
        WSTART      = 1'b0;

        DP_in       = 1'b0;
        DP_out      = 1'b0;
        RES_in      = 1'b0;
        RES_out     = 1'b0;
        Instruct    = NONE;

        bus_cycle_state = STAND_BY;
        current_state   = IDLE;
        next_state      = IDLE;
    end

    //CFI
    initial
    begin: InitCFI
    integer i;
    integer j;

            CFI_array[8'h07] = 8'hFF;
            CFI_array[8'h08] = 8'hFF;
            CFI_array[8'h09] = 8'hFF;
            CFI_array[8'h0A] = 8'hFF;
            CFI_array[8'h0B] = 8'hFF;
            CFI_array[8'h0C] = 8'hFF;
            CFI_array[8'h0D] = 8'hFF;
            CFI_array[8'h0E] = 8'hFF;
            CFI_array[8'h0F] = 8'hFF;
            CFI_array[8'h10] = 8'h51;
            CFI_array[8'h11] = 8'h52;
            CFI_array[8'h12] = 8'h59;
            CFI_array[8'h13] = 8'h02;
            CFI_array[8'h14] = 8'h00;
            CFI_array[8'h15] = 8'h40;
            CFI_array[8'h16] = 8'h00;
            CFI_array[8'h17] = 8'h00;
            CFI_array[8'h18] = 8'h00;
            CFI_array[8'h19] = 8'h00;
            CFI_array[8'h1A] = 8'h00;
            //System interface string
            CFI_array[8'h1B] = 8'h27;
            CFI_array[8'h1C] = 8'h36;
            CFI_array[8'h1D] = 8'h00;
            CFI_array[8'h1E] = 8'h00;
            CFI_array[8'h1F] = 8'h0B;
            CFI_array[8'h20] = 8'h0B;
            CFI_array[8'h21] = 8'h09;
            CFI_array[8'h22] = 8'h11;
            CFI_array[8'h23] = 8'h01;
            CFI_array[8'h24] = 8'h01;
            CFI_array[8'h25] = 8'h02;
            CFI_array[8'h26] = 8'h01;
            //device geometry definition
            CFI_array[8'h27] = 8'h18;
            CFI_array[8'h28] = 8'h05;
            CFI_array[8'h29] = 8'h00;
            CFI_array[8'h2A] = 8'h08;
            CFI_array[8'h2B] = 8'h00;
            CFI_array[8'h2C] = 8'h02;
            CFI_array[8'h2D] = 8'h1F;
            CFI_array[8'h2E] = 8'h00;
            CFI_array[8'h2F] = 8'h10;
            CFI_array[8'h30] = 8'h00;
            CFI_array[8'h31] = 8'hFD;
            CFI_array[8'h32] = 8'h00;
            CFI_array[8'h33] = 8'h00;
            CFI_array[8'h34] = 8'h01;
            CFI_array[8'h35] = 8'h00;
            CFI_array[8'h36] = 8'h00;
            CFI_array[8'h37] = 8'h00;
            CFI_array[8'h38] = 8'h00;
            CFI_array[8'h39] = 8'h00;
            CFI_array[8'h3A] = 8'h00;
            CFI_array[8'h3B] = 8'h00;
            CFI_array[8'h3C] = 8'h00;
            CFI_array[8'h3D] = 8'hFF;
            CFI_array[8'h3E] = 8'hFF;
            CFI_array[8'h3F] = 8'hFF;
            //primary vendor-specific extended query
            CFI_array[8'h40] = 8'h50;
            CFI_array[8'h41] = 8'h52;
            CFI_array[8'h42] = 8'h49;
            CFI_array[8'h43] = 8'h31;
            CFI_array[8'h44] = 8'h33;
            CFI_array[8'h45] = 8'h05;
            CFI_array[8'h46] = 8'h00;
            CFI_array[8'h47] = 8'h04;
            CFI_array[8'h48] = 8'h00;
            CFI_array[8'h49] = 8'h05;
            CFI_array[8'h4A] = 8'h00;
            CFI_array[8'h4B] = 8'h01;
            CFI_array[8'h4C] = 8'h03;
            CFI_array[8'h4D] = 8'h85;
            CFI_array[8'h4E] = 8'h95;
            CFI_array[8'h4F] = 8'h07;
            CFI_array[8'h50] = 8'h00;

            for(i=73;i>=0;i=i-1)
            begin
                CFI_tmp = CFI_array[8'h07-i+73];
                for(j=7;j>=0;j=j-1)
                begin
                    CFI_array_tmp[8*i+j] = CFI_tmp[j];
                end
            end
    end

    // initialize memory
    initial
    begin: InitMemory
    integer i;

        for (i=0;i<=AddrRANGE;i=i+1)
        begin
            Mem[i] = MaxData;
        end

        if ((UserPreload) && !(mem_file_name == "none"))
        begin
           // Memory Preload
           //s25fl129p00.mem, memory preload file
           //  @aaaaaa - <aaaaaa> stands for address
           //  dd      - <dd> is byte to be written at Mem(aaaaaa++)
           // (aaaaaa is incremented at every load)
           $readmemh(mem_file_name,Mem);
        end

        for (i=OTPLoAddr;i<=OTPHiAddr;i=i+1)
        begin
            OTPMem[i] = MaxData;
        end
        if (UserPreload && !(otp_file_name == "none"))
        begin
        //s25fl129p00_secsi memory file
        //   /       - comment
        //   @aaaaaa     - <aaaaaa> stands for address within last defined
        //   sector
        //   dd      - <dd> is byte to be written at SecSi(aaaaaa++)
        //   (aa is incremented at every load)
        //   only first 1-5 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
           $readmemh(otp_file_name,OTPMem);
        end
        PR_LOCK1[15:8] = 16'h0;
        PR_LOCK1[7:0]  = OTPMem[256];

        PR_LOCK2[15:8] = OTPMem[275];
        PR_LOCK2[7:0]  = OTPMem[274];

        PR_LOCK3[15:8] = OTPMem[533];
        PR_LOCK3[7:0]  = OTPMem[532];
    end

    //Power Up time;
    initial
    begin
        PoweredUp = 1'b0;
        #tdevice_PU PoweredUp = 1'b1;
    end

   always @(posedge DP_in)
   begin:TDPr
     #tdevice_DP DP_out = DP_in;
   end
   always @(negedge DP_in)
   begin:TDPf
     #1 DP_out = DP_in;
   end

   always @(posedge RES_in)
   begin:TRESr
     #tdevice_RES RES_out = RES_in;
   end
   always @(negedge RES_in)
   begin:TRESf
     #1 RES_out = RES_in;
   end

   always @(next_state or PoweredUp)
   begin: StateTransition
       if (PoweredUp)
       begin
           current_state = next_state;
       end
   end

   always @(PoweredUp)
   begin:CheckCEOnPowerUP
       if ((~PoweredUp) && (~CSNeg_ipd))
           $display ("Device is selected during Power Up");
   end

//   ///////////////////////////////////////////////////////////////////////////
//   // Instruction cycle decode
//   ///////////////////////////////////////////////////////////////////////////
 integer data_cnt = 0;
 integer addr_cnt = 0;
 integer code_cnt = 0;
 integer mode_cnt = 0;
 integer dummy_cnt = 0;
 integer bit_cnt = 0;

 reg[2047:0] Data_in = 2048'b0;
 integer quad_data_in [0:511];
 reg[3:0] quad_nybble = 4'b0;
 reg[3:0] Quad_slv = 4'b0;
 reg[7:0] code = 8'b0;
 reg[7:0] code_in = 8'b0;
 reg[7:0] Byte_slv = 8'b0;
 reg[HiAddrBit:0] addr_bytes;
 reg[23:0] Address_in = 8'b0;
 reg[7:0] mode_bytes;
 reg[7:0] mode_in;

 reg rising_edge_CSNeg_ipd  = 1'b0;
 reg falling_edge_CSNeg_ipd = 1'b0;
 reg rising_edge_SCK_ipd    = 1'b0;
 reg falling_edge_SCK_ipd   = 1'b0;

    always @(falling_edge_CSNeg_ipd or rising_edge_CSNeg_ipd
    or rising_edge_SCK_ipd or falling_edge_SCK_ipd)
    begin: Buscycle1
        integer i;
        integer j;
        integer k;
        if (falling_edge_CSNeg_ipd)
        begin
            if (bus_cycle_state==STAND_BY)
            begin
                bus_cycle_state = CODE_BYTE;
                Instruct = NONE;
                write = 1'b1;
                code_cnt = 0;
                addr_cnt = 0;
                data_cnt = 0;
                mode_cnt = 0;
                dummy_cnt = 0;
            end
        end

        if (rising_edge_SCK_ipd)
        begin
            if (~CSNeg_ipd)
            begin
                case (bus_cycle_state)
                    CODE_BYTE :
                    begin
                        if (HOLDNeg_in)
                        begin
                            code_in[code_cnt] = SI_in;
                            code_cnt = code_cnt + 1;
                            if (code_cnt == BYTE)
                            begin
                                for (i=0;i<=7;i=i+1)
                                begin
                                    code[i] = code_in[7-i];
                                end
                                case(code)
                                    8'b00000110 :
                                    begin
                                        Instruct = WREN;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00000100 :
                                    begin
                                        Instruct = WRDI;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00000001 :
                                    begin
                                        Instruct = WRR;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00000101 :
                                    begin
                                        Instruct = RDSR;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00000011 :
                                    begin
                                        Instruct = READ;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b00001011 :
                                    begin
                                        Instruct = FAST_READ;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b10011111 :
                                    begin
                                        Instruct = RDID;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b10010000 :
                                    begin
                                        Instruct = READ_ID;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b10101011 :
                                    begin
                                        Instruct = RES_READ_ES;
                                        bus_cycle_state = DUMMY_BYTES;
                                    end
                                    8'b11011000 :
                                    begin
                                        Instruct = SE;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b11000111 ,  8'b01100000:
                                    begin
                                        Instruct = BE;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00000010 :
                                    begin
                                        Instruct = PP;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b00110010 :
                                    begin
                                        Instruct = QPP;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b10111001 :
                                    begin
                                        Instruct = DP;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00110000 :
                                    begin
                                        Instruct = CLSR;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00110101 :
                                    begin
                                        Instruct = RCR;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                    8'b00100000 :
                                    begin
                                        Instruct = P4E;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b01000000 :
                                    begin
                                        Instruct = P8E;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b01000010 :
                                    begin
                                        Instruct = OTPP;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b01001011 :
                                    begin
                                        Instruct = OTPR;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b00111011 :
                                    begin
                                        Instruct = DUAL_READ;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b01101011 :
                                    begin
                                        Instruct = QUAD_READ;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b10111011 :
                                    begin
                                        Instruct = DH_READ;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                    8'b11101011 :
                                    begin
                                        Instruct = QH_READ;
                                        bus_cycle_state = ADDRESS_BYTES;
                                    end
                                endcase
                            end
                        end
                    end

                    ADDRESS_BYTES :
                    begin
                        if (((Instruct == FAST_READ || Instruct == OTPR ||
                            Instruct == DUAL_READ) && HOLDNeg_in) ||
                            ((Instruct == QUAD_READ) && QUAD))
                        begin
                            Address_in[addr_cnt] = SI_in;
                            addr_cnt = addr_cnt + 1;
                            if (addr_cnt == 3*BYTE)
                            begin
                                for (i=23;i>=23-HiAddrBit;i=i-1)
                                begin
                                    addr_bytes[23-i] = Address_in[i];
                                end
                                Address = addr_bytes;
                                change_addr = 1'b1;
                                #1 change_addr = 1'b0;
                                bus_cycle_state = DUMMY_BYTES;
                            end
                        end
                        else if (Instruct == DH_READ && HOLDNeg_in)
                        begin
                            if (SOIn !== 1'b0 && SOIn !== 1'b1)
                            begin
                                mpm_mode = 0;
                                bus_cycle_state = STAND_BY;
                            end
                            else
                            begin
                                Address_in[2*addr_cnt]   = SOIn;
                                Address_in[2*addr_cnt+1] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 12)
                                begin
                                    addr_cnt = 0;
                                    for (i=23;i>=23-HiAddrBit;i=i-1)
                                    begin
                                        addr_bytes[23-i] = Address_in[i];
                                    end
                                    Address = addr_bytes;
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;
                                    bus_cycle_state = MODE_BYTE;
                                end
                            end
                        end
                        else if (Instruct == QH_READ)
                        begin
                            if(QUAD)
                            begin
                                if (SOIn !== 1'b0 && SOIn !== 1'b1)
                                begin
                                    mpm_mode = 0;
                                    bus_cycle_state = STAND_BY;
                                end
                                else
                                begin
                                    Address_in[4*addr_cnt]   = HOLDNeg_in;
                                    Address_in[4*addr_cnt+1] = WPNeg_in;
                                    Address_in[4*addr_cnt+2] = SOIn;
                                    Address_in[4*addr_cnt+3] = SI_in;
                                    read_cnt = 0;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 6)
                                    begin
                                        addr_cnt = 0;
                                        for (i=23;i>=23-HiAddrBit;i=i-1)
                                        begin
                                            addr_bytes[23-i] = Address_in[i];
                                        end
                                        Address = addr_bytes;
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        bus_cycle_state = MODE_BYTE;
                                    end
                                end
                            end
                            else
                            begin
                                bus_cycle_state = STAND_BY;
                            end
                        end
                        else if (HOLDNeg_in)
                        begin
                            Address_in[addr_cnt] = SI_in;
                            addr_cnt = addr_cnt + 1;
                            if (addr_cnt == 3*BYTE)
                            begin
                                for (i=23;i>=23-HiAddrBit;i=i-1)
                                begin
                                    addr_bytes[23-i] = Address_in[i];
                                end
                                Address = addr_bytes;
                                change_addr = 1'b1;
                                #1 change_addr = 1'b0;
                                bus_cycle_state = DATA_BYTES;
                            end
                        end
                    end

                    MODE_BYTE :
                    begin
                        if((Instruct == DH_READ) && HOLDNeg_in)
                        begin
                            mode_in[2*mode_cnt]   = SOIn;
                            mode_in[2*mode_cnt+1] = SI_in;
                            mode_cnt = mode_cnt + 1;
                            if (mode_cnt == BYTE/2)
                            begin
                                mode_cnt = 0;
                                for (i=7;i>=7-BYTE;i=i-1)
                                begin
                                    mode_bytes[i] = mode_in[7-i];
                                end
                                bus_cycle_state = DATA_BYTES;
                            end
                        end
                        else if((Instruct == QH_READ) && QUAD)
                        begin
                            mode_in[4*mode_cnt]   = HOLDNeg_in;
                            mode_in[4*mode_cnt+1] = WPNeg_in;
                            mode_in[4*mode_cnt+2] = SOIn;
                            mode_in[4*mode_cnt+3] = SI_in;
                            mode_cnt = mode_cnt + 1;
                            if (mode_cnt == BYTE/4)
                            begin
                                mode_cnt = 0;
                                for (i=7;i>=7-BYTE;i=i-1)
                                begin
                                    mode_bytes[i] = mode_in[7-i];
                                end
                                bus_cycle_state = DUMMY_BYTES;
                            end
                        end
                        dummy_cnt = 0;
                    end

                    DUMMY_BYTES :
                    begin
                        if(QUAD && (Instruct == QUAD_READ ||
                           Instruct == QH_READ))
                        begin
                            dummy_cnt = dummy_cnt + 1;
                            if ((dummy_cnt == BYTE) && Instruct == QUAD_READ)
                                bus_cycle_state = DATA_BYTES;
                            else if ((dummy_cnt == BYTE/2) &&
                                      Instruct == QH_READ)
                                bus_cycle_state = DATA_BYTES;
                        end
                        else if(HOLDNeg_in)
                        begin
                            dummy_cnt = dummy_cnt + 1;
                            if (dummy_cnt == BYTE && (Instruct == FAST_READ ||
                                Instruct == OTPR || Instruct == DUAL_READ))
                                bus_cycle_state = DATA_BYTES;
                            else if (dummy_cnt == 3*BYTE)
                                bus_cycle_state = DATA_BYTES;
                        end
                    end

                    DATA_BYTES :
                    begin
                        if(QUAD && Instruct == QPP)
                        begin
                            quad_nybble = {HOLDNeg_in, WPNeg_in, SOIn, SI_in};
                            if (data_cnt > 511)
                            begin
                                //In case of quad mode and QPP,
                                //if more than 512 bytes are sent to the device
                                for (i=0;i<=510;i=i+1)
                                begin
                                    quad_data_in[i] = quad_data_in[i+1];
                                end
                                quad_data_in[511] = quad_nybble;
                                data_cnt = data_cnt + 1;
                            end
                            else
                            begin
                                if( quad_nybble !== 4'bZZZZ)
                                begin
                                    quad_data_in[data_cnt] = quad_nybble;
                                end
                                data_cnt = data_cnt + 1;
                            end
                        end
                        else if (HOLDNeg_in)
                        begin
                            if (data_cnt > 2047)
                            //In case of serial mode and PP, if more than 256
                            //bytes are sent to the device
                            begin
                                if (bit_cnt == 0)
                                begin
                                    for (i=0;i<=(255*BYTE-1);i=i+1)
                                    begin
                                        Data_in[i] = Data_in[i+8];
                                    end
                                end
                                Data_in[2040 + bit_cnt] = SI_in;
                                bit_cnt = bit_cnt + 1;
                                if (bit_cnt == 8)
                                begin
                                    bit_cnt = 0;
                                end
                                data_cnt = data_cnt + 1;
                            end
                            else
                            begin
                                Data_in[data_cnt] = SI_in;
                                data_cnt = data_cnt + 1;
                                bit_cnt = 0;
                            end
                        end
                    end
                endcase
            end
        end
        if (falling_edge_SCK_ipd)
        begin
            if ((bus_cycle_state == DATA_BYTES) && (~CSNeg_ipd))
            begin
                if (((Instruct == READ || Instruct == FAST_READ ||
                    Instruct == DUAL_READ || Instruct == DH_READ ||
                    Instruct == RES_READ_ES || Instruct == RDID ||
                    Instruct == RDSR || Instruct == READ_ID ||
                    Instruct == RCR || Instruct == OTPR) && HOLDNeg_in) ||
                    ((Instruct == QUAD_READ || Instruct == QH_READ) && QUAD))
                begin
                    read_out = 1'b1;
                    #1 read_out = 1'b0;
                end
            end
        end
        if (rising_edge_CSNeg_ipd)
        begin
            if ((bus_cycle_state != DATA_BYTES) && (bus_cycle_state !=
                                                            DUMMY_BYTES))
                bus_cycle_state = STAND_BY;
            else
            begin
            if (bus_cycle_state == DATA_BYTES)
            begin
                if (mpm_mode && (mode_bytes[7:4] == 4'b1010) &&
                    (Instruct == DH_READ || Instruct == QH_READ))
                    bus_cycle_state = ADDRESS_BYTES;
                else
                begin
                    mpm_mode = 0;
                    bus_cycle_state = STAND_BY;
                end
                if (Instruct == QPP)
                begin
                    if (data_cnt > 0)
                    begin
                        if ((data_cnt % 2) == 0)
                        begin
                            write = 0;
                            for(i=0;i<=255;i=i+1)
                            begin
                                for(j=1;j>=0;j=j-1)
                                begin
                                    Quad_slv = quad_data_in[(i*2)+(1-j)];
                                    for(k=3;k>=0;k=k-1)
                                    begin
                                        Byte_slv[4*j+k] = Quad_slv[k];
                                    end
                                end
                                WByte[i] = Byte_slv;
                            end
                            if (data_cnt > 512)
                                Byte_number = 255;
                            else
                                Byte_number = data_cnt/2 -1;
                        end
                    end
                end
                if (HOLDNeg_in)
                begin
                    case (Instruct)
                        WRDI,
                        WREN,
                        DP,
                        BE,
                        SE,
                        P4E,
                        P8E,
                        CLSR:
                        begin
                            if (data_cnt == 0)
                                write = 1'b0;
                        end

                        RES_READ_ES:
                        begin
                            write = 1'b0;
                        end

                        WRR :
                        begin
                            if(!(SRWD && ~WPNeg_in))
                            begin
                                if(((data_cnt % 8) == 0) && (data_cnt > 0))
                                begin
                                    if (data_cnt == 8)
                                    begin
                                        write = 0;
                                        Status_reg_in = Data_in[7:0];
                                    end
                                    else if (data_cnt == 16)
                                    begin
                                        write = 0;
                                        Status_reg_in   = Data_in[7:0];
                                        Sec_conf_reg_in = Data_in[15:8];
                                    end
                                end
                            end
                        end

                        PP :
                        begin
                            if (data_cnt > 0)
                            begin
                                if ((data_cnt % 8) == 0)
                                begin
                                    write = 1'b0;
                                    for (i=0;i<=255;i=i+1)
                                    begin
                                        for (j=7;j>=0;j=j-1)
                                        begin
                                            Byte_slv[j] =
                                            Data_in[(i*8) + (7-j)];
                                        end
                                        WByte[i] = Byte_slv;
                                    end
                                    if (data_cnt > 256*BYTE)
                                        Byte_number = 255;
                                    else
                                        Byte_number = ((data_cnt/8) - 1);
                                end
                            end
                        end

                        OTPP :
                        begin
                            if (data_cnt == 8)
                            begin
                                write = 1'b0;
                                for (j=7;j>=0;j=j-1)
                                begin
                                    Byte_slv[j] = Data_in[7-j];
                                end
                                WOTPByte = Byte_slv;
                            end
                        end
                    endcase
                end
            end
            else
                if (bus_cycle_state == DUMMY_BYTES)
                begin
                    bus_cycle_state = STAND_BY;
                    if (HOLDNeg_in && (Instruct == RES_READ_ES) &&
                    (dummy_cnt == 0))
                        write = 1'b0;
                end
            end
        end
    end

/////////////////////////////////////////////////////////////////////////
//    // Timing control for the Program Operations
//    // start
//    /////////////////////////////////////////////////////////////////////////

 event pdone_event;

    always @(PSTART)
    begin
        if (PSTART && PDONE)
            if (Sec_Prot[SA] == 1'b0)
            begin
                PDONE = 1'b0;
                ->pdone_event;
            end
    end

    always @(pdone_event)
    begin:pdone_process
        PDONE = 1'b0;
        #tdevice_PP PDONE = 1'b1;
    end

//    /////////////////////////////////////////////////////////////////////////
//    // Timing control for the Write Status Register Operation
//    // start
//    /////////////////////////////////////////////////////////////////////////

 event wdone_event;

    always @(WSTART)
    begin
        if (WSTART && WDONE)
        begin
            WDONE = 1'b0;
            ->wdone_event;
        end
    end

    always @(wdone_event)
    begin:wdone_process
        WDONE = 1'b0;
        #tdevice_WR WDONE = 1'b1;
    end

//    /////////////////////////////////////////////////////////////////////////
//    // Timing control for the Erase Operations
//    /////////////////////////////////////////////////////////////////////////
 time duration_erase;

    event edone_event;

    always @(ESTART)
    begin: erase
        if (ESTART && EDONE)
        begin
            if (Instruct == BE)
            begin
                duration_erase = tdevice_BE;
            end
            else if (Instruct == P4E || Instruct == P8E)
            begin
                duration_erase = tdevice_PE;
            end
            else
            begin
                duration_erase = tdevice_SE;
            end

            EDONE = 1'b0;
            ->edone_event;
        end
    end

    always @(edone_event)
    begin : edone_process
        EDONE = 1'b0;
        #duration_erase EDONE = 1'b1;
    end
//    /////////////////////////////////////////////////////////////////////////
//    // Main Behavior Process
//    // combinational process for next state generation
//    /////////////////////////////////////////////////////////////////////////

    reg rising_edge_PDONE = 1'b0;
    reg rising_edge_EDONE = 1'b0;
    reg rising_edge_WDONE = 1'b0;
    reg rising_edge_DP_out = 1'b0;
    reg falling_edge_write = 1'b0;
    integer i;
    integer j;

    always @(falling_edge_write or rising_edge_PDONE or rising_edge_WDONE
    or rising_edge_EDONE or rising_edge_DP_out)
    begin: StateGen1
        if (falling_edge_write)
        begin
            case (current_state)
                IDLE :
                begin
                    if (~write)
                    begin
                        if ((Instruct == WRR) && WEL)
                        begin
                            if (~(Status_reg[7] && (~WPNeg_in)))
                                next_state = WRITE_SR;
                        end

                        else if ((Instruct == PP || Instruct == QPP) &&
                                  WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (Sec_Prot[sect] == 1'b0)
                                next_state = PAGE_PG;
                        end

                        else if (Instruct == OTPP && WEL)
                        begin
                            if(Address == 256 || Address == 257 ||
                            ((Address >= 258 && Address <= 273) &&
                            PR_LOCK1[(Address-258)/8] == 1'b1)
                            || Address == 274
                            || Address == 275 || ((Address >= 276 &&
                            Address <= 531) && PR_LOCK2[(Address-276)/16]
                            ==1'b1) || Address == 532 || Address == 533 ||
                            ((Address >= 534 && Address <= 767)
                            && PR_LOCK3[(Address-534)/16] == 1'b1))
                                next_state =  OTP_PG;
                        end

                        else if (Instruct == SE && WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (Sec_Prot[sect] == 1'b0)
                                next_state = SECTOR_ER;
                        end

                        else if (Instruct == P4E && WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (Sec_Prot[sect] == 1'b0 && (((sect == 0 ||
                                sect == 1) && ~TBPARAM) || ((sect == SecNum ||
                                sect == SecNum-1) && TBPARAM)))
                                next_state = P4_ER;
                        end

                        else if (Instruct == P8E && WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (Sec_Prot[sect] == 1'b0 && (((sect == 0 ||
                                sect == 1) && ~TBPARAM) || ((sect == SecNum ||
                                sect == SecNum-1) && TBPARAM)))
                                next_state = P8_ER;
                        end

                        else if (Instruct == BE && WEL)
                        begin
                            if (Status_reg[2]==1'b0 && Status_reg[3]==1'b0 &&
                                Status_reg[4]==1'b0)
                                next_state = BULK_ER;
                        end
                        else if (Instruct == DP)
                            next_state = DP_DOWN_WAIT;
                        else
                            next_state = IDLE;
                    end
                end

                DP_DOWN :
                begin
                    if (~write)
                    begin
                        if (Instruct == RES_READ_ES)
                            next_state = IDLE;
                    end
                end

            endcase
        end

        if (rising_edge_PDONE)
        begin
            if (current_state==PAGE_PG || current_state==OTP_PG)
            begin
                next_state = IDLE;
            end
        end

        if (rising_edge_WDONE)
        begin
            if (current_state==WRITE_SR)
            begin
                next_state = IDLE;
            end
        end

        if (rising_edge_EDONE)
        begin
            if (current_state==SECTOR_ER || current_state==BULK_ER
            || current_state==P4_ER || current_state==P8_ER)
            begin
                next_state = IDLE;
            end
        end

        if (rising_edge_DP_out)
        begin
            if (current_state==DP_DOWN_WAIT)
                next_state = DP_DOWN;
        end

    end

    ///////////////////////////////////////////////////////////////////////////
    //FSM Output generation and general functionality
    ///////////////////////////////////////////////////////////////////////////
    reg rising_edge_read_out = 1'b0;
    reg rising_edge_RES_out  = 1'b0;
    reg Instruct_event       = 1'b0;
    reg change_addr_event    = 1'b0;
    reg rising_edge_powered  = 1'b0;
    reg current_state_event  = 1'b0;

    integer WData [0:255];
    integer WOTPData;
    integer Addr;
    integer Addr_tmp;

    always @(oe_event)
    begin
        oe = 1'b1;
        #1 oe = 1'b0;
    end

    always @(rising_edge_read_out or Instruct_event or
             change_addr_event or oe or current_state_event or
             falling_edge_write or EDONE or WDONE or PDONE or
             CSNeg_ipd or rising_edge_RES_out or rising_edge_powered or
             rising_edge_DP_out)
    begin: Functionality
    integer i,j;

        if (rising_edge_read_out)
        begin
            if (PoweredUp == 1'b1)
                ->oe_event;
        end

        if (Instruct_event)
        begin
            read_cnt = 0;
            rd_fast = 1'b1;
            rd_slow = 1'b0;
            dual    = 1'b0;
            if (current_state == DP_DOWN_WAIT)
            begin
                if (DP_in == 1'b1)
                begin
                    $display ("Command results can be corrupted");
                end
            end
            if (Instruct == DH_READ || Instruct == QH_READ)
            begin
                mpm_mode = 1;
            end
        end

        if (rising_edge_powered)
        begin
            Sec_conf_reg[0] = 1'b0;

            if (Sec_conf_reg[3] && ~Sec_conf_reg[4] && ~Sec_conf_reg[0])
            begin
                Status_reg[4] = 1'b0;// BP2
                Status_reg[3] = 1'b0;// BP1
                Status_reg[2] = 1'b0;// BP0
                change_BP = 1'b1;
                #1 change_BP = 1'b0;
            end
        end

        if (change_addr_event)
        begin
            read_addr = Address;
        end

        if (oe || current_state_event)
        begin
            case (current_state)
                IDLE :
                begin
                    if (oe && ~RES_in)
                    begin
                        if (Instruct == RDSR)
                        begin
                        //Read Status Register
                            SOut_zd = Status_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                        if (Instruct == RCR)
                        begin
                        //Read Security Conf. Register
                            SOut_zd = Sec_conf_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                        else if (Instruct == READ || Instruct == FAST_READ)
                        begin
                        //Read Memory array
                            if (Instruct == READ)
                            begin
                                rd_fast = 1'b0;
                                rd_slow = 1'b1;
                            end
                            data_out[7:0] = Mem[read_addr];
                            SOut_zd  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                        else if (Instruct == DUAL_READ || Instruct == DH_READ)
                        begin
                        //Read Memory array
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            data_out[7:0] = Mem[read_addr];
                            SOut_zd       = data_out[7-2*read_cnt];
                            SIOut_zd      = data_out[6-2*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                        else if (Instruct == QUAD_READ || Instruct == QH_READ)
                        begin
                        //Read Memory array
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            data_out[7:0] = Mem[read_addr];
                            HOLDNegOut_zd  = data_out[7-4*read_cnt];
                            WPNegOut_zd    = data_out[6-4*read_cnt];
                            SOut_zd        = data_out[5-4*read_cnt];
                            SIOut_zd       = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                        else if (Instruct == OTPR)
                        begin
                            if(read_addr>=OTPLoAddr && read_addr<=OTPHiAddr)
                            begin
                                //Read OTP Memory array
                                rd_fast = 1'b1;
                                rd_slow = 1'b0;
                                data_out = OTPMem[read_addr];
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else if (Instruct == RDID)
                        begin
                        // Read ID
                            ident_out = {Manuf_ID,DeviceID,ExtendedBytes,
                            ExtendedID,DieRev,MaskRev,CFI_array_tmp};
                            SOut_zd = ident_out[647-read_cnt];
                            read_cnt  = read_cnt + 1;
                            if (read_cnt == 648)
                                read_cnt = 0;
                        end
                        else if (Instruct == READ_ID)
                        begin
                        // --Read Manufacturer and Device ID
                            if (read_addr % 2 == 0)
                            begin
                                data_out[7:0] = Manuf_ID;
                                SOut_zd = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    read_addr = read_addr + 1;
                                end
                            end
                            else if (read_addr % 2 == 1)
                            begin
                                data_out[7:0] = ES;
                                SOut_zd = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    read_addr = 0;
                                end
                            end
                        end
                    end
                    else if (oe && RES_in)
                    begin
                        $display ("Command results can be corrupted");
                        SOut_zd = 1'bX;
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end

                WRITE_SR,
                SECTOR_ER,
                BULK_ER,
                P4_ER,
                P8_ER,
                OTP_PG,
                PAGE_PG :
                begin
                    if (oe && Instruct == RDSR)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    if (oe && Instruct == RCR)
                    begin
                    //Read Security Conf. Register
                        SOut_zd = Sec_conf_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                DP_DOWN :
                begin
                    if (oe && Instruct == RES_READ_ES)
                    begin
                    // Read ID
                        data_out[7:0] = ES;
                        SOut_zd = data_out[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end

            endcase
        end

        if (falling_edge_write)
        begin
            case (current_state)
                IDLE :
                begin
                    if (~write)
                    begin
                        if (RES_in == 1'b1 && Instruct != DP)
                        begin
                            $display ("Command results can be corrupted");
                        end
                        if (Instruct == WREN)
                            Status_reg[1] = 1'b1;
                        else if (Instruct == WRDI)
                            Status_reg[1] = 1'b0;
                        else if (Instruct == WRR && WEL &&
                                (~(Status_reg[7] == 1'b1 && WPNeg_in == 1'b0)))
                        begin
                            WSTART = 1'b1;
                            WSTART <= #1 1'b0;
                            Status_reg[0] = 1'b1;
                        end
                        else if ((Instruct == PP || Instruct == QPP) &&
                                  WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (Sec_Prot[sect] == 1'b0)
                            begin
                                PSTART = 1'b1;
                                PSTART <= #1 1'b0;
                                Status_reg[0] = 1'b1; //WIP
                                Addr = Address;
                                Addr_tmp = Address;
                                SA = sect;
                                wr_cnt = Byte_number;
                                for (i=0;i<=wr_cnt;i=i+1)
                                begin
                                    if (Viol != 1'b0)
                                        WData[i] = -1;
                                    else
                                        WData[i] = WByte[i];
                                end
                            end
                            else
                            begin
                                Status_reg[1] = 1'b0;
                            end
                        end
                        else if (Instruct == OTPP && WEL)
                        begin
                            if(Address == 256 || Address == 257 ||
                            ((Address >= 258 && Address <= 273) &&
                            PR_LOCK1[(Address-258)/8] == 1'b1)
                            || Address == 274
                            || Address == 275 || ((Address >= 276 &&
                            Address <= 531) && PR_LOCK2[(Address-276)/16]
                            ==1'b1) || Address == 532 || Address == 533 ||
                            ((Address >= 534 && Address <= 767)
                            && PR_LOCK3[(Address-534)/16] == 1'b1))
                            begin
                                PSTART = 1'b1;
                                PSTART <= #1 1'b0;
                                Status_reg[0] = 1'b1; //WIP
                                Addr = Address;
                                if (Viol != 1'b0 )
                                    WOTPData = -1;
                                else
                                    WOTPData = WOTPByte;
                            end
                            else if (Address < 100 || Address > 767 )
                            begin
                                Status_reg[6] = 1'b1;
                                Status_reg[1] = 1'b0;
                            end
                            else
                            begin
                                Status_reg[1] = 1'b0;
                            end
                        end
                        else if (Instruct == SE && WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (Sec_Prot[sect] == 1'b0)
                            begin
                                ESTART = 1'b1;
                                ESTART <= #1 1'b0;
                                Status_reg[0] = 1'b1;
                                Addr = Address;
                            end
                            else
                            begin
                                Status_reg[5] = 1'b1;
                                Status_reg[1] = 1'b0;
                            end
                        end
                        else if (Instruct == BE && WEL)
                        begin
                            if(Status_reg[2]==1'b0 && Status_reg[3]==1'b0 &&
                               Status_reg[4]==1'b0)
                            begin
                                ESTART = 1'b1;
                                ESTART <= #1 1'b0;
                                Status_reg[0] = 1'b1;
                            end
                            else
                            begin
                                Status_reg[5] = 1'b1;
                                Status_reg[1] = 1'b0;
                            end
                        end
                        else if (Instruct == P4E && WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (((sect == 0 ||
                                sect == 1) && ~TBPARAM) || ((sect == SecNum ||
                                sect == SecNum-1) && TBPARAM))
                            begin
                                if (Sec_Prot[sect] == 1'b0)
                                begin
                                        ESTART = 1'b1;
                                        ESTART <= #1 1'b0;
                                        Status_reg[0] = 1'b1;
                                        Addr = Address;
                                end
                                else
                                begin
                                        Status_reg[5] = 1'b1;
                                        Status_reg[1] = 1'b0;
                                end
                            end
                            else
                            begin
                                Status_reg[5] = 1'b1;
                                Status_reg[1] = 1'b0;
                            end
                        end
                        else if (Instruct == P8E && WEL)
                        begin
                            sect = Address / 24'h10000;
                            if (((sect == 0 ||
                                sect == 1) && ~TBPARAM) || ((sect == SecNum ||
                                sect == SecNum-1) && TBPARAM))
                            begin
                                if (Sec_Prot[sect] == 1'b0)
                                begin
                                        ESTART = 1'b1;
                                        ESTART <= #1 1'b0;
                                        Status_reg[0] = 1'b1;
                                        Addr = Address;
                                end
                                else
                                begin
                                        Status_reg[5] = 1'b1;
                                        Status_reg[1] = 1'b0;
                                end
                            end
                            else
                            begin
                                Status_reg[5] = 1'b1;
                                Status_reg[1] = 1'b0;
                            end
                        end
                        else if (Instruct == CLSR)
                        begin
                            Status_reg[5] = 1'b0;
                            Status_reg[6] = 1'b0;
                        end
                        else if (Instruct == DP)
                        begin
                            RES_in <= 1'b0;
                            DP_in = 1'b1;
                        end
                        else if (Instruct == RES_READ_ES)
                        begin
                            RES_in <= 1'b1;
                        end
                    end

                end

                DP_DOWN :
                begin
                    if (~write)
                    begin
                        if (Instruct == RES_READ_ES)
                            RES_in = #1 1'b1;
                    end
                end

            endcase
        end

        if(current_state_event || EDONE)
        begin
            case (current_state)

                SECTOR_ER :
                begin
                    ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                    for (i=AddrLo;i<=AddrHi;i=i+1)
                    begin
                        Mem[i] = -1;
                    end
                    if (EDONE)
                    begin
                        Status_reg[0] = 1'b0;
                        Status_reg[1] = 1'b0;
                        for (i=AddrLo;i<=AddrHi;i=i+1)
                        begin
                            Mem[i] = MaxData;
                        end
                    end
                end
                BULK_ER :
                begin
                    for (i=0;i<=AddrRANGE;i=i+1)
                    begin
                        Mem[i] = -1;
                    end

                    if (EDONE)
                    begin
                        Status_reg[0] = 1'b0;
                        Status_reg[1] = 1'b0;
                        for (i=0;i<=AddrRANGE;i=i+1)
                        begin
                            Mem[i] = MaxData;
                        end
                    end
                end
                P4_ER :
                begin
                    ADDRHILO_PB4(AddrLo, AddrHi, Addr);
                    for (i=AddrLo;i<=AddrHi;i=i+1)
                    begin
                        Mem[i] = -1;
                    end
                    if (EDONE)
                    begin
                        Status_reg[0] = 1'b0;
                        Status_reg[1] = 1'b0;
                        for (i=AddrLo;i<=AddrHi;i=i+1)
                        begin
                            Mem[i] =  MaxData;
                        end
                    end
                end
                P8_ER :
                begin
                    ADDRHILO_PB8(AddrLo, AddrHi, Addr);
                    for (i=AddrLo;i<=AddrHi;i=i+1)
                    begin
                        Mem[i] = -1;
                    end
                    if (EDONE)
                    begin
                        Status_reg[0] = 1'b0;
                        Status_reg[1] = 1'b0;
                        for (i=AddrLo;i<=AddrHi;i=i+1)
                        begin
                            Mem[i] =  MaxData;
                        end
                    end
                end
            endcase
        end

        if(current_state_event || WDONE)
        begin
            if (current_state == WRITE_SR)
            begin
                if (WDONE)
                begin
                    Status_reg[0] = 1'b0;//WIP
                    Status_reg[1] = 1'b0;//WEL
                    Status_reg[7] = Status_reg_in[0];//MSB first, SRWD
                    if(~Sec_conf_reg[4])
                    begin
                        if(~(Status_reg[7] && ~WPNeg_in))
                        begin
                            if(~Sec_conf_reg[0])
                            begin
                                Status_reg[4] = Status_reg_in[3];// BP2
                                Status_reg[3] = Status_reg_in[4];// BP1
                                Status_reg[2] = Status_reg_in[5];// BP0

                                Sec_conf_reg[0] = Sec_conf_reg_in[7];
                                Sec_conf_reg[2] = Sec_conf_reg_in[5];
                                Sec_conf_reg[4] = Sec_conf_reg_in[3];
                                Sec_conf_reg[5] = Sec_conf_reg_in[2];

                                change_BP = 1'b1;
                                #1 change_BP = 1'b0;
                            end
                            else
                                Sec_conf_reg[4] = Sec_conf_reg_in[3];
                        end
                    end
                    Sec_conf_reg[1] = Sec_conf_reg_in[6];
                    Sec_conf_reg[3] = Sec_conf_reg_in[4];
                end
            end
        end

        if(current_state_event || PDONE)
        begin
            if (current_state == PAGE_PG)
            begin
                ADDRHILO_PG(AddrLo, AddrHi, Addr);
                cnt = 0;

                for (i=0;i<=wr_cnt;i=i+1)
                begin
                    new_int = WData[i];
                    old_int = Mem[Addr + i - cnt];
                    if (new_int > -1)
                    begin
                        new_bit = new_int;
                        if (old_int > -1)
                        begin
                            old_bit = old_int;
                            for(j=0;j<=7;j=j+1)
                                if (~old_bit[j])
                                    new_bit[j]=1'b0;
                            new_int=new_bit;
                        end

                        WData[i]= new_int;
                    end
                    else
                    begin
                        WData[i] = -1;
                    end

                    Mem[Addr + i -cnt] = - 1;

                    if ((Addr + i) == AddrHi)
                    begin
                        Addr = AddrLo;
                        cnt = i + 1;
                    end
                end

                cnt = 0;

                if (PDONE)
                begin
                    Status_reg[0] = 1'b0;//wip
                    Status_reg[1] = 1'b0;// wel
                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        Mem[Addr_tmp + i - cnt] = WData[i];
                        if ((Addr_tmp + i) == AddrHi)
                        begin
                            Addr_tmp = AddrLo;
                            cnt = i + 1;
                        end
                    end
                end
            end
        end

        if(current_state_event || PDONE)
        begin
            if (current_state == OTP_PG)
            begin
                new_int = WOTPData;
                old_int = OTPMem[Addr];
                if (new_int > -1)
                begin
                    new_bit = new_int;
                    if (old_int > -1)
                    begin
                        old_bit = old_int;
                        for(j=0;j<=7;j=j+1)
                        begin
                            if (~old_bit[j])
                                new_bit[j] = 1'b0;
                        end
                        new_int = new_bit;
                    end
                    WOTPData = new_int;
                end
                else
                begin
                    WOTPData = -1;
                end
                OTPMem[Addr] =  -1;
                if (PDONE)
                begin
                    Status_reg[0] = 1'b0;
                    Status_reg[1] = 1'b0;
                    OTPMem[Addr] = WOTPData;
                    PR_LOCK1 = {OTPMem[257],OTPMem[256]};

                    PR_LOCK1[15:8] = OTPMem[257];
                    PR_LOCK1[7:0]  = OTPMem[256];
                    PR_LOCK2[15:8] = OTPMem[275];
                    PR_LOCK2[7:0]  = OTPMem[274];
                    PR_LOCK3[15:8] = OTPMem[533];
                    PR_LOCK3[7:0]  = OTPMem[532];
                end
            end
        end

        //Output Disable Control
        if (CSNeg_ipd )
        begin
            SIOut_zd      = 1'bZ;
            HOLDNegOut_zd = 1'bZ;
            WPNegOut_zd   = 1'bZ;
            SOut_zd = 1'bZ;
        end

        if (rising_edge_RES_out)
        begin
            if(RES_out)
            begin
                RES_in = 1'b0;
            end
        end

        if (rising_edge_DP_out)
        begin
            if (current_state == DP_DOWN_WAIT)
            begin
                DP_in = 1'b0;
            end
        end

    end

    always @(change_BP)
    begin
        if (change_BP)
        begin
            case (Status_reg[4:2])
                3'b000 :
                begin
                    Sec_Prot = 256'h0;
                end

                3'b001 :
                begin
                    if (~Sec_conf_reg[5])
                    begin
                        Sec_Prot[SecNum : (SecNum+1)*63/64] = 4'hF;
                        Sec_Prot[(SecNum+1)*63/64 - 1 : 0] = 254'h0;
                    end
                    else
                    begin
                        Sec_Prot[(SecNum+1)/64 - 1 : 0] = 4'hF;
                        Sec_Prot[SecNum : (SecNum+1)/64] = 254'h0;
                    end
                end

                3'b010 :
                begin
                    if (~Sec_conf_reg[5])
                    begin
                        Sec_Prot[SecNum : (SecNum+1)*31/32] = 8'hFF;
                        Sec_Prot[(SecNum+1)*31/32 - 1 : 0] = 248'h0;
                    end
                    else
                    begin
                        Sec_Prot[(SecNum+1)/32 - 1 : 0] = 8'hFF;
                        Sec_Prot[SecNum : (SecNum+1)/32] = 248'h0;
                    end
                end

                3'b011 :
                begin
                    if (~Sec_conf_reg[5])
                    begin
                        Sec_Prot[SecNum : (SecNum+1)*15/16] = 16'hFFFF;
                        Sec_Prot[(SecNum+1)*15/16 - 1 : 0]  = 240'h0;
                    end
                    else
                    begin
                        Sec_Prot[(SecNum+1)/16 - 1 : 0]  = 16'hFFFF;
                        Sec_Prot[SecNum : (SecNum+1)/16] = 240'h0;
                    end
                end

                3'b100 :
                begin
                    if (~Sec_conf_reg[5])
                    begin
                        Sec_Prot[SecNum : (SecNum+1)*7/8] = 32'hFFFFFFFF;
                        Sec_Prot[(SecNum+1)*7/8 - 1 : 0]  = 224'h0;
                    end
                    else
                    begin
                        Sec_Prot[(SecNum+1)/8 - 1 : 0]  = 32'hFFFFFFFF;
                        Sec_Prot[SecNum : (SecNum+1)/8] = 224'h0;
                    end
                end

                3'b101 :
                begin
                    if (~Sec_conf_reg[5])
                    begin
                        Sec_Prot[SecNum : (SecNum+1)*3/4]
                                                    = 64'hFFFFFFFFFFFFFFFF;
                        Sec_Prot[(SecNum+1)*3/4 - 1 : 0] = 192'h0;
                    end
                    else
                    begin
                        Sec_Prot[(SecNum+1)/4 - 1 : 0]
                                                    = 64'hFFFFFFFFFFFFFFFF;
                        Sec_Prot[SecNum : (SecNum+1)/4] = 192'h0;
                    end
                end

                3'b110 :
                begin
                    if (~Sec_conf_reg[5])
                    begin
                        Sec_Prot[SecNum : (SecNum+1)/2]
                                 = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                        Sec_Prot[(SecNum+1)/2 - 1 : 0] = 64'h0;
                    end
                    else
                    begin
                        Sec_Prot[(SecNum+1)/2 - 1 : 0]
                                 = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                        Sec_Prot[SecNum : (SecNum+1)/2] = 64'h0;
                    end
                end

                3'b111 :
                begin
                    Sec_Prot =
          256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                end

            endcase
        end
    end

    assign fast_rd = rd_fast;
    assign rd = rd_slow;

    always @(SOut_zd or HOLDNeg_in or SIOut_zd)
    begin
        if (~HOLDNeg_in && ~QUAD)
        begin
            hold_mode = 1'b1;
            SIOut_z   = 1'bZ;
            SOut_z    = 1'bZ;
        end
        else
        begin
            if (hold_mode)
            begin
                SIOut_z <= #(tpd_HOLDNeg_SO) SIOut_zd;
                SOut_z  <= #(tpd_HOLDNeg_SO) SOut_zd;
                hold_mode = 1'b0;
            end
            else
            begin
                SIOut_z = SIOut_zd;
                SOut_z  = SOut_zd;
                hold_mode = 1'b0;
            end
        end
    end

// Procedure ADDRHILO_SEC
 task ADDRHILO_SEC;
 inout  AddrLOW;
 inout  AddrHIGH;
 input   Addr;
 integer AddrLOW;
 integer AddrHIGH;
 integer Addr;
 integer sector;
 begin
    sector = Addr / 20'h10000;
    AddrLOW = sector * 20'h10000;
    AddrHIGH = sector * 20'h10000 + 16'hFFFF;
 end
 endtask

// Procedure ADDRHILO_PG
 task ADDRHILO_PG;
 inout  AddrLOW;
 inout  AddrHIGH;
 input   Addr;
 integer AddrLOW;
 integer AddrHIGH;
 integer Addr;
 integer page;
 begin

    page = Addr / 16'h100;
    AddrLOW = page * 16'h100;
    AddrHIGH = page * 16'h100 + 8'hFF;

 end
 endtask

// Procedure ADDRHILO_PB4
 task ADDRHILO_PB4;
 inout   AddrLOW;
 inout   AddrHIGH;
 input   Addr;
 integer AddrLOW;
 integer AddrHIGH;
 integer Addr;
 integer sector;
 begin
    sector = Addr / 20'h10000;
    if (sector == 0 || sector == 1 ||
        sector == SecNum || sector == SecNum-1)
    begin
        AddrLOW  = (Address/(SecSize_4+1))*(SecSize_4+1);
        AddrHIGH = (Address/(SecSize_4+1))*(SecSize_4+1) + SecSize_4;
    end
 end
 endtask

// Procedure ADDRHILO_PB8
 task ADDRHILO_PB8;
 inout   AddrLOW;
 inout   AddrHIGH;
 input   Addr;
 integer AddrLOW;
 integer AddrHIGH;
 integer Addr;
 integer sector;
 begin
    sector = Addr / 20'h10000;
    if (sector == 0 || sector == SecNum-1)
    begin
        AddrLOW  = (Address/(SecSize_8+1))*(SecSize_8+1);
        AddrHIGH = (Address/(SecSize_8+1))*(SecSize_8+1) + SecSize_8;
    end
    if (sector == 1)
    begin
        AddrLOW  = (Address/(SecSize_8+1))*(SecSize_8+1);
        AddrHIGH = (Address/(SecSize_8+1))*(SecSize_8+1) + SecSize_8;
        if (AddrHIGH > 20'h1FFFF)
            AddrHIGH = 20'h1FFFF;
    end
    if (sector == SecNum)
    begin
        AddrLOW  = (Address/(SecSize_8+1))*(SecSize_8+1);
        AddrHIGH = (Address/(SecSize_8+1))*(SecSize_8+1) + SecSize_8;
        if (AddrHIGH > 24'hFFFFFF)
            AddrHIGH = 24'hFFFFFF;
    end
 end
 endtask

    always @(negedge CSNeg_ipd)
    begin
        falling_edge_CSNeg_ipd = 1'b1;
        #1 falling_edge_CSNeg_ipd = 1'b0;
    end

    always @(posedge SCK_ipd)
    begin
        rising_edge_SCK_ipd = 1'b1;
        #1 rising_edge_SCK_ipd = 1'b0;
    end

    always @(negedge SCK_ipd)
    begin
        falling_edge_SCK_ipd = 1'b1;
        #1 falling_edge_SCK_ipd = 1'b0;
    end

    always @(posedge CSNeg_ipd)
    begin
        rising_edge_CSNeg_ipd = 1'b1;
        #1 rising_edge_CSNeg_ipd = 1'b0;
    end

    always @(negedge write)
    begin
        falling_edge_write = 1'b1;
        #1 falling_edge_write = 1'b0;
    end

    always @(posedge PDONE)
    begin
        rising_edge_PDONE = 1'b1;
        #1 rising_edge_PDONE = 1'b0;
    end

    always @(posedge WDONE)
    begin
        rising_edge_WDONE = 1'b1;
        #1 rising_edge_WDONE = 1'b0;
    end

    always @(posedge EDONE)
    begin
        rising_edge_EDONE = 1'b1;
        #1 rising_edge_EDONE = 1'b0;
    end

    always @(posedge DP_out)
    begin
        rising_edge_DP_out = 1'b1;
        #1 rising_edge_DP_out = 1'b0;
    end

    always @(posedge RES_out)
    begin
        rising_edge_RES_out = 1'b1;
        #1 rising_edge_RES_out = 1'b0;
    end

    always @(posedge read_out)
    begin
        rising_edge_read_out = 1'b1;
        #1 rising_edge_read_out = 1'b0;
    end

    always @(posedge PoweredUp)
    begin
        rising_edge_powered = 1'b1;
        #1 rising_edge_powered = 1'b0;
    end

    always @(Instruct)
    begin
        Instruct_event = 1'b1;
        #1 Instruct_event = 1'b0;
    end

    always @(change_addr)
    begin
        change_addr_event = 1'b1;
        #1 change_addr_event = 1'b0;
    end

    always @(current_state)
    begin
        current_state_event = 1'b1;
        #1 current_state_event = 1'b0;
    end

endmodule
