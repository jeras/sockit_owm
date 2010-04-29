// *============================================================================================== 
// *
// *   MX25L12845E.v - 128M-BIT CMOS Serial Flash Memory
// *
// *           COPYRIGHT 2009 Macronix International Co., Ltd.
// *----------------------------------------------------------------------------------------------
// * Environment  : Cadence NC-Verilog
// * Reference Doc: MX25L12845E REV.1.2,OCT.21, 2009
// * Creation Date: @(#)$Date: 2009/12/11 09:37:24 $
// * Version      : @(#)$Revision: 1.12 $
// * Description  : There is only one module in this file
// *                module MX25L12845E->behavior model for the 128M-Bit flash
// *----------------------------------------------------------------------------------------------
// * Note 1:model can load initial flash data from file when model define  parameter Init_File = "xxx"; 
// *        xxx: initial flash data file name;default value xxx = "none", initial flash data is "FF".
// * Note 2:power setup time is tVSL = 300_000 ns, so after power up, chip can be enable.
// * Note 3:If you have any question and suggestion, please send your mail to follow email address :
// *                                    flash_model@mxic.com.tw
// *============================================================================================== 
// * timescale define
// *============================================================================================== 
`timescale 1ns / 100ps

// *============================================================================================== 
// * product parameter define
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* Define controller STATE						    */
    /*----------------------------------------------------------------------*/
	`define		STANDBY_STATE		0
        `define		CMD_STATE		1
        `define		HPM_STATE		2
        `define		BAD_CMD_STATE		3


module MX25L12845E( SCLK, 
		    CS, 
		    SI, 
		    SO, 
		    WP, 
		    SIO3,
		    PO6,
		    PO5,
		    PO4,
		    PO3,
		    PO2,
		    PO1,
		    PO0 );

// *============================================================================================== 
// * Declaration of ports (input, output, inout)
// *============================================================================================== 
    input  SCLK;    // Signal of Clock Input
    input  CS;	    // Chip select (Low active)
    inout  SI;	    // Serial Input/Output SIO0
    inout  SO;	    // Serial Input/Output SIO1
    inout  WP;	    // Hardware write protection or Serial Input/Output SIO2
    inout  SIO3;    // Serial Input/Output SIO3
    inout  PO6;     // Parallel data output
    inout  PO5;     // Parallel data output
    inout  PO4;     // Parallel data output
    inout  PO3;     // Parallel data output
    inout  PO2;     // Parallel data output
    inout  PO1;     // Parallel data output
    inout  PO0;     // Parallel data output

// *============================================================================================== 
// * Declaration of parameter (parameter)
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* Density STATE parameter						    */  		
    /*----------------------------------------------------------------------*/
    parameter	A_MSB		= 23,
                A_MSB_OTP       = 8,			
                A_MSB_DMC       = 6,			
		TOP_Add		= 24'hffffff,
		Secur_TOP_Add   = 9'h1ff,
		DMC_TOP_Add     = 7'h7f,
		Sector_MSB	= 11,
		Block_MSB	= 7,
		Block_NUM	= 256;

    /*----------------------------------------------------------------------*/
    /* Define ID Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	ID_MXIC		= 8'hc2,
		ID_Device	= 8'h17,
		Memory_Type	= 8'h20,
		Memory_Density	= 8'h18;

    /*----------------------------------------------------------------------*/
    /* Define Initial Memory File Name					    */
    /*----------------------------------------------------------------------*/
    parameter   Init_File	= "none"; // initial flash data

    /*----------------------------------------------------------------------*/
    /* AC Charicters Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	tSHQZ_S	= 8,    // CS Serial High to SO Float Time [ns]
                tSHQZ_P	= 20,    // CS Parallel High to SO Float Time [ns]
		tCLQV_1XIO= 9,   // Clock Low to 1 IO Output Valid
		tCLQV_2XIO= 9.5,   // Clock Low to 2 IO Output Valid
		tCLQV_4XIO= 9.5,   // Clock Low to 4 IO Output Valid
		tCLQV2  = 9.5,   // Clock Low to IO Output Valid DTR Mode
		tCLQV_P	= 70,    // Clock Low to Output Valid Parallel Mode
		tCLQX	= 2,   	// Output Hold Time
             	tBP  	= 9_000,	// Byte program time
             	tSE	= 60_000_000,	// Sector erase time  
		tBE	= 700_000_000,	// Block erase time
		tBE32	= 500_000_000,	// Block 32KB erase time
		tCE	= 80_000,	// unit is ms instead of ns  
		tPP	= 1_400_000,	// Program time
		tW 	= 40_000_000,	// Write Status time 
		tVSL	= 300_000,	// Time delay to chip select allowed
		tWPS 	= 1_000_000,	// Write Protection Select time
		tWSR 	= 1_000_000,	// Write security  registertime
        	tWP_SRAM= 1_000, // Write protetion sram time
          	tPGM_CHK= 2_000,	// Program protect area time
		tERS_CHK= 100_000;	// Erase protect area time

	parameter   tSCLK_S = 9.6,	// Clock Serial Cycle Time [ns]
		    fSCLK_S = 104,	// Clock Serial Frequence except READ instruction[ns] 15pF
                    tSCLK_P = 166.6,	// Clock Parallel Cycle Time [ns]
		    fSCLK_P = 6,	// Clock Parallel Frequence except READ instruction[ns] 15pF
		    tRSCLK  = 20,	// Clock Cycle Time for READ instruction[ns] 15pF
		    fRSCLK  = 50,	// Clock Frequence for READ instruction[ns] 15pF
		    tCH_S   = 4.5,  	// Clock Serial High Time (min) [ns]
		    tCL_S   = 4.5,  	// Clock Serial Low  Time (min) [ns]
                    tCH_R   = 9,        // Clock High Time (min) [ns]
                    tCL_R   = 9,        // Clock Low  Time (min) [ns]
		    tCH_P   = 30,  	// Clock Parallel High Time (min) [ns]
		    tCL_P   = 30,  	// Clock Parallel Low  Time (min) [ns]
		    tSLCH   = 8,	// CS# Active Setup Time (relative to SCLK) (min) [ns]
		    tCHSL   = 5,	// CS# Not Active Hold Time (relative to SCLK)(min) [ns]
		    tSHSL_R = 15,	// CS High Time for read instruction (min) [ns]
		    tSHSL_W = 50,	// CS High Time for write instruction (min) [ns]
		    tDVCH_S   = 2,	// SI Serial Setup Time (min) [ns]
		    tDVCH_P   = 10,	// SI Parallel Setup Time (min) [ns]
		    tCHDX_S   = 5,	// SI Serial Hold Time (min) [ns]
		    tCHDX_P   = 10,	// SI Parallel Hold Time (min) [ns]
		    tCHSH_S   = 5,	// CS# Serial Active Hold Time (relative to SCLK) (min) [ns]
		    tCHSH_P   = 30,	// CS# Parallel Active Hold Time (relative to SCLK) (min) [ns]
		    tSHCH   = 8,	// CS# Not Active Setup Time (relative to SCLK) (min) [ns]
		    tWHSL   = 20,	// Write Protection Setup Time		  
		    tSHWL   = 100,	// Write Protection Hold  Time  
		    tDP     = 10_000,	        // CS# High to Deep Power-down Mode
		    tRES1   = 100_000,	// CS# High to Standby Mode without Electronic Signature Read
		    tRES2   = 100_000,	// CS# High to Standby Mode with Electronic Signature Read
 	            tTSCLK  = 14.2,	// Clock Cycle Time for 2XI/O READ instruction[ns] 15pF
		    fTSCLK  = 70,	// Clock Frequence for 2XI/O READ instruction[ns] 15pF
 	            tQSCLK  = 14.2,	// Clock Cycle Time for 4XI/O READ instruction[ns] 15pF
		    fQSCLK  = 70,	// Clock Frequence for 4XI/O READ instruction[ns] 15pF
	            tDSCLK  = 20,   	// Clock Cycle Time for DDR READ instruction[ns] 15pF
		    fDSCLK  = 50,   	// Clock Frequence for DDR READ instruction[ns] 15pF
 	            tPSCLK  = 50,	// Clock Cycle Time for 4XI/O PP Operation
		    fPSCLK  = 20;	// Clock Frequence for 4XI/O PP Operation

    /*----------------------------------------------------------------------*/
    /* Define Command Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	WREN	    = 8'h06, // WriteEnable   
		WRDI	    = 8'h04, // WriteDisable  
		RDID	    = 8'h9F, // ReadID	  
		RDSR	    = 8'h05, // ReadStatus	  
    	        WRSR	    = 8'h01, // WriteStatus   
    	        READ1X	    = 8'h03, // ReadData	  
                READ2X      = 8'hbb, // 2X Read 
                READ4X	    = 8'heb, // 4XI/O Read;
    	        FASTREAD1X  = 8'h0b, // FastReadData 
                DDRREAD1X   = 8'h0d, // fast DDR read 1XI/O Read;
    	        DDRREAD2X   = 8'hbd, // Dual DDR read 2XI/O Read;
    	        DDRREAD4X   = 8'hed, // Quad DDR read 4XI/O Read;
    	        SE	    = 8'h20, // SectorErase   
    	        BE2	    = 8'h52, // 32k block erase 
                BE	    = 8'hd8, // BlockErase	  
    	        CE1	    = 8'h60, // ChipErase	  
    	        CE2	    = 8'hc7, // ChipErase	  
    	        PP	    = 8'h02, // PageProgram   
    	        DP	    = 8'hb9, // DeepPowerDown
    	        RDP	    = 8'hab, // ReleaseFromDeepPowerDwon 
    	        RES	    = 8'hab, // ReadElectricID 
    	        REMS	    = 8'h90, // ReadElectricManufacturerDeviceID
    	        REMS2	    = 8'hef, // ReadElectricManufacturerDeviceID 
    	        REMS4	    = 8'hdf, // ReadElectricManufacturerDeviceID
    	        REMS4D      = 8'hcf, // ReadElectricManufacturerDeviceID
    	        CP	    = 8'had, // Continuously  program mode;
    	        ENSO	    = 8'hb1, // Enter secured OTP;
    	        EXSO	    = 8'hc1, // Exit  secured OTP;
    	        RDSCUR	    = 8'h2b, // Read  security  register;
    	        WRSCUR	    = 8'h2f, // Write security  register;
    	        ESRY	    = 8'h70, // Enable  SO to output RY/BY;
    	        DSRY	    = 8'h80, // Disable SO to output RY/BY;
    	        HPM	    = 8'ha3, // High Performance Enable Mode
    	        FIOPGM0	    = 8'h38, // 4I Page Pgm load address and data all 4io
    	        DMC_READ    = 8'h5a, // enter DMC read mode
                CLSR        = 8'h30, // clear the security register E_FAIL bit and P_FAIL bit
    	        ENPLM       = 8'h55, // enter parallel mode
    	        EXPLM       = 8'h45, // exit parallel mode
    	        WPSEL       = 8'h68, // write protection selection 
    	        SBLK        = 8'h36, // single block lock  
    	        SBULK       = 8'h39, // single block unlock  
    	        RDBLOCK     = 8'h3c, // block protect read
    	        GBLK        = 8'h7e, // gang block lock
    	        GBULK       = 8'h98; // gang block unlock

    /*----------------------------------------------------------------------*/
    /* Declaration of internal-signal                                       */
    /*----------------------------------------------------------------------*/
    reg  [7:0]		 ARRAY[0:TOP_Add];  
    reg  [7:0]		 Status_Reg;	    
    reg  [7:0]		 CMD_BUS;
    reg  [23:0]          SI_Reg;	    
    reg  [7:0]           Dummy_A[0:255];    
    reg  [A_MSB:0]	 Address;	    
    reg  [Sector_MSB:0]	 Sector;	  
    reg  [Block_MSB:0] 	 Block;	   
    reg  [2:0]		 STATE;
    reg  [7:0]		 Secur_ARRAY[0:Secur_TOP_Add]; 
    reg  [7:0]		 Secur_Reg;	    
    reg  [15:0]		 CP_Data;
    reg  [15:0] SEC_Pro_Reg_TOP;
    reg  [15:0] SEC_Pro_Reg_BOT;
    reg  [Block_NUM - 2:1] SEC_Pro_Reg;
    reg  [6:0]		 PO_Reg;
    reg  [6:0]		 Latch_PO; 
    reg  [7:0]		 DMC_ARRAY[0:DMC_TOP_Add]; 
    reg     Latch_SO;    
    reg     P_Mode;	    
    reg     P_Mode_Chk;	    
    reg     P_Mode_IN;	    
    reg     P_Mode_OUT;	    

    reg     SIO0_Reg;
    reg     SIO1_Reg;
    reg     SIO2_Reg;
    reg     SIO3_Reg;
    reg     Chip_EN;
    reg	    SI_IN_EN;
    reg	    SI_OUT_EN;   
    reg	    SO_IN_EN;
    reg	    SO_OUT_EN;   
    reg	    WP_IN_EN;    
    reg	    WP_OUT_EN;   
    reg	    SIO3_IN_EN;  
    reg	    SIO3_OUT_EN;
    reg     DMC_Mode; 
    reg     DP_Mode;	    
    reg     Read_1XIO_Mode;
    reg     Read_1XIO_Chk;
    reg     FastRD_1XIO_Mode;	
    reg     PP_1XIO_Mode;
    reg     SE_4K_Mode;
    reg     BE_Mode;
    reg     CE_Mode;
    reg     WRSR_Mode;
    reg     RES_Mode;
    reg     REMS_Mode;
    reg     RDSR_Mode;
    reg     RDID_Mode;
    reg     RDSCUR_Mode;
    reg     Secur_Mode;	    
    reg     CP_ESRY_Mode;	
    reg     EN_CP_Mode;
    reg     CP_Mode;
    reg     Read_2XIO_Mode;
    reg     Read_2XIO_Chk;
    reg     Byte_PGM_Mode;
    reg     Read_4XIO_Mode;
    reg     Read_4XIO_Chk;
    reg     ENDDR4XIO_Read_Mode;
    reg     DDRRead_1XIO_Mode;
    reg     DDRRead_2XIO_Mode;
    reg     DDRRead_4XIO_Mode;
    reg     DDR_Read_Mode_IN;
    reg     Set_4XIO_DDR_Enhance_Mode;
    reg     Enhance_Mode; 
    reg	    SEC_PROVFY_Mode;

    reg     PP_4XIO_Mode;
    reg     PP_4XIO_Load;
    reg     PP_1XIO_Load;
    reg     PP_4XIO_Chk;
    reg     EN4XIO_Read_Mode;
    reg     Set_4XIO_Enhance_Mode;   
    reg     CP_ESRY_ModeEN;
    reg     Read_SHSL;
    reg     tDP_Chk;
    reg     tRES1_Chk;
    reg     tRES2_Chk;

    wire    Write_SHSL;
    wire    HPM_RD;
    wire    SIO3;
    wire    WP_B_INT;
    wire    SCLK;
    wire    WIP;
    wire    WEL;
    wire    SRWD;
    wire    Dis_CE;
    wire    Dis_WRSR;
    wire    CP_Busy;
    wire    DDR_Read_Mode;
    wire    WPSEL_Mode; 
    wire    Norm_Array_Mode;
    event   CP_Event;
    event   WRSCUR_Event;
    event   WRSR_Event; 
    event   BE_Event;
    event   SE_4K_Event;
    event   CE_Event;
    event   PP_Event;
    event   SEC_Pro_Event;
    event   Chip_Unprot_Event;
    event   BE32K_Event;
    event   WPSEL_Event;
    event   SBLK_Event;
    event   SBULK_Event;
    event   GBLK_Event;
    event   GBULK_Event;

    integer i;
    integer j;
    integer Bit; 
    integer Bit_Tmp; 
    integer Start_Add;
    integer End_Add;
    integer Page_Size;
    time    tRES;

    /*----------------------------------------------------------------------*/
    /* initial variable value						    */
    /*----------------------------------------------------------------------*/
    initial begin
	Secur_Reg   = 8'b0000_0000;
	SO_OUT_EN   = 1'b0; 
	SI_IN_EN    = 1'b0; 
	CMD_BUS	    = 8'b0000_0000;
	Address	    = 0;
	i	    = 0;
	j	    = 0;
	Bit	    = 0;
	Bit_Tmp	    = 0;
	Start_Add   = 0;
	End_Add	    = 0;
	Page_Size   = 256;
	DP_Mode	    = 1'b0;
	P_Mode	    = 1'b0;
	P_Mode_Chk  = 1'b0;
	P_Mode_IN   = 1'b0;
	P_Mode_OUT  = 1'b0;

	Chip_EN	    = 1'b0;
        tDP_Chk       = 1'b0;
        tRES1_Chk       = 1'b0;
        tRES2_Chk       = 1'b0;
	Read_1XIO_Mode  = 1'b0;
	Read_1XIO_Chk   = 1'b0;
	PP_1XIO_Mode    = 1'b0;
	SE_4K_Mode      = 1'b0;
	BE_Mode	    = 1'b0;
	CE_Mode	    = 1'b0;
	WRSR_Mode   = 1'b0;
	RES_Mode    = 1'b0;
	REMS_Mode   = 1'b0;
        Read_SHSL   = 1'b0;
	FastRD_1XIO_Mode  = 1'b0;
	SI_OUT_EN    = 1'b0; 
	SO_IN_EN    = 1'b0; 
	CP_Data	    = 8'b0000_0000;
	Secur_Mode  = 1'b0;
	CP_ESRY_Mode= 1'b0;
	EN_CP_Mode  = 1'b0;
	CP_Mode	    = 1'b0;
	Read_2XIO_Mode  = 1'b0;
	Read_2XIO_Chk   = 1'b0;
	Byte_PGM_Mode   = 1'b0;
	Secur_Reg[3:2]  = 2'b00;
	WP_OUT_EN       = 1'b0; 
	SIO3_OUT_EN     = 1'b0; 
	WP_IN_EN        = 1'b0; 
	SIO3_IN_EN      = 1'b0; 
	Status_Reg      = 8'b0000_0000 ;
	Read_4XIO_Mode  = 1'b0;
	Read_4XIO_Chk   = 1'b0;
	PP_4XIO_Mode    = 1'b0;
        PP_4XIO_Load    = 1'b0;
        PP_1XIO_Load    = 1'b0;
	EN4XIO_Read_Mode  = 1'b0;
	Enhance_Mode      = 1'b0;
	SEC_PROVFY_Mode   = 1'b0;
        PP_4XIO_Chk     = 1'b0;
	SEC_Pro_Reg[Block_NUM - 2:1] = ~1'b0; 
	SEC_Pro_Reg_TOP[15:0] = 16'hffff;
	SEC_Pro_Reg_BOT[15:0] = 16'hffff;
        ENDDR4XIO_Read_Mode	= 1'b0;
        DDRRead_1XIO_Mode	= 1'b0;
        DDRRead_2XIO_Mode	= 1'b0;
        DDRRead_4XIO_Mode	= 1'b0;
        DDR_Read_Mode_IN	= 1'b0;
        DMC_Mode = 1'b0;
        Set_4XIO_Enhance_Mode = 1'b0;
        Set_4XIO_DDR_Enhance_Mode = 1'b0;
        CP_ESRY_ModeEN = 1'b0;
    end
    
    /*----------------------------------------------------------------------*/
    /* initial flash data    						    */
    /*----------------------------------------------------------------------*/
    initial 
    begin : memory_initialize
	for ( i = 0; i <=  TOP_Add; i = i + 1 )
	    ARRAY[i] = 8'hff; 
	if ( Init_File != "none" )
	    $readmemh(Init_File,ARRAY) ;
	for( i = 0; i <=  Secur_TOP_Add; i = i + 1 ) begin
	    Secur_ARRAY[i]=8'hff;
	end
	for( i = 0; i <=  DMC_TOP_Add; i = i + 1 ) begin
	    DMC_ARRAY[i] = 8'h00;
	end
        // define DMC code
        DMC_ARRAY[8'h0] =  8'h53;
        DMC_ARRAY[8'h1] =  8'h46;
        DMC_ARRAY[8'h2] =  8'h44;
        DMC_ARRAY[8'h3] =  8'h50;
        DMC_ARRAY[8'h4] =  8'h00;
        DMC_ARRAY[8'h5] =  8'h01;
        DMC_ARRAY[8'h6] =  8'h02;
        DMC_ARRAY[8'h7] =  8'h00;
        DMC_ARRAY[8'h8] =  8'h00;
        DMC_ARRAY[8'h9] =  8'h00;
        DMC_ARRAY[8'ha] =  8'h01;
        DMC_ARRAY[8'hb] =  8'h02;
        DMC_ARRAY[8'hc] =  8'h20;
        DMC_ARRAY[8'hd] =  8'h00;
        DMC_ARRAY[8'he] =  8'h00;
        DMC_ARRAY[8'hf] =  8'h00;
        DMC_ARRAY[8'h10] =  8'h01;
        DMC_ARRAY[8'h11] =  8'h00;
        DMC_ARRAY[8'h12] =  8'h01;
        DMC_ARRAY[8'h13] =  8'h00;
        DMC_ARRAY[8'h14] =  8'h00;
        DMC_ARRAY[8'h15] =  8'h00;
        DMC_ARRAY[8'h16] =  8'h00;
        DMC_ARRAY[8'h17] =  8'h00;
        DMC_ARRAY[8'h18] =  8'h02;
        DMC_ARRAY[8'h19] =  8'h00;
        DMC_ARRAY[8'h1a] =  8'h01;
        DMC_ARRAY[8'h1b] =  8'h02;
        DMC_ARRAY[8'h1c] =  8'h28;
        DMC_ARRAY[8'h1d] =  8'h00;
        DMC_ARRAY[8'h1e] =  8'h00;
        DMC_ARRAY[8'h1f] =  8'h00;
        DMC_ARRAY[8'h20] =  8'h05;
        DMC_ARRAY[8'h21] =  8'h20;
        DMC_ARRAY[8'h22] =  8'h38;
        DMC_ARRAY[8'h23] =  8'h00;
        DMC_ARRAY[8'h24] =  8'hff;
        DMC_ARRAY[8'h25] =  8'hff;
        DMC_ARRAY[8'h26] =  8'hff;
        DMC_ARRAY[8'h27] =  8'h07;
        DMC_ARRAY[8'h28] =  8'h00;
        DMC_ARRAY[8'h29] =  8'h00;
        DMC_ARRAY[8'h2a] =  8'h00;
        DMC_ARRAY[8'h2b] =  8'h00;
        DMC_ARRAY[8'h2c] =  8'h00;
        DMC_ARRAY[8'h2d] =  8'h00;
        DMC_ARRAY[8'h2e] =  8'h00;
        DMC_ARRAY[8'h2f] =  8'h00;
        DMC_ARRAY[8'h30] =  8'h00;
        DMC_ARRAY[8'h31] =  8'h36;
        DMC_ARRAY[8'h32] =  8'h00;
        DMC_ARRAY[8'h33] =  8'h27;
        DMC_ARRAY[8'h34] =  8'h00;
        DMC_ARRAY[8'h35] =  8'hfd;
        DMC_ARRAY[8'h36] =  8'h03;
        DMC_ARRAY[8'h37] =  8'h00;
    end

// *============================================================================================== 
// * Input/Output bus opearation 
// *============================================================================================== 
    assign WP_B_INT = (Status_Reg[6] == 1'b0) ? WP : 1'b1;
    assign   SO	    = SO_OUT_EN   ? SIO1_Reg : 1'bz ;
    assign   SI	    = SI_OUT_EN   ? SIO0_Reg : 1'bz ;
    assign   WP	    = WP_OUT_EN   ? SIO2_Reg : 1'bz ;
    assign   SIO3   = SIO3_OUT_EN ? SIO3_Reg : 1'bz ;
    assign   {SO, PO6, PO5, PO4, PO3, PO2, PO1, PO0 } = P_Mode_OUT ? {SIO1_Reg, PO_Reg} : 8'bz ;

    /*----------------------------------------------------------------------*/
    /*  When CP_mode,  Enable  SO to output RY/BY;                          */ 
    /*----------------------------------------------------------------------*/
    assign    CP_Busy = !(EN_CP_Mode && Status_Reg[0]);
    always @ ( negedge CS ) begin
	if ( (EN_CP_Mode == 1) && (CP_ESRY_Mode == 1'b1) ) begin
            CP_ESRY_ModeEN = 1'b1;
	    SO_OUT_EN =  1'b1;
	    SIO1_Reg <= #tCLQV_1XIO CP_Busy;
	end
        else begin
            CP_ESRY_ModeEN = 1'b0;
	end
    end

    always @ ( CP_Busy ) begin
	if ( CP_ESRY_ModeEN == 1 ) begin
	    SIO1_Reg <= #tCLQV_1XIO CP_Busy;
	end
    end

// *============================================================================================== 
// * Finite State machine to control Flash operation
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* power on              						    */
    /*----------------------------------------------------------------------*/
    initial begin 
	Chip_EN   <= #tVSL 1'b1;// Time delay to chip select allowed 
    end
    
    /*----------------------------------------------------------------------*/
    /* Command Decode        						    */
    /*----------------------------------------------------------------------*/
    assign WIP	    = Status_Reg[0] ;
    assign WEL	    = Status_Reg[1] ;
    assign SRWD     = Status_Reg[7] ;
    assign Dis_CE   = Status_Reg[5] == 1'b1 || Status_Reg[4] == 1'b1 || 
		      Status_Reg[3] == 1'b1 || Status_Reg[2] == 1'b1;
    assign HPM_RD   = EN4XIO_Read_Mode == 1'b1 || ENDDR4XIO_Read_Mode ;  
    assign DDR_Read_Mode = DDRRead_1XIO_Mode || DDRRead_2XIO_Mode || DDRRead_4XIO_Mode;
    assign Norm_Array_Mode = ~Secur_Mode;
    assign Dis_WRSR = (WP_B_INT == 1'b0 && Status_Reg[7] == 1'b1) || (!Norm_Array_Mode);
    assign WPSEL_Mode = Secur_Reg[7];

    always @ ( negedge CS ) begin
        SI_IN_EN = 1'b1; 
	if ( EN4XIO_Read_Mode == 1'b1 ) begin
	    //$display( $time, " Enter READX4 Function ..." );
            Read_SHSL = 1'b1;
	    STATE   <= `HPM_STATE;
	    Read_4XIO_Mode = 1'b1;
            Read_4XIO_Chk = 1'b1; 
	end
	if ( ENDDR4XIO_Read_Mode == 1'b1 ) begin
	    //$display( $time, " Enter DDR READX4 Function ..." );
            Read_SHSL = 1'b1;
	    STATE   <= `HPM_STATE;
	    DDRRead_4XIO_Mode = 1'b1;
            #1 DDR_Read_Mode_IN = 1'b1;
	end
	if ( HPM_RD == 1'b0 ) begin
            Read_SHSL <= #1 1'b0;   
	end
        #1;
        tDP_Chk = 1'b0; 
        tRES1_Chk = 1'b0; 
        tRES2_Chk = 1'b0; 
    end

    always @ ( negedge SCLK or posedge CS ) begin
        if ( CS == 1'b0 && DDR_Read_Mode == 1'b1 ) begin
            #1 DDR_Read_Mode_IN = 1'b1;
        end
        else begin
            DDR_Read_Mode_IN = 1'b0;
        end  
    end
   
    always @ ( negedge SCLK or posedge CS ) begin
	if ( CS == 1'b0 && DDR_Read_Mode_IN == 1'b1 ) begin
	    if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b1 && SIO3_IN_EN == 1'b1 ) begin
		SI_Reg[23:0] = {SI_Reg[19:0], SIO3, WP, SO, SI};
	    end 
	    else  if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 ) begin
		SI_Reg[23:0] = {SI_Reg[21:0], SO, SI};
	    end
	    else begin 
		SI_Reg[23:0] = {SI_Reg[22:0], SI};
	    end
	    if ( (ENDDR4XIO_Read_Mode == 1'b1 && Bit == 2 ) ||
	         (DDRRead_1XIO_Mode == 1'b1 && Bit == 19 ) ||
	         (DDRRead_2XIO_Mode == 1'b1 && Bit == 13 ) ||
	         (DDRRead_4XIO_Mode == 1'b1 && Bit == 10 && ENDDR4XIO_Read_Mode == 1'b0) ) begin
	        Address = SI_Reg [A_MSB:0];
	        load_address(Address);
	    end  
	end
    end 	

    always @ ( posedge SCLK or posedge CS ) begin
	if ( CS == 1'b0 ) begin
	    Bit_Tmp = Bit_Tmp + 1; 
	    Bit	= Bit_Tmp - 1;
	    if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b1 && SIO3_IN_EN == 1'b1 ) begin
		SI_Reg[23:0] = {SI_Reg[19:0], SIO3, WP, SO, SI};
	    end 
	    else  if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 ) begin
		SI_Reg[23:0] = {SI_Reg[21:0], SO, SI};
	    end
	    else begin 
		SI_Reg[23:0] = {SI_Reg[22:0], SI};
	    end
	    if ( EN4XIO_Read_Mode == 1'b1 && Bit == 5 ) begin
	        Address = SI_Reg [A_MSB:0];
	        load_address(Address);
	    end
	    if ( P_Mode == 1'b1 ) begin
	        {Latch_SO, Latch_PO} = {SO,PO6, PO5, PO4, PO3, PO2, PO1, PO0};
	    end
	end	
  
	if ( Bit == 7 && CS == 1'b0 && ~HPM_RD ) begin
	    STATE = `CMD_STATE;
	    CMD_BUS = SI_Reg[7:0];
	    //$display( $time,"SI_Reg[7:0]= %h ", SI_Reg[7:0] );
	end
	
	case ( STATE )
	    `STANDBY_STATE: 
	        begin
	        end
        
	    `CMD_STATE: 
	        begin
	            case ( CMD_BUS )
	            WREN: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin	
	    			    // $display( $time, " Enter Write Enable Function ..." );
	    			    write_enable;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE; 
	    		    end 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 
	    		end
		     
	    	    WRDI:   
	    		begin
	                    if ( !DP_Mode && !WIP && Chip_EN ) begin
	                        if ( CS == 1'b1 && Bit == 7 ) begin	
	    			    // $display( $time, " Enter Write Disable Function ..." );
	    			    write_disable;
	                        end
	                        else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE; 
	    		    end 
	                    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 
	    		end 
	                 
	    	    RDID:
	    		begin  
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin 
	    			//$display( $time, " Enter Read ID Function ..." );
                               if ( Bit == 7 ) begin
	    			    RDID_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
                                end 
                            end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 	
	    		end
                      
	            RDSR:
	    		begin 
	    		    if ( !DP_Mode && (EN_CP_Mode && CP_ESRY_Mode) == 1'b0 && Chip_EN ) begin 
	    			//$display( $time, " Enter Read Status Function ..." );
                                if ( Bit == 7 ) begin
	    			    RDSR_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
                                end 
                            end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 	
	    		end
           
	            WRSR:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && !Dis_WRSR && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 15 ) begin
	    			    //$display( $time, " Enter Write Status Function ..." ); 
	    			    ->WRSR_Event;
	    			    WRSR_Mode = 1'b1;
	    			end    
	    			else if ( CS == 1'b1 && Bit < 15 || Bit > 15 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end 
                      
	            READ1X: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter Read Data Function ..." );
	    			if ( Bit == 31 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			end
	    			if ( Bit == 7 ) begin
	    			    Read_1XIO_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
	    			end
	    		    end	
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;				
	    		end
                     
	            FASTREAD1X:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter Fast Read Data Function ..." );
                                Read_SHSL = 1'b1;
	    			if ( Bit == 31 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			end
	    			if ( Bit == 7 ) begin
	    			    FastRD_1XIO_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
	    			end
	    		    end	
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;				
	    		end

	            SE: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && !Secur_Mode && !DMC_Mode && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address =  SI_Reg[A_MSB:0];
	    			end
	    			if ( CS == 1'b1 && Bit == 31 ) begin
	    			    //$display( $time, " Enter Sector Erase Function ..." );
	    			    ->SE_4K_Event;
	    			    SE_4K_Mode = 1'b1;
	    			end
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	                     	     STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end

	            BE: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && !Secur_Mode && !DMC_Mode && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			if ( CS == 1'b1 && Bit == 31 ) begin
	    			    //$display( $time, " Enter Block Erase Function ..." );
	    			    ->BE_Event;
	    			    BE_Mode = 1'b1;
	    			end 
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end
                      
	            CE1, CE2:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && !Secur_Mode && !DMC_Mode && Chip_EN ) begin

	    			if ( CS == 1'b1 && Bit == 7  ) begin
	    			    //$display( $time, " Enter Chip Erase Function ..." );
	    			    ->CE_Event;
	    			    CE_Mode = 1'b1 ;
	    			end 
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 ) 
	    			STATE <= `BAD_CMD_STATE;
	    		end
                      
	            PP: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			end
	    			if ( Bit == 7 ) begin
	    			    PP_1XIO_Load = 1'b1;
	    			end
	    			if ( CS == 1'b0 && Bit == 31 ) begin
	    			    //$display( $time, " Enter Page Program Function ..." );
				    ->PP_Event;
				    PP_1XIO_Mode = 1'b1;
	    			end
	    			else if ( CS == 1 &&( ( P_Mode == 1'b0 && ((Bit < 39) || ((Bit + 1) % 8 !== 0))) || 
                                                      ( P_Mode == 1'b1 && (Bit < 32) )) ) begin
	    			    STATE <= `BAD_CMD_STATE;
	    			end
                            end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            DP: 
	    		begin
	    		    if ( !WIP && !EN_CP_Mode && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 && DP_Mode == 1'b0 ) begin
	    			    //$display( $time, " Enter Deep Power Dwon Function ..." );
	    			    tDP_Chk = 1'b1;
                                    DP_Mode = 1'b1;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end	 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end
                      
                      
	            RDP, RES: 
	    		begin
	    		    if ( !WIP && !EN_CP_Mode && Chip_EN ) begin
	    			// $display( $time, " Enter Release from Deep Power Dwon Function ..." );
	    			if ( Bit == 7 ) begin
	    			    RES_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			    if ( DP_Mode == 1'b1 ) begin
	    			       tRES1_Chk = 1'b1;
                                       DP_Mode = 1'b0;
                                    end
	    			    if ( Enhance_Mode == 1'b1 ) begin
	    			       Enhance_Mode = 1'b0;
                                    end   
	    			end
	    			if ( Bit == 38 && tRES1_Chk == 1'b1) begin
                                    tRES1_Chk = 1'b0;
                                    tRES2_Chk = 1'b1;
	    			end
	    		    end 
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            REMS, REMS2, REMS4, REMS4D:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			//$display( $time, " Enter Read Electronic Manufacturer & ID Function ..." );
	    			if ( Bit == 7 ) begin
	    			    REMS_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            READ2X: 
	    		begin 
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter READX2 Function ..." );
	    			if ( Bit == 19 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			end
	    			if ( Bit == 7 ) begin
	    			    Read_2XIO_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end	
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;				
	    		end 	

	            CP: 
	    		begin
	    		    if ( !DP_Mode && !WIP && WEL && Chip_EN ) begin
	    			if ( EN_CP_Mode == 1'b0 && Bit == 31 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			    Address = {Address [A_MSB:1], 1'b0} ;
	    			end
	    			if ( CS == 1'b0 && ((EN_CP_Mode == 1'b0 && Bit == 47) || (EN_CP_Mode == 1'b1 && Bit == 23))
                                    && write_protect(Address) == 1'b0 ) begin 
	    			    //$display( $time, " Enter CP Mode Function ..." );
	    			    ->CP_Event;
	    			end
	    			else if ( CS == 1'b1 && ((EN_CP_Mode == 1'b0 && Bit < 47) ||
	    			    (EN_CP_Mode == 1'b1 && Bit < 23) || ((Bit + 1) % 8 !== 0))) begin
	    			    STATE <= `BAD_CMD_STATE;
                                end   
	    		    end
	    		    else if ( Bit == 7 )
	    			 STATE <= `BAD_CMD_STATE;
	    		end
 
	    	    ENSO: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin  
	    			    //$display( $time, " Enter ENSO  Function ..." );
	    			    enter_secured_otp;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end
                      
	            EXSO: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin  
	    			    //$display( $time, " Enter EXSO  Function ..." );
	    			    exit_secured_otp;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end
                      
	            RDSCUR: 
	    		begin
	    		    if ( !DP_Mode && (EN_CP_Mode && CP_ESRY_Mode) == 1'b0 && Chip_EN ) begin 
	    			// $display( $time, " Enter Read Secur_Register Function ..." );
	    			if ( Bit == 7 ) begin
	    			    RDSCUR_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
	    			end
                            end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;				
	    		end
                      
                      
	            WRSCUR: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && !Secur_Mode && !DMC_Mode && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin  
	    			    //$display( $time, " Enter WRSCUR Secur_Register Function ..." );
	    			    ->WRSCUR_Event;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end
                      
	            ESRY: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin 
	    			    //$display( $time, " Enter ESRY  Function ..." );
	    			    read_ryby;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	                    end
	                    else if ( Bit == 7 )
	                       	 STATE <= `BAD_CMD_STATE;
	                end
                      
	            DSRY: 
	    		begin 
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin 
	    			    //$display( $time, " Enter DSRY  Function ..." );
	    			    disread_ryby;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            READ4X:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Status_Reg[6] && Chip_EN ) begin
	    			//$display( $time, " Enter READX4 Function ..." );
	    			if ( Bit == 13 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			end
 	    			if ( Bit == 7 ) begin
	    			    Read_4XIO_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end
                      
	            FIOPGM0: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && Status_Reg[6] && !P_Mode && Chip_EN ) begin
	    			if ( Bit == 13 ) begin
	                            Address = SI_Reg [A_MSB:0];
	                            load_address(Address);
	    			end
	    			if ( Bit == 7 ) begin
                                    PP_4XIO_Load= 1'b1;
	    			    SO_IN_EN    = 1'b1;
	    			    SI_IN_EN    = 1'b1;
	    			    WP_IN_EN    = 1'b1;
	    			    SIO3_IN_EN  = 1'b1;
	    			end
	    			if ( CS == 1'b0 && Bit == 13 ) begin
	                     	    //$display( $time, " Enter 4io Page Program Function ..." );
	                     	    ->PP_Event;
	                     	    PP_4XIO_Mode= 1'b1;
	    			end
                                else if ( CS == 1 && (Bit < 15 || (Bit + 1)%2 !== 0 )) begin
	    			    STATE <= `BAD_CMD_STATE;
	    			end    
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

                    CLSR:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && !EN_CP_Mode ) begin
                                if ( CS == 1'b1 && Bit == 7 ) begin
                                    // $display( $time, " Enter clear security register Function ..." );
                                    clr_secur_register;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

 	            HPM:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin
	    			    //$display( $time, " Enter Enhance quad byte Function ..." );
	    			    enhance_read;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            DDRREAD1X:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter DDR READX1 Function ..." );
 	    			if ( Bit == 7 ) begin
	    			    DDRRead_1XIO_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            DDRREAD2X:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter DDR READX2 Function ..." );
 	    			if ( Bit == 7 ) begin
	    			    DDRRead_2XIO_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            DDRREAD4X:
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Status_Reg[6] && Chip_EN ) begin
	    			//$display( $time, " Enter DDR READX4 Function ..." );
 	    			if ( Bit == 7 ) begin
	    			    DDRRead_4XIO_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            BE2: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && !Secur_Mode && !DMC_Mode && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			if ( CS == 1'b1 && Bit == 31  ) begin
	    			    //$display( $time, " Enter Block 32K Erase Function ..." );
	    			    ->BE32K_Event;
	    			    BE_Mode = 1'b1;
	    			end 
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end

	    	    ENPLM: 
			begin
	    	            if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    	                if ( CS== 1'b1 && Bit == 7 ) begin  
				    //$display( $time, " Enter PARALLELMODE Function ..." );
				    parallel_mode;
	    	                end
	    	                else if ( Bit > 7 )
				    STATE <= `BAD_CMD_STATE;
	    	            end
	    	            else if ( Bit == 7 )
	    	            	STATE <= `BAD_CMD_STATE;
	    	        end
                      
	    	    EXPLM: 
			begin
	    	            if ( !DP_Mode && !EN_CP_Mode && !WIP && Chip_EN ) begin
	    	                if ( CS== 1'b1 && Bit == 7 ) begin  
				    //$display( $time, " Exit PARALLELMODE Function ..." );
				    exit_parallel_mode;
	    	                end
	    	                else if ( Bit > 7 )
				    STATE <= `BAD_CMD_STATE;
	    	            end
	    	            else if ( Bit == 7 )
	    	            	STATE <= `BAD_CMD_STATE;
	    	        end

	    	    DMC_READ: 
			begin
	    	            if ( !DP_Mode && !EN_CP_Mode && !Secur_Mode && !WIP && Chip_EN ) begin
				//$display( $time, " Enter DMC read mode ..." );
				if ( Bit == 31 ) begin
				    Address = SI_Reg [A_MSB:0];
				    load_address(Address);
				end
 	    			if ( Bit == 7 ) begin
	    			    DMC_Mode = 1;
	    			    FastRD_1XIO_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    	            end
	    	            else if ( Bit == 7 )
	    	            	STATE <= `BAD_CMD_STATE;
	    	        end

	            WPSEL: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && Norm_Array_Mode && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin  
	    			    //$display( $time, " Enter Write Protection Selection Function ..." );
	    			    ->WPSEL_Event;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            SBLK: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			if ( CS == 1'b1 && Bit == 31 ) begin 
	    			    //$display( $time, " Enter Sector Protection Function ..." );
	    			    ->SBLK_Event;
	    			end
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            SBULK: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			if ( CS == 1'b1 && Bit == 31 ) begin 
	    			    //$display( $time, " Enter Sector Unprotection Function ..." );
	    			    ->SBULK_Event;
	    			end
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            RDBLOCK: 
	    		begin 
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WPSEL_Mode && Chip_EN ) begin
	    			//$display( $time, " Enter Sector protection Read Function ..." );
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0];
	    			end
 	    			if ( Bit == 7 ) begin
	    			    SEC_PROVFY_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end 
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end
                     
	            GBLK: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin 
	    			    //$display( $time, " Enter Chip Protection Function ..." );
	    			    ->GBLK_Event;
	    			end
	    			else if ( CS == 1'b1 && Bit > 7 )             
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            GBULK: 
	    		begin
	    		    if ( !DP_Mode && !EN_CP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin 
	    			    //$display( $time, " Enter Chip Unprotection Function ..." );
	    			    ->GBULK_Event;
	    			end
	    			else if ( CS == 1'b1 && Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end

	            default: 
	    		begin
	    		    STATE <= `BAD_CMD_STATE;
	    		end
		    endcase
	        end
	    `HPM_STATE: 
	        begin
	        end

                 
	    `BAD_CMD_STATE: 
	        begin
	        end
            
	    default: 
	        begin
	    	STATE =  `STANDBY_STATE;
	        end
	endcase
    end 

    always @ (posedge CS) begin 
	if ( Set_4XIO_Enhance_Mode) 
	    EN4XIO_Read_Mode = 1'b1;
	else
	    EN4XIO_Read_Mode = 1'b0;

	if ( Set_4XIO_DDR_Enhance_Mode) 
	    ENDDR4XIO_Read_Mode = 1'b1;
	else
	    ENDDR4XIO_Read_Mode = 1'b0;
        
        if ( P_Mode_Chk == 1'b0 )  begin
	    SO_OUT_EN    <= #tSHQZ_S 1'b0;
	    SI_OUT_EN    <= #tSHQZ_S 1'b0;
	    WP_OUT_EN    <= #tSHQZ_S 1'b0;
	    SIO3_OUT_EN  <= #tSHQZ_S 1'b0;

	    SIO0_Reg <= #tSHQZ_S 1'bx;
	    SIO1_Reg <= #tSHQZ_S 1'bx;
	    SIO2_Reg <= #tSHQZ_S 1'bx;
	    SIO3_Reg <= #tSHQZ_S 1'bx;
        end 
        else begin
	    SO_OUT_EN    <= #tSHQZ_P 1'b0;
	    PO_Reg[6:0]  <= #tSHQZ_P 7'bx;
	    SIO1_Reg     <= #tSHQZ_P 1'bx;
        end
            
        #1; 
	Bit		= 1'b0;
	Bit_Tmp	= 1'b0;
	SO_IN_EN	= 1'b0;
	SI_IN_EN	= 1'b0;
	WP_IN_EN	= 1'b0;
	SIO3_IN_EN  = 1'b0;
        
	RES_Mode	= 1'b0;
	REMS_Mode	= 1'b0;
        DMC_Mode    = 1'b0;
        RDID_Mode   = 1'b0;
        RDSR_Mode   = 1'b0;
        RDSCUR_Mode = 1'b0;
        RDID_Mode   = 1'b0;
	SEC_PROVFY_Mode = 1'b0;
        CP_ESRY_ModeEN = 1'b0;
	Read_1XIO_Mode  = 1'b0;
	Read_2XIO_Mode  = 1'b0;
	Read_4XIO_Mode  = 1'b0;
	Read_1XIO_Chk   = 1'b0;
	Read_2XIO_Chk   = 1'b0;
	Read_4XIO_Chk   = 1'b0;
        P_Mode_Chk      = 1'b0;
        P_Mode_IN       = 1'b0;
        P_Mode_OUT      = 1'b0;

	FastRD_1XIO_Mode  = 1'b0;
        DDRRead_1XIO_Mode	= 1'b0;
        DDRRead_2XIO_Mode	= 1'b0;
        DDRRead_4XIO_Mode	= 1'b0;
        DDR_Read_Mode_IN    = 1'b0;  
	PP_4XIO_Load    = 1'b0;
	PP_4XIO_Chk     = 1'b0;
	PP_1XIO_Load    = 1'b0;
	STATE <=  `STANDBY_STATE;

        disable read_1xio;
        disable read_2xio;
        disable read_4xio;
        disable ddrread_1xio;
        disable ddrread_2xio;
        disable ddrread_4xio;
        disable read_status;
        disable read_secur_register;
        disable read_id;
        disable read_electronic_id;
        disable read_electronic_manufacturer_device_id;
        disable sector_protection_read;
	disable dummy_cycle;
    end 

    /*----------------------------------------------------------------------*/
    /*	ALL function trig action            				    */
    /*----------------------------------------------------------------------*/
    always @ ( negedge SCLK ) begin
        if (Read_1XIO_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            if ( P_Mode == 1'b0 )  begin
                Read_1XIO_Chk = 1'b1;
            end 
            else begin
                P_Mode_Chk = 1'b1; 
            end
        end
        if (Read_2XIO_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            Read_2XIO_Chk = 1'b1;
        end
        if (Read_4XIO_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            Read_4XIO_Chk = 1'b1;
        end
        if (PP_4XIO_Load == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            PP_4XIO_Chk = 1'b1;
        end
        if ( RDSR_Mode == 1'b1 && P_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            P_Mode_Chk = 1'b1;
        end
        if ( RDID_Mode == 1'b1 && P_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            P_Mode_Chk = 1'b1;
        end
        if (RES_Mode == 1'b1 && P_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            P_Mode_Chk = 1'b1;
        end
        if (REMS_Mode == 1'b1 && P_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            P_Mode_Chk = 1'b1;
        end
        if (PP_1XIO_Load == 1'b1 && P_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            P_Mode_Chk = 1'b1;
        end
    end
 
    always @ ( posedge P_Mode_Chk ) begin
        SI_IN_EN =1'b0;
    end

    always @ ( posedge Read_1XIO_Mode ) begin
	read_1xio;
    end 

    always @ ( posedge FastRD_1XIO_Mode ) begin
        fastread_1xio;
    end

    always @ ( posedge REMS_Mode ) begin
        read_electronic_manufacturer_device_id;
    end

    always @ ( posedge RES_Mode ) begin
        read_electronic_id;
    end
 
    always @ ( posedge RDID_Mode ) begin
	read_id;
    end 

    always @ ( posedge RDSR_Mode ) begin
	read_status;
    end 

    always @ ( posedge Read_2XIO_Mode ) begin
	read_2xio;
    end 

    always @ ( posedge Read_4XIO_Mode ) begin
	read_4xio;
    end 

    always @ ( posedge RDSCUR_Mode ) begin
	read_secur_register;
    end 

    always @ ( posedge SEC_PROVFY_Mode ) begin
	sector_protection_read;
    end 

    always @ ( posedge DDRRead_1XIO_Mode ) begin
	ddrread_1xio;
    end 

    always @ ( posedge DDRRead_2XIO_Mode ) begin
	ddrread_2xio;
    end 

    always @ ( posedge DDRRead_4XIO_Mode ) begin
	ddrread_4xio;
    end 
    
    always @ ( WRSR_Event ) begin
	write_status;
    end

    always @ ( BE_Event ) begin
	block_erase;
    end

    always @ ( CE_Event ) begin
	chip_erase;
    end
    
    always @ ( PP_Event ) begin
        page_program( Address );
    end
   
    always @ ( SE_4K_Event ) begin
	sector_erase_4k;
    end

    always @ ( CP_Event ) begin
	cp_program;
    end

    always @ ( WRSCUR_Event ) begin
	write_secur_register;
    end

    always @ ( BE32K_Event ) begin
	block_erase_32k;
    end

    always @ ( SBLK_Event ) begin
	single_block_lock;
    end

    always @ ( SBULK_Event ) begin
	single_block_unlock;
    end

    always @ ( GBLK_Event ) begin
	chip_lock;
    end

    always @ ( GBULK_Event ) begin
	chip_unlock;
    end

    always @ ( WPSEL_Event ) begin
	write_protection_select;
    end

// *========================================================================================== 
// * Module Task Declaration
// *========================================================================================== 
    /*----------------------------------------------------------------------*/
    /*	Description: define a wait dummy cycle task			    */
    /*	INPUT							            */
    /*	    Cnum: cycle number						    */
    /*----------------------------------------------------------------------*/
    task dummy_cycle;
	input [31:0] Cnum;
	begin
	    repeat( Cnum ) begin
		@ ( posedge SCLK );
	    end
	end
    endtask // dummy_cycle

    /*----------------------------------------------------------------------*/
    /*	Description: define a write enable task				    */
    /*----------------------------------------------------------------------*/
    task write_enable;
	begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
	    Status_Reg[1] = 1'b1; 
	    // $display( $time, " New Status Register = %b", Status_Reg );
	end
    endtask // write_enable
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a write disable task (WRDI)			    */
    /*----------------------------------------------------------------------*/
    task write_disable;
	begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
	    Status_Reg[1]  = 1'b0;
	    EN_CP_Mode	   = 1'b0;
	    Secur_Reg[4] = 1'b0;  
	    //$display( $time, " New Status Register = %b", Status_Reg );
	end
    endtask // write_disable
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read id task (RDID)			    */
    /*----------------------------------------------------------------------*/
    task read_id;
	reg  [23:0] Dummy_ID;
	integer Dummy_Count;
	begin
	    Dummy_ID	= {ID_MXIC, Memory_Type, Memory_Density};
	    Dummy_Count = 0;
	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_id;
		end
		else begin
		    SO_OUT_EN = 1'b1;
		    if ( P_Mode == 1'b0 ) begin 
		        {SIO1_Reg, Dummy_ID} <= #tCLQV_1XIO {Dummy_ID, Dummy_ID[23]};
		    end
		    else begin
                        P_Mode_OUT = 1'b1; 
		        if ( Dummy_Count == 0 ) begin
		            {SIO1_Reg,PO_Reg} <= #tCLQV_P ID_MXIC;
		            Dummy_Count = 1;
		        end	
		        else if ( Dummy_Count == 1 ) begin	
		            {SIO1_Reg,PO_Reg} <= #tCLQV_P Memory_Type;
		            Dummy_Count = 2;
		        end
		        else if ( Dummy_Count == 2 ) begin			     
		            {SIO1_Reg,PO_Reg} <= #tCLQV_P Memory_Density;
		            Dummy_Count = 0;
		        end    
		    end
		end
	    end  // end forever
	end
    endtask // read_id
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read status task (RDSR)			    */
    /*----------------------------------------------------------------------*/
    task read_status;
	integer Dummy_Count;
	begin
	    Dummy_Count = 8;
	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_status;
		end
		else begin
		    SO_OUT_EN = 1'b1;
		    if ( P_Mode == 1'b0 ) begin
			if ( Dummy_Count ) begin
			    Dummy_Count = Dummy_Count - 1;
			    SIO1_Reg    <= #tCLQV_1XIO Status_Reg[Dummy_Count];
			end
			else begin
			    Dummy_Count = 7;
			    SIO1_Reg    <= #tCLQV_1XIO Status_Reg[Dummy_Count];
			end		 
		    end
		    else begin 
                        P_Mode_OUT = 1'b1; 
			{SIO1_Reg,PO_Reg} <= #tCLQV_P Status_Reg;
		    end
		end
	    end  // end forever
	end
    endtask // read_status


    /*----------------------------------------------------------------------*/
    /*	Description: define a write status task				    */
    /*----------------------------------------------------------------------*/
    task write_status;
    integer tWRSR;
    reg [7:0] Status_Reg_Up;
	begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
            if ( WPSEL_Mode == 1'b0 ) begin
	    	Status_Reg_Up = SI_Reg[7:0] ;
	    	if ( (Status_Reg[7] == 1'b1 && Status_Reg_Up[7] == 1'b0 ) ||
		    (Status_Reg[6] == 1'b1 && Status_Reg_Up[6] == 1'b0 ) ||
		    (Status_Reg[5] == 1'b1 && Status_Reg_Up[5] == 1'b0 ) ||
		    (Status_Reg[4] == 1'b1 && Status_Reg_Up[4] == 1'b0 ) ||
		    (Status_Reg[3] == 1'b1 && Status_Reg_Up[3] == 1'b0 ) ||
		    (Status_Reg[2] == 1'b1 && Status_Reg_Up[2] == 1'b0 ))
		    tWRSR = tW;
		else
		    tWRSR = tBP; 
            end
            else begin
	    	Status_Reg_Up[6] = SI_Reg[6] ;
	    	if ((Status_Reg[6] == 1'b1 && Status_Reg_Up[6] == 1'b0 ))
		    tWRSR = tW;
		else
		    tWRSR = tBP; 
            end
	    //SRWD:Status Register Write Protect
            Status_Reg[0]   = 1'b1;
            #tWRSR;
	    Status_Reg[7]   =  Status_Reg_Up[7] && (!WPSEL_Mode);
	    Status_Reg[6]   =  Status_Reg_Up[6];
	    Status_Reg[5]   =  Status_Reg_Up[5] && (!WPSEL_Mode);
	    Status_Reg[4]   =  Status_Reg_Up[4] && (!WPSEL_Mode);
	    Status_Reg[3]   =  Status_Reg_Up[3] && (!WPSEL_Mode);
	    Status_Reg[2]   =  Status_Reg_Up[2] && (!WPSEL_Mode);
	    //WIP:Write Enable Latch
	    Status_Reg[0]   = 1'b0;
	    //WEL:Write Enable Latch
	    Status_Reg[1]   = 1'b0;
	    WRSR_Mode       = 1'b0;
	end
    endtask // write_status
   
    /*----------------------------------------------------------------------*/
    /*	Description: define a read data task				    */
    /*----------------------------------------------------------------------*/
    task read_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	begin
	    Dummy_Count = 8;
            dummy_cycle(24);
            #1; 
	    read_array(Address, OUT_Buf);
	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_1xio;
		end 
		else  begin 
		    SO_OUT_EN	= 1'b1;
		    if ( P_Mode == 1'b0 ) begin
			if ( Dummy_Count ) begin
			    {SIO1_Reg, OUT_Buf} <= #tCLQV_1XIO {OUT_Buf, OUT_Buf[7]};
			    Dummy_Count = Dummy_Count - 1;
			end
			else begin
			    Address = Address + 1;
			    load_address(Address);
			    read_array(Address, OUT_Buf);
			    {SIO1_Reg, OUT_Buf} <= #tCLQV_1XIO  {OUT_Buf, OUT_Buf[7]};
			    Dummy_Count = 7 ;
			end
		    end
		    else begin
                        P_Mode_OUT = 1'b1; 
			read_array(Address, OUT_Buf);
			{SIO1_Reg,PO_Reg} <= #tCLQV_1XIO {OUT_Buf};
			Address = Address + 1;
			load_address(Address);
		    end
		end 
	    end  // end forever
	end   
    endtask // read_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast read data task			    */
    /*		     0B AD1 AD2 AD3 X					    */
    /*----------------------------------------------------------------------*/
    task fastread_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	begin
	    Dummy_Count = 8;
	    dummy_cycle(24);
	    dummy_cycle(8);
	    read_array(Address, OUT_Buf);
	    
	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable fastread_1xio;
		end 
		else begin 
		    SO_OUT_EN = 1'b1;
		    if ( Dummy_Count ) begin
			{SIO1_Reg, OUT_Buf} <= #tCLQV_1XIO {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
			load_address(Address);
			read_array(Address, OUT_Buf);
			{SIO1_Reg, OUT_Buf} <= #tCLQV_1XIO {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = 7 ;
		    end
		end    
	    end  // end forever
	end   
    endtask // fastread_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a block erase task				    */
    /*		     D8 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task block_erase;
	reg [Block_MSB:0] Block; 
	integer i;
	begin
	    Block	=  Address[A_MSB:16];
	    Start_Add	= (Address[A_MSB:16]<<16) + 16'h0;
	    End_Add	= (Address[A_MSB:16]<<16) + 16'hffff;
	    //WIP : write in process Bit
	    Status_Reg[0] =  1'b1;
	    if ( write_protect(Address) == 1'b0 ) begin
	        #tBE ;
	        for( i = Start_Add; i <= End_Add; i = i + 1 )
	        begin
	            ARRAY[i] = 8'hff;
	        end
	        //WIP : write in process Bit
	        Status_Reg[0] =  1'b0;//WIP
	        //WEL : write enable latch
	        Status_Reg[1] =  1'b0;//WEL
	        BE_Mode = 1'b0;
	    end
	    else begin
	        #tERS_CHK;
                Secur_Reg[6] = 1'b1;
	        Status_Reg[0] = 1'b0;//WIP
	        Status_Reg[1] = 1'b0;//WEL
	        BE_Mode = 1'b0;
	    end 
	end
    endtask // block_erase

    /*----------------------------------------------------------------------*/
    /*	Description: define a sector 4k erase task			    */
    /*		     20 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task sector_erase_4k;
	integer i;
	begin
	    Sector	=  Address[A_MSB:12]; 
	    Start_Add	= (Address[A_MSB:12]<<12) + 12'h000;
	    End_Add	= (Address[A_MSB:12]<<12) + 12'hfff;	      
	    //WIP : write in process Bit
	    Status_Reg[0] =  1'b1;
	    if ( write_protect(Address) == 1'b0 ) begin
	       #tSE;
	       for( i = Start_Add; i <= End_Add; i = i + 1 )
	       begin
	           ARRAY[i] = 8'hff;
	       end
	       //WIP : write in process Bit
	       Status_Reg[0] = 1'b0;//WIP
	       //WEL : write enable latch
	       Status_Reg[1] = 1'b0;//WEL
	       SE_4K_Mode = 1'b0;
	    end 
	    else begin
	        #tERS_CHK;
                Secur_Reg[6] = 1'b1;
	        Status_Reg[0] = 1'b0;//WIP
	        Status_Reg[1] = 1'b0;//WEL
	        SE_4K_Mode = 1'b0;
	    end
	end
    endtask // sector_erase_4k
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a chip erase task				    */
    /*		     60(C7)						    */
    /*----------------------------------------------------------------------*/
    task chip_erase;
        begin
            Status_Reg[0] =  1'b1;
            if ( (Dis_CE == 1'b1 && WPSEL_Mode == 1'b0) || ((SEC_Pro_Reg || SEC_Pro_Reg_BOT || SEC_Pro_Reg_TOP || (WP_B_INT == 1'b0)) && WPSEL_Mode == 1'b1)) begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end
            else begin
            	for ( i = 0;i<tCE/1000;i = i + 1) begin
                    #1000_000_000;
                end
            	for( i = 0; i <Block_NUM; i = i+1 ) begin
	            Address = (i<<16) + 16'h0;
	            Start_Add = (i<<16) + 16'h0;
	            End_Add   = (i<<16) + 16'hffff;	
	            for( j = Start_Add; j <=End_Add; j = j + 1 )
	            begin
	                ARRAY[j] =  8'hff;
	            end
	        end
	    end
            i = 0;
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;//WIP
            //WEL : write enable latch
            Status_Reg[1] = 1'b0;//WEL
	    CE_Mode = 1'b0;
        end
    endtask // chip_erase	

    /*----------------------------------------------------------------------*/
    /*	Description: define a page program task				    */
    /*		     02 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task page_program;
	input  [A_MSB:0]  Address;
	reg    [7:0]	  Offset;
	integer Dummy_Count, Tmp_Int, i;
	begin
	    Dummy_Count = Page_Size;    // page size
	    Tmp_Int = 0;
            Offset  = Address[7:0];
	    /*------------------------------------------------*/
	    /*	Store 256 bytes into a temp buffer - Dummy_A  */
	    /*------------------------------------------------*/
            for (i = 0; i < Dummy_Count ; i = i + 1 ) begin
		Dummy_A[i]  = 8'hff;
            end
	    forever begin
		@ ( posedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    if ( (Tmp_Int % 8 !== 0) || (Tmp_Int == 1'b0) ) begin
			PP_4XIO_Mode = 0;
			PP_1XIO_Mode = 0;
			disable page_program;
		    end
		    else begin
		        if ( Tmp_Int > 8 )
			    Byte_PGM_Mode = 1'b0;
                        else 
			    Byte_PGM_Mode = 1'b1;
			update_array ( Address );
		    end
		    disable page_program;
		end
		else begin  // count how many Bits been shifted
		    if ( P_Mode == 1'b0 ) begin
			Tmp_Int = PP_4XIO_Mode == 1'b1 ? Tmp_Int + 4 : Tmp_Int + 1;
		        if ( Tmp_Int % 8 == 0) begin
                            #1;
			    Dummy_A[Offset] = SI_Reg [7:0];
			    Offset = Offset + 1;   
                            Offset = Offset[7:0];   
                        end  
		    end    
		    else begin
                        P_Mode_IN = 1'b1; 
			Tmp_Int = Tmp_Int + 8;
		        if ( Tmp_Int % 8 == 0) begin
                            #1; 
			    Dummy_A[Offset] = {Latch_SO, Latch_PO};
			    Offset = Offset + 1;
                            Offset = Offset[7:0];   
                        end  
		    end
		end
	    end  // end forever
	end
    endtask // page_program

    /*----------------------------------------------------------------------*/
    /*	Description: define a read electronic ID (RES)			    */
    /*		     AB X X X						    */
    /*----------------------------------------------------------------------*/
    task read_electronic_id;
	reg  [7:0] Dummy_ID;
	begin
            dummy_cycle(23);
	    Dummy_ID = ID_Device;
	    dummy_cycle(1);

	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_electronic_id;
		end 
		else begin  
		    SO_OUT_EN = 1'b1;
		    if ( P_Mode == 1'b0 ) begin
			{SIO1_Reg, Dummy_ID} <= #tCLQV_1XIO  {Dummy_ID, Dummy_ID[7]};
		    end 
		    else begin
                        P_Mode_OUT = 1'b1; 
			{SIO1_Reg,PO_Reg} <= #tCLQV_P ID_Device; 
		    end
		end
	    end // end forever	 
	end
    endtask // read_electronic_id
	    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read electronic manufacturer & device ID	    */
    /*----------------------------------------------------------------------*/
    task read_electronic_manufacturer_device_id;
	reg  [15:0] Dummy_ID;
	integer Dummy_Count;
	begin
	    dummy_cycle(24);
	    #1;
	    if ( Address[0] == 1'b0 ) begin
		Dummy_ID = {ID_MXIC,ID_Device};
	    end
	    else begin
		Dummy_ID = {ID_Device,ID_MXIC};
	    end
	    Dummy_Count = 0;
	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_electronic_manufacturer_device_id;
		end
		else begin
		    SO_OUT_EN =  1'b1;
		    if ( P_Mode == 1'b0 ) begin // check parallel mode (2)
		        {SIO1_Reg, Dummy_ID} <= #tCLQV_1XIO  {Dummy_ID, Dummy_ID[15]};
		    end	
		    else if ( P_Mode == 1'b1 ) begin
                        P_Mode_OUT = 1'b1; 
		        if ( Dummy_Count == 0 ) begin
		            {SIO1_Reg,PO_Reg} <= #tCLQV_P Dummy_ID[15:8];
		            Dummy_Count = 1;
		        end
		        else begin
		            {SIO1_Reg,PO_Reg} <= #tCLQV_P Dummy_ID[7:0];
		            Dummy_Count = 0;
		        end
		    end
		end
	    end	// end forever
	end
    endtask // read_electronic_manufacturer_device_id

    /*----------------------------------------------------------------------*/
    /*	Description: define a program chip task				    */
    /*	INPUT				program_time			    */
    /*	    segment: segment address					    */
    /*	    offset : offset address					    */
    /*----------------------------------------------------------------------*/
    task update_array;
	input [A_MSB:0] Address;
	integer Dummy_Count;
        integer program_time;
	begin
	    Dummy_Count = Page_Size;
            Address = { Address [A_MSB:8], 8'h0 };
            program_time = (Byte_PGM_Mode) ? tBP : tPP;
	    Status_Reg[0]= 1'b1;
	    if ( write_protect(Address) == 1'b0 ) begin
	        #program_time ;
		for ( i = 0; i < Dummy_Count; i = i + 1 ) begin
		    if ( Secur_Mode == 1'b1)
			Secur_ARRAY[Address + i] = Secur_ARRAY[Address + i] & Dummy_A[i];  
		    else   	
			ARRAY[Address+ i] = ARRAY[Address + i] & Dummy_A[i];
		end
	    end
	    else begin
	        #tPGM_CHK ;
                Secur_Reg[5] = 1'b1;
	    end
	    Status_Reg[0] = 1'b0;
	    Status_Reg[1] = 1'b0;
	    PP_4XIO_Mode = 1'b0;
	    PP_1XIO_Mode = 1'b0;
            Byte_PGM_Mode = 1'b0;
	end
    endtask // update_array


    /*----------------------------------------------------------------------*/
    /*	Description: define a enter secured OTP task		    */
    /*----------------------------------------------------------------------*/
    task enter_secured_otp;
	begin
	    //$display( $time, " Enter secured OTP mode  = %b",  enter_Secur_Mode );
	    Secur_Mode= 1;
	    //$display( $time, " New Enter  secured OTP mode  = %b",  enter_Secur_Mode );
	end
    endtask // enter_secured_otp
 
    /*----------------------------------------------------------------------*/
    /*	Description: define a exit 512 secured OTP task			    */
    /*----------------------------------------------------------------------*/
    task exit_secured_otp;
	begin
	    //$display( $time, " Enter 512 secured OTP mode  = %b",  enter_Secur_Mode );
	    Secur_Mode = 0;
	    //$display( $time,  " New Enter 512 secured OTP mode  = %b",  enter_Secur_Mode );
	end
    endtask

    /*----------------------------------------------------------------------*/
    /*	Description: Execute Reading Security Register			    */
    /*----------------------------------------------------------------------*/
    task read_secur_register;
	integer Dummy_Count;
	begin
	    Dummy_Count = 8;
	    forever @ ( negedge SCLK or posedge CS ) begin // output security register info
		if ( CS == 1 ) begin
		    disable	read_secur_register;
		end
		else  begin 
		    SO_OUT_EN = 1'b1;
		    if ( Dummy_Count ) begin
			Dummy_Count = Dummy_Count - 1;
			SIO1_Reg    <= #tCLQV_1XIO Secur_Reg[Dummy_Count];
		    end
		    else begin
			Dummy_Count = 7;
			SIO1_Reg    <= #tCLQV_1XIO Secur_Reg[Dummy_Count];
		    end		 
		end      
	    end
	end  
    endtask // read_secur_register

    /*----------------------------------------------------------------------*/
    /*	Description: Execute Write Security Register			    */
    /*----------------------------------------------------------------------*/
    task write_secur_register;
	begin
	    Status_Reg[0] = 1'b1;
	    #tWSR; 
	    Secur_Reg [1] = 1'b1;
	    Status_Reg[0] = 1'b0;
	end
    endtask // write_secur_register

    /*----------------------------------------------------------------------*/
    /*	Description: define a continuously program task			    */
    /*		     02 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task cp_program;
	integer Tmp_Int;
	begin
	    CP_Data = SI_Reg[15:0] ;
	    Tmp_Int = 0;
            forever begin
                @ ( posedge SCLK or posedge CS );
                if ( CS == 1'b1 ) begin
                    if ( Tmp_Int % 8 !== 0 ) begin
                	disable cp_program;
                    end
                    else begin
                	EN_CP_Mode = 1'b1;
                	CP_Mode   = 1'b1; 
                	Secur_Reg[4] = EN_CP_Mode;
                	Status_Reg[0] = 1'b1;
                        if ( write_protect(Address) == 1'b0) begin
                	    #tBP;
                	    if ( Secur_Mode == 1) 
                	    begin  
			        Secur_ARRAY[Address + 1]    = Secur_ARRAY[Address + 1] & CP_Data [7:0];
			        Secur_ARRAY[Address]	    = Secur_ARRAY[Address] & CP_Data [15:8];
                	    end
                	    else
                	    begin  
			        ARRAY[Address + 1]  = ARRAY[Address + 1] & CP_Data [7:0];
			        ARRAY[Address]	    = ARRAY[Address] & CP_Data [15:8];
                	    end 
                        end
                        else begin
                            #tPGM_CHK;
                            Secur_Reg[5] = 1'b1;
			    Secur_Reg[4]    = 1'b0;
			    Status_Reg[1]   = 1'b0;
			    EN_CP_Mode	= 1'b0;
                        end  
                	Status_Reg[0]= 1'b0;
                	CP_Mode  = 1'b0; 
                	if ( ((Address == Secur_TOP_Add - 1) && Secur_Mode) ||
		             (Address == TOP_Add - 1))
                	begin
                	    Secur_Reg[4]    = 1'b0;
                	    Status_Reg[1]   = 1'b0;
                	    EN_CP_Mode	= 1'b0;
                	end
                	else
                	begin	 
                	    Address = Address + 2;
                	end 
                	if ( write_protect(Address) == 1'b1 ) 
                	begin
			    Secur_Reg[4]    = 1'b0;
			    Status_Reg[1]   = 1'b0;
			    EN_CP_Mode	= 1'b0;
			end
                    end
                    disable cp_program;
                end
                else begin  // count how many Bits been shifted
                    Tmp_Int = Tmp_Int + 1;
                end
            end  // end forever
	end
    endtask // cp_program
 
    /*----------------------------------------------------------------------*/
    /*	Description: define a ESRY task					    */
    /*----------------------------------------------------------------------*/
    task read_ryby;
	begin
	    //$display( $time, " Enter CP ESRY mode  = %b",  CP_ESRY_Mode );
	    CP_ESRY_Mode= 1;
	    //$display( $time, " New  Enter CP ESRY mode  = %b",  CP_ESRY_Mode );
	 end
    endtask // read_ryby
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a DSRY	      task			    */
    /*----------------------------------------------------------------------*/
    task disread_ryby;
	begin
	    //$display( $time, " Enter CP ESRY mode  = %b",  CP_ESRY_Mode );
	    CP_ESRY_Mode = 0;
	    //$display( $time,  " New	Enter CP ESRY mode  = %b",  CP_ESRY_Mode );
	end
    endtask // disread_ryby

    /*----------------------------------------------------------------------*/
    /*	Description: Execute 2X IO Read Mode				    */
    /*----------------------------------------------------------------------*/
    task read_2xio;
	reg  [7:0]  OUT_Buf;
	integer     Dummy_Count;
	begin
	    Dummy_Count=4;
	    SI_IN_EN = 1'b1;
	    SO_IN_EN = 1'b1;
	    SI_OUT_EN = 1'b0;
	    SO_OUT_EN = 1'b0;
	    dummy_cycle(12);
	    dummy_cycle(4);
	    read_array(Address, OUT_Buf);
            
	    forever @ ( negedge SCLK or  posedge CS ) begin
	        if ( CS == 1'b1 ) begin
		    disable read_2xio;
	        end
	        else begin
		    SO_OUT_EN	= 1'b1;
		    SI_OUT_EN	= 1'b1;
		    SI_IN_EN	= 1'b0;
		    SO_IN_EN	= 1'b0;
		    if ( Dummy_Count ) begin
			{SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV_2XIO {OUT_Buf, OUT_Buf[1:0]};
			Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
	    		load_address(Address);
	    		read_array(Address, OUT_Buf);
	    		{SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV_2XIO {OUT_Buf, OUT_Buf[1:0]};
	    		Dummy_Count = 3 ;
		    end
	        end
	    end//forever  
	end
    endtask // read_2xio
    /*----------------------------------------------------------------------*/
    /*	Description: Execute 4X IO Read Mode				    */
    /*----------------------------------------------------------------------*/
    task read_4xio;
	//reg [A_MSB:0] Address;
	reg [7:0]   OUT_Buf ;
	integer	    Dummy_Count;
	begin
	    Dummy_Count = 2;
	    SI_OUT_EN    = 1'b0;
	    SO_OUT_EN    = 1'b0;
	    WP_OUT_EN    = 1'b0;
	    SIO3_OUT_EN  = 1'b0;
	    SI_IN_EN	= 1'b1;
	    SO_IN_EN	= 1'b1;
	    WP_IN_EN	= 1'b1;
	    SIO3_IN_EN   = 1'b1;
	    dummy_cycle(6);
	    dummy_cycle(2);
	    #1;
	    if ( (SI_Reg[0]!= SI_Reg[4]) &&
	         (SI_Reg[1]!= SI_Reg[5]) &&
	         (SI_Reg[2]!= SI_Reg[6]) &&
	         (SI_Reg[3]!= SI_Reg[7]) ) begin
	        Set_4XIO_Enhance_Mode = 1'b1;
	    end
	    else  begin 
	        Set_4XIO_Enhance_Mode = 1'b0;
	    end
	    dummy_cycle(4);
	    read_array(Address, OUT_Buf);


	    forever @ ( negedge SCLK or  posedge CS ) begin
	        if ( CS == 1'b1 ) begin
		    disable read_4xio;
	        end
	          
	        else begin
                    SO_OUT_EN   = 1'b1;
                    SI_OUT_EN   = 1'b1;
                    WP_OUT_EN   = 1'b1;
                    SIO3_OUT_EN = 1'b1;
                    SO_IN_EN    = 1'b0;
                    SI_IN_EN    = 1'b0;
                    WP_IN_EN    = 1'b0;
                    SIO3_IN_EN  = 1'b0;
                    if ( Dummy_Count ) begin
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV_4XIO {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV_4XIO {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = 1 ;
                    end
	        end
	    end//forever  
	end
    endtask // read_4xio

    /*----------------------------------------------------------------------*/
    /*	Description: define Enhance quad byte mode			    */  
    /*----------------------------------------------------------------------*/
    task enhance_read;
	begin
	    //$display( $time, " Old Enhance quad byte mode = %b", Enhance_Mode );
	    if ( Enhance_Mode == 1'b0)
		Enhance_Mode = 1'b1;
	    //$display( $time, " New Enhance quad byte mode = %b", Enhance_Mode );
	end 
    endtask // enhance_read

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast DDR read data task			    */
    /*		     0D AD1 AD2 AD3 X					    */
    /*----------------------------------------------------------------------*/
    task ddrread_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	begin
	    Dummy_Count = 8;
	    dummy_cycle(12);
	    dummy_cycle(6);
	    read_array(Address, OUT_Buf);
	    
	    forever begin
		@ ( SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable ddrread_1xio;
		end 
		else begin 
		    SO_OUT_EN = 1'b1;
		    if ( Dummy_Count ) begin
			{SIO1_Reg, OUT_Buf} <= #tCLQV2 {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
			load_address(Address);
			read_array(Address, OUT_Buf);
			{SIO1_Reg, OUT_Buf} <= #tCLQV2 {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = 7 ;
		    end
		end    
	    end  // end forever
	end   
    endtask // ddrread_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: Execute DDR 2X IO Read Mode				    */
    /*----------------------------------------------------------------------*/
    task ddrread_2xio;
	reg  [7:0]  OUT_Buf;
	integer     Dummy_Count;
	begin
	    Dummy_Count=4;
	    SI_IN_EN = 1'b1;
	    SO_IN_EN = 1'b1;
	    SI_OUT_EN = 1'b0;
	    SO_OUT_EN = 1'b0;
	    dummy_cycle(6);
	    dummy_cycle(6);

	    read_array(Address, OUT_Buf);
            
	    forever @ ( SCLK or  posedge CS ) begin
	        if ( CS == 1'b1 ) begin
		    disable ddrread_2xio;
	        end
	        else begin
		    SO_OUT_EN	= 1'b1;
		    SI_OUT_EN	= 1'b1;
		    SI_IN_EN	= 1'b0;
		    SO_IN_EN	= 1'b0;
		    if ( Dummy_Count ) begin
			{SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV2 {OUT_Buf, OUT_Buf[1:0]};
			Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
	    		load_address(Address);
	    		read_array(Address, OUT_Buf);
	    		{SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV2 {OUT_Buf, OUT_Buf[1:0]};
	    		Dummy_Count = 3 ;
		    end
	        end
	    end//forever  
	end
    endtask // ddrread_2xio

    /*----------------------------------------------------------------------*/
    /*	Description: Execute DDR 4X IO Read Mode				    */
    /*----------------------------------------------------------------------*/
    task ddrread_4xio;
	//reg [A_MSB:0] Address;
	reg [7:0]   OUT_Buf ;
	integer	    Dummy_Count;
	begin
	    Dummy_Count = 2;
	    SI_OUT_EN    = 1'b0;
	    SO_OUT_EN    = 1'b0;
	    WP_OUT_EN    = 1'b0;
	    SIO3_OUT_EN  = 1'b0;
	    SI_IN_EN	= 1'b1;
	    SO_IN_EN	= 1'b1;
	    WP_IN_EN	= 1'b1;
	    SIO3_IN_EN   = 1'b1;
	    dummy_cycle(3);
	    dummy_cycle(1);
	    @ (negedge SCLK );
	    #1;
	    if ( (SI_Reg[0]!= SI_Reg[4]) &&
	         (SI_Reg[1]!= SI_Reg[5]) &&
	         (SI_Reg[2]!= SI_Reg[6]) &&
	         (SI_Reg[3]!= SI_Reg[7]) ) begin
	        Set_4XIO_DDR_Enhance_Mode = 1'b1;
	    end
	    else  begin 
	        Set_4XIO_DDR_Enhance_Mode = 1'b0;
	    end
            dummy_cycle(7);
	    
	    read_array(Address, OUT_Buf);

	    forever @ ( SCLK or  posedge CS ) begin
	        if ( CS == 1'b1 ) begin
		    disable ddrread_4xio;
	        end
	        else begin
                    SO_OUT_EN   = 1'b1;
                    SI_OUT_EN   = 1'b1;
                    WP_OUT_EN   = 1'b1;
                    SIO3_OUT_EN = 1'b1;
                    SO_IN_EN    = 1'b0;
                    SI_IN_EN    = 1'b0;
                    WP_IN_EN    = 1'b0;
                    SIO3_IN_EN  = 1'b0;
                    if ( Dummy_Count ) begin
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV2 {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV2 {OUT_Buf, OUT_Buf[3:0]};
                        Dummy_Count = 1 ;
                    end
	        end
	    end//forever  
	end
    endtask // ddrread_4xio

    /*----------------------------------------------------------------------*/
    /*	Description: Execute Write protection select			    */
    /*----------------------------------------------------------------------*/
    task write_protection_select;
	begin
	    Status_Reg[0] = 1'b1;
	    #tWPS; 
	    Secur_Reg [7] = 1'b1;
	    Status_Reg[0] = 1'b0;
	    Status_Reg[7] = 1'b0;
	    Status_Reg[5:2] = 4'b0;
	end
    endtask // write_protection_select

    /*----------------------------------------------------------------------*/
    /*	Description: define a block erase task				    */
    /*		     52 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task block_erase_32k;
	reg [Block_MSB:0] Block; 
	integer i;
	begin
	    Block	=  Address[A_MSB:15];
	    Start_Add	= (Address[A_MSB:15]<<15) + 16'h0;
	    End_Add	= (Address[A_MSB:15]<<15) + 16'h7fff;
	    //WIP : write in process Bit
	    Status_Reg[0] =  1'b1;
	    if ( write_protect(Address) == 1'b0 ) begin
	       #tBE32 ;
	       for( i = Start_Add; i <= End_Add; i = i + 1 )
	       begin
	           ARRAY[i] = 8'hff;
	       end
	       //WIP : write in process Bit
	       Status_Reg[0] =  1'b0;//WIP
	       //WEL : write enable latch
	       Status_Reg[1] =  1'b0;//WEL
	       BE_Mode = 1'b0;
	    end
	    else begin
	        #tERS_CHK;
                Secur_Reg[6] = 1'b1;
	        Status_Reg[0] = 1'b0;//WIP
	        Status_Reg[1] = 1'b0;//WEL
	        BE_Mode = 1'b0;
	    end 
	end
    endtask // block_erase_32k

    /*----------------------------------------------------------------------*/
    /*	Description: Execute  Single Block Lock 			    */
    /*----------------------------------------------------------------------*/
    task single_block_lock;
        begin
            Block  =  Address [A_MSB:16];
            Status_Reg[0] = 1'b1;
            #tWP_SRAM;
	    if (Block[Block_MSB:0] == 0) begin 
            	SEC_Pro_Reg_BOT[Address[15:12]] = 1'b1;
	    end
	    else if (Block[Block_MSB:0] == Block_NUM-1) begin 
            	SEC_Pro_Reg_TOP[Address[15:12]] = 1'b1;
	    end
            else 
                SEC_Pro_Reg[Block] = 1'b1;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // single_block_lock

    /*----------------------------------------------------------------------*/
    /*	Description: Execute  Single Block Unlock				    */
    /*----------------------------------------------------------------------*/
    task single_block_unlock;
        begin
            Block  =  Address [A_MSB:16];
            Status_Reg[0] = 1'b1;
            #tWP_SRAM;
	    if (Block[Block_MSB:0] == 0) begin 
            	SEC_Pro_Reg_BOT[Address[15:12]] = 1'b0;
	    end
	    else if (Block[Block_MSB:0] == Block_NUM-1) begin 
            	SEC_Pro_Reg_TOP[Address[15:12]] = 1'b0;
	    end
            else 
                SEC_Pro_Reg[Block] = 1'b0;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // single_block_unlock

    /*----------------------------------------------------------------------*/
    /*	Description: Execute  Chip Lock				    */
    /*----------------------------------------------------------------------*/
    task chip_lock;
        begin
            Status_Reg[0] = 1'b1;
            #(tWP_SRAM*Block_NUM);
            SEC_Pro_Reg   = ~1'b0;
	    SEC_Pro_Reg_BOT = ~1'b0; 
	    SEC_Pro_Reg_TOP = ~1'b0; 
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // chip_lock

    /*----------------------------------------------------------------------*/
    /*	Description: Execute Chip Block Unlock				    */
    /*----------------------------------------------------------------------*/
    task chip_unlock;
        begin
            Status_Reg[0] = 1'b1;
            #(tWP_SRAM*Block_NUM);
	    SEC_Pro_Reg   = 1'b0;
	    SEC_Pro_Reg_BOT = 1'b0; 
	    SEC_Pro_Reg_TOP = 1'b0; 
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // chip_unlock

    /*----------------------------------------------------------------------*/
    /*	Description: Execute Block Lock  Protection Read		    */
    /*----------------------------------------------------------------------*/
    task sector_protection_read;
	begin
	    dummy_cycle(24);
            #1; 
	    Block    =  Address[A_MSB:16];
	    forever begin
		@ ( negedge SCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable sector_protection_read;
		end 
		else begin 
		    SO_OUT_EN = 1'b1;
		    if (Block[Block_MSB:0] == 0) begin 
			SIO1_Reg <= #tCLQV_1XIO SEC_Pro_Reg_BOT[Address[15:12]] ;
		    end
		    else if (Block[Block_MSB:0] == Block_NUM-1 ) begin 
			SIO1_Reg <= #tCLQV_1XIO SEC_Pro_Reg_TOP[Address[15:12]] ;
		    end
		    else 
			SIO1_Reg <= #tCLQV_1XIO SEC_Pro_Reg[Block] ;
		end    
	    end  // end forever
	end   
     endtask // sector_protection_read

    /*----------------------------------------------------------------------*/
    /*	Description: define a parallel mode task                            */
    /*----------------------------------------------------------------------*/
    task parallel_mode;
	begin
	    //$display( $time, " Old Pmode Register = %b", P_Mode );
	    P_Mode = 1;
	    //$display( $time, " New Pmode Register = %b", P_Mode );
	end
    endtask // parallel_mode

    /*----------------------------------------------------------------------*/
    /*	Description: define exit parallel mode task                         */
    /*----------------------------------------------------------------------*/
    task exit_parallel_mode;
	begin
	    //$display( $time, " Old Pmode Register = %b", P_Mode );
	    P_Mode = 0;
	    //$display( $time, " New Pmode Register = %b", P_Mode );
	end
    endtask //  exit_parallel_mode

    /*----------------------------------------------------------------------*/
    /*  Description: Execute clear Security Register                        */
    /*----------------------------------------------------------------------*/
    task clr_secur_register;
        begin
            Secur_Reg [6] = 1'b0;
            Secur_Reg [5] = 1'b0;
        end
    endtask // clr_secur_register

    /*----------------------------------------------------------------------*/
    /*	Description: define read array output task	                    */
    /*----------------------------------------------------------------------*/
    task read_array;
	input [A_MSB:0] Address;
	output [7:0]    OUT_Buf;
	begin
	    if ( Secur_Mode == 1 ) begin
                OUT_Buf = Secur_ARRAY[Address];
	    end 
	    else if ( DMC_Mode == 1 ) begin
                OUT_Buf = DMC_ARRAY[Address];
	    end 
	    else begin
                OUT_Buf = ARRAY[Address] ;
	    end 
	end
    endtask //  read_array

    /*----------------------------------------------------------------------*/
    /*	Description: define read array output task	                    */
    /*----------------------------------------------------------------------*/
    task load_address;
	inout [A_MSB:0] Address;
	begin
	    if ( Secur_Mode == 1 ) begin
		Address = Address[A_MSB_OTP:0] ;
	    end 
	    else if ( DMC_Mode == 1 ) begin
		Address = Address[A_MSB_DMC:0] ;
	    end 
	end
    endtask //  load_address

    /*----------------------------------------------------------------------*/
    /*	Description: define a write_protect area function		    */
    /*	INPUT								    */
    /*	    sector : sector address					    */
    /*----------------------------------------------------------------------*/  
    function write_protect;
	input [A_MSB:0] Address;
	begin
	    //protect_define
            if( Norm_Array_Mode == 1'b1 ) begin
		Block  =  Address [A_MSB:16];
                if ( WPSEL_Mode == 1'b0 ) begin
                    if (Status_Reg[5:2] == 4'b0000) begin
                        write_protect = 1'b0;
                    end
                    else if (Status_Reg[5:2] == 4'b0001) begin
                        if (Block[Block_MSB:0] >= 254 && Block[Block_MSB:0] <= 255) begin
                        	write_protect = 1'b1;
                        end
                        else begin
                        	write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0010) begin
                        if (Block[Block_MSB:0] >= 252 && Block[Block_MSB:0] <= 255) begin
                        	write_protect = 1'b1;
                        end
                        else begin
                        	write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0011) begin
                        if (Block[Block_MSB:0] >= 248 && Block[Block_MSB:0] <= 255) begin
                        	write_protect = 1'b1;
                        end
                        else begin
                        	write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0100) begin
                        if (Block[Block_MSB:0] >= 240 && Block[Block_MSB:0] <= 255) begin
                        	write_protect = 1'b1;
                        end
                        else begin
                        	write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0101) begin
                        if (Block[Block_MSB:0] >= 224 && Block[Block_MSB:0] <= 255) begin
                        	write_protect = 1'b1;
                        end
                        else begin
                        	write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0110) begin
                        if (Block[Block_MSB:0] >= 192 && Block[Block_MSB:0] <= 255) begin
	                    write_protect = 1'b1;
	                end
	                else begin
	                    write_protect = 1'b0;
	                end
	            end
	            else if (Status_Reg[5:2] == 4'b0111) begin
	                if (Block[Block_MSB:0] >= 128 && Block[Block_MSB:0] <= 255) begin
	                	write_protect = 1'b1;
	                end
	                else begin
	                	write_protect = 1'b0;
	                end
	            end
	            else
			write_protect = 1'b1;
		end
                else begin
                    if (Block[Block_MSB:0] == 0) begin
                    	if ( SEC_Pro_Reg_BOT[Address[15:12]] == 1'b0 ) begin
			    write_protect = 1'b0;
			end
			else begin
			    write_protect = 1'b1;
			end
		    end
                    else if (Block[Block_MSB:0] == 255) begin
                    	if ( SEC_Pro_Reg_TOP[Address[15:12]] == 1'b0 ) begin
			    write_protect = 1'b0;
			end
			else begin
			    write_protect = 1'b1;
			end
		    end
                    else begin
                    	if ( SEC_Pro_Reg[Address[A_MSB:16]] == 1'b0 ) begin
			    write_protect = 1'b0;
			end
			else begin
			    write_protect = 1'b1;
			end
		    end
		    if( WP_B_INT == 1'b0 )
			write_protect = 1'b1;
		end
	    end
	    else if( Secur_Mode == 1'b1 ) begin
                if ( Secur_Reg [1] == 1'b0 && Secur_Reg [0] == 1'b0 ) begin
		    write_protect = 1'b0;
                end
	        else begin
		    write_protect = 1'b1;
		end
            end 
	    else begin
		write_protect = 1'b0;
            end 
	end
    endfunction // write_protect


// *============================================================================================== 
// * AC Timing Check Section
// *==============================================================================================
    wire SIO3_EN;
    wire WP_EN;
    wire S_Mode_Chk;
    wire [7:0] PO;
    assign SIO3_EN = !Status_Reg[6];
    assign WP_EN = (!Status_Reg[6]) && SRWD;
    assign S_Mode_Chk = (~(Read_1XIO_Chk || Read_2XIO_Chk || Read_4XIO_Chk || PP_4XIO_Chk || P_Mode_Chk)) && (CS==1'b0);
    assign PO = {SO, PO6, PO5, PO4, PO3, PO2, PO1, PO0};
    wire SI_DDREN;
    wire SO_DDREN;
    wire WP_DDREN;
    wire SIO3_DDREN;
    assign SI_DDREN   = DDR_Read_Mode_IN && SI_IN_EN;
    assign SO_DDREN   = DDR_Read_Mode_IN && SO_IN_EN;
    assign WP_DDREN   = DDR_Read_Mode_IN && WP_IN_EN;
    assign SIO3_DDREN = DDR_Read_Mode_IN && SIO3_IN_EN;

    assign  Write_SHSL = !Read_SHSL;

    wire tSCLK_Chk;
    assign tSCLK_Chk = (~(Read_1XIO_Chk || Read_2XIO_Chk || Read_4XIO_Chk || PP_4XIO_Chk)) && (CS==1'b0);

    wire P_Mode_Chk_W;
    assign P_Mode_Chk_W = P_Mode_Chk;
    wire Read_1XIO_Chk_W;
    assign Read_1XIO_Chk_W = Read_1XIO_Chk;
    wire Read_2XIO_Chk_W;
    assign Read_2XIO_Chk_W = Read_2XIO_Chk;
    wire Read_4XIO_Chk_W;
    assign Read_4XIO_Chk_W = Read_4XIO_Chk;
    wire PP_4XIO_Chk_W;
    assign PP_4XIO_Chk_W = PP_4XIO_Chk;
    wire DDR_Read_Mode_IN_W;
    assign DDR_Read_Mode_IN_W = DDR_Read_Mode_IN;
    wire Read_SHSL_W;
    assign Read_SHSL_W = Read_SHSL;
    wire tDP_Chk_W;
    assign tDP_Chk_W = tDP_Chk;
    wire tRES1_Chk_W;
    assign tRES1_Chk_W = tRES1_Chk;
    wire tRES2_Chk_W;
    assign tRES2_Chk_W = tRES2_Chk;
    wire SI_IN_EN_W;
    assign SI_IN_EN_W = SI_IN_EN;
    wire SO_IN_EN_W;
    assign SO_IN_EN_W = SO_IN_EN;
    wire WP_IN_EN_W;
    assign WP_IN_EN_W = WP_IN_EN;
    wire SIO3_IN_EN_W;
    assign SIO3_IN_EN_W = SIO3_IN_EN;
    wire P_Mode_IN_W;
    assign P_Mode_IN_W = P_Mode_IN;

    specify
    	/*----------------------------------------------------------------------*/
    	/*  Timing Check                                                        */
    	/*----------------------------------------------------------------------*/
	$period( posedge  SCLK &&& P_Mode_Chk_W, tSCLK_P  );	// SCLK _/~ ->_/~
	$period( posedge  SCLK &&& S_Mode_Chk, tSCLK_S  );	// SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_1XIO_Chk_W , tRSCLK ); // SCLK ~\_ ->~\_
	$period( posedge  SCLK &&& Read_2XIO_Chk_W , tTSCLK ); // SCLK ~\_ ->~\_
	$period( posedge  SCLK &&& Read_4XIO_Chk_W , tQSCLK ); // SCLK ~\_ ->~\_
	$period( posedge  SCLK &&& PP_4XIO_Chk_W ,   tPSCLK ); // SCLK _/~ ->_/~

	$period( posedge  SCLK &&& DDR_Read_Mode_IN_W , tDSCLK ); // SCLK ~\_ ->~\_

	$width ( posedge  SCLK &&& S_Mode_Chk, tCH_S   );	// SCLK _/~~\_
	$width ( negedge  SCLK &&& S_Mode_Chk, tCL_S   );	// SCLK ~\__/~
        $width ( posedge  SCLK &&& Read_1XIO_Chk_W, tCH_R   );    // SCLK _/~~\_
        $width ( negedge  SCLK &&& Read_1XIO_Chk_W, tCL_R   );    // SCLK ~\__/~
	$width ( posedge  SCLK &&& P_Mode_Chk_W, tCH_P   );	// SCLK _/~~\_
	$width ( negedge  SCLK &&& P_Mode_Chk_W, tCL_P   );	// SCLK ~\__/~

	$width ( posedge  CS  &&& Read_SHSL_W, tSHSL_R );	// CS _/~\_
	$width ( posedge  CS  &&& Write_SHSL, tSHSL_W );// CS _/~\_

	$width ( posedge  CS  &&& tDP_Chk_W, tDP );	// CS _/~\_
	$width ( posedge  CS  &&& tRES1_Chk_W, tRES1 );	// CS _/~\_
	$width ( posedge  CS  &&& tRES2_Chk_W, tRES2 );	// CS _/~\_

	$setup ( SI &&& ~CS, posedge SCLK &&& SI_IN_EN_W,  tDVCH_S );
	$hold  ( posedge SCLK &&& SI_IN_EN_W, SI &&& ~CS,  tCHDX_S );

	$setup ( SO &&& ~CS, posedge SCLK &&& SO_IN_EN_W,  tDVCH_S );
	$hold  ( posedge SCLK &&& SO_IN_EN_W, SO &&& ~CS,  tCHDX_S );
	$setup ( WP &&& ~CS, posedge SCLK &&& WP_IN_EN_W,  tDVCH_S );
	$hold  ( posedge SCLK &&& WP_IN_EN_W, WP &&& ~CS,  tCHDX_S );

	$setup ( SIO3 &&& ~CS, posedge SCLK &&& SIO3_IN_EN_W,  tDVCH_S );
	$hold  ( posedge SCLK &&& SIO3_IN_EN_W, SIO3 &&& ~CS,  tCHDX_S );

	$setup ( PO &&& ~CS, posedge SCLK &&& P_Mode_IN_W,  tDVCH_P );
	$hold  ( posedge SCLK &&& P_Mode_IN_W, PO &&& ~CS,  tCHDX_P );

	$setup    ( negedge CS, posedge SCLK &&& ~CS, tSLCH );
	$hold     ( posedge SCLK &&& S_Mode_Chk, posedge CS, tCHSH_S );
	$hold     ( posedge SCLK &&& P_Mode_Chk_W, posedge CS, tCHSH_P );
     
	$setup    ( posedge CS, posedge SCLK &&& CS, tSHCH );
	$hold     ( posedge SCLK &&& CS, negedge CS, tCHSL );

	$setup ( posedge WP &&& WP_EN, negedge CS,  tWHSL );
	$hold  ( posedge CS, negedge WP &&& WP_EN,  tSHWL );

	$setup ( SI &&& ~CS, negedge SCLK &&& SI_DDREN,  tDVCH_S );
	$hold  ( negedge SCLK &&& SI_DDREN, SI &&& ~CS,  tCHDX_S );

	$setup ( SO &&& ~CS, negedge SCLK &&& SO_DDREN,  tDVCH_S );
	$hold  ( negedge SCLK &&& SO_DDREN, SO &&& ~CS,  tCHDX_S );

	$setup ( WP &&& ~CS, negedge SCLK &&& WP_DDREN,  tDVCH_S );
	$hold  ( negedge SCLK &&& WP_DDREN, WP &&& ~CS,  tCHDX_S );

	$setup ( SIO3 &&& ~CS, negedge SCLK &&& SIO3_DDREN,  tDVCH_S );
	$hold  ( negedge SCLK &&& SIO3_DDREN, SIO3 &&& ~CS,  tCHDX_S );
     endspecify

    integer AC_Check_File;
    // timing check module 
    initial 
    begin 
    	AC_Check_File= $fopen ("ac_check.err" );    
    end

    time  T_CS_P , T_CS_N;
    time  T_WP_P , T_WP_N;
    time  T_SCLK_P , T_SCLK_N;
    time  T_SIO3_P , T_SIO3_N;
    time  T_SI;
    time  T_SO;
    time  T_WP;
    time  T_SIO3;                    
    time  T_PO;                    

    initial 
    begin
	T_CS_P = 0; 
	T_CS_N = 0;
	T_WP_P = 0;  
	T_WP_N = 0;
	T_SCLK_P = 0; 
	T_SCLK_N = 0;
	T_SIO3_P = 0;  
	T_SIO3_N = 0;
	T_SI = 0;
	T_SO = 0;
	T_WP = 0;
	T_SIO3 = 0;                    
	T_PO = 0;                    
    end

    always @ ( posedge SCLK ) begin
	//tSCLK
        if ( $time - T_SCLK_P < tSCLK_S && S_Mode_Chk && $time > 0 && ~CS ) 
	    $fwrite (AC_Check_File, "Clock Serial Frequence for except READ struction fSCLK =%d Mhz, fSCLK timing violation at %d \n", fSCLK_S, $time );
	//tSCLK Parallel Mode
        if ( $time - T_SCLK_P < tSCLK_P && P_Mode_Chk && $time > 0 && ~CS ) 
	    $fwrite (AC_Check_File, "Clock Parallel Frequence for except READ struction fSCLK =%d Mhz, fSCLK timing violation at %d \n", fSCLK_P, $time );


	//fRSCLK
        if ( $time - T_SCLK_P < tRSCLK && Read_1XIO_Chk && $time > 0 && ~CS )
	    $fwrite (AC_Check_File, "Clock Frequence for READ instruction fRSCLK =%d Mhz, fRSCLK timing violation at %d \n", fRSCLK, $time );
	//fTSCLK
        if ( $time - T_SCLK_P < tTSCLK && Read_2XIO_Chk && $time > 0 && ~CS )
	    $fwrite (AC_Check_File, "Clock Frequence for 2XI/O instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK, $time );
	//fQSCLK
        if ( $time - T_SCLK_P < tQSCLK && Read_4XIO_Chk && $time > 0 && ~CS )
	    $fwrite (AC_Check_File, "Clock Frequence for 4XI/O instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK, $time );

	//fPSCLK
        if ( $time - T_SCLK_P < tPSCLK && PP_4XIO_Chk && $time > 0 && ~CS )
	    $fwrite (AC_Check_File, "Clock Frequence for 4XI/O PP Operation fPSCLK =%d Mhz, fPSCLK timing violation at %d \n", fPSCLK, $time );

	//fDSCLK
        if ( $time - T_SCLK_P < tDSCLK && DDR_Read_Mode_IN && $time > 0 && ~CS )
	    $fwrite (AC_Check_File, "Clock Frequence for DDR read instruction fDSCLK =%d Mhz, fDSCLK timing violation at %d \n", fDSCLK, $time );
        T_SCLK_P = $time; 
        #0;  
	//tDVCH
        if ( T_SCLK_P - T_SI < tDVCH_S && SI_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Data SI setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_P - T_SO < tDVCH_S && SO_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_P - T_WP < tDVCH_S && WP_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Data WP setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_P - T_SIO3 < tDVCH_S && SIO3_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Data SIO3 setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_P - T_PO < tDVCH_P && P_Mode_IN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO/PO setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_P, $time );


	//tCL
        if ( T_SCLK_P - T_SCLK_N < tCL_S && S_Mode_Chk && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Serial SCLK Low time tCL=%f ns, tCL timing violation at %d \n", tCL_S, $time );
        if ( T_SCLK_P - T_SCLK_N < tCL_R && Read_1XIO_Chk && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimun Serial SCLK Low time tCL=%f ns, tCL timing violation at %d \n", tCL_R, $time );
        if ( T_SCLK_P - T_SCLK_N < tCL_P && P_Mode_Chk && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun Parallel SCLK Low time tCL=%f ns, tCL timing violation at %d \n", tCL_P, $time );
        #0;
	// tSLCH
        if ( T_SCLK_P - T_CS_N < tSLCH  && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun CS# active setup time tSLCH=%d ns, tSLCH timing violation at %d \n", tSLCH, $time );

	// tSHCH
        if ( T_SCLK_P - T_CS_P < tSHCH  && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimun CS# not active setup time tSHCH=%d ns, tSHCH timing violation at %d \n", tSHCH, $time );
    end

    always @ ( negedge SCLK ) begin
        T_SCLK_N = $time;
        #0; 
	//tCH
        if ( T_SCLK_N - T_SCLK_P < tCH_S && S_Mode_Chk && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun Serial SCLK High time tCH=%f ns, tCH timing violation at %d \n", tCH_S, $time );
        if ( T_SCLK_N - T_SCLK_P < tCH_R && Read_1XIO_Chk && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimun Serial SCLK High time tCH=%f ns, tCH timing violation at %d \n", tCH_R, $time );

        if ( T_SCLK_N - T_SCLK_P < tCH_P && P_Mode_Chk && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun Serial SCLK High time tCH=%f ns, tCH timing violation at %d \n", tCH_P, $time );
	
	//tDVCH
        if ( T_SCLK_N - T_SI < tDVCH_S && SI_DDREN && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun Data SI setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_N - T_SO < tDVCH_S && SO_DDREN && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_N - T_WP < tDVCH_S && WP_DDREN && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun Data WP setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
        if ( T_SCLK_N - T_SIO3 < tDVCH_S && SIO3_DDREN && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun Data SIO3 setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH_S, $time );
    end
   
    always @ ( SI ) begin
        T_SI = $time; 
        #0;  
	//tCHDX
	if ( T_SI - T_SCLK_P < tCHDX_S && SI_IN_EN && T_SI > 0 )
	    $fwrite (AC_Check_File, "minimun Data SI hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
	if ( T_SI - T_SCLK_N < tCHDX_S && SI_DDREN && T_SI > 0 )
	    $fwrite (AC_Check_File, "minimun Data SI hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
    end

    always @ ( SO ) begin
        T_SO = $time; 
        #0;  
	//tCHDX
	if ( T_SO - T_SCLK_P < tCHDX_S && SO_IN_EN && T_SO > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
	if ( T_SO - T_SCLK_N < tCHDX_S && SO_DDREN && T_SO > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
    end

    always @ ( WP ) begin
        T_WP = $time; 
        #0;  
	//tCHDX
	if ( T_WP - T_SCLK_P < tCHDX_S && WP_IN_EN && T_WP > 0 )
	    $fwrite (AC_Check_File, "minimun Data WP hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
	if ( T_WP - T_SCLK_N < tCHDX_S && WP_DDREN && T_WP > 0 )
	    $fwrite (AC_Check_File, "minimun Data WP hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
    end

    always @ ( SIO3 ) begin
        T_SIO3 = $time; 
        #0;  
	//tCHDX
       if ( T_SIO3 - T_SCLK_P < tCHDX_S && SIO3_IN_EN && T_SIO3 > 0 )
	    $fwrite (AC_Check_File, "minimun Data SIO3 hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
       if ( T_SIO3 - T_SCLK_N < tCHDX_S && SIO3_DDREN && T_SIO3 > 0 )
	    $fwrite (AC_Check_File, "minimun Data SIO3 hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_S, $time );
    end


    always @ ( PO ) begin
        T_PO = $time; 
        #0;  
	//tCHDX
	if ( T_PO - T_SCLK_P < tCHDX_P && P_Mode_IN && T_PO > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO/PO hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX_P, $time );
    end

 
    always @ ( posedge CS ) begin
        T_CS_P = $time;
        #0;  
	// tCHSH 
        if ( T_CS_P - T_SCLK_P < tCHSH_S  && (~P_Mode_Chk) && T_CS_P > 0 )
	    $fwrite (AC_Check_File, "minimun Serial CS# active hold time tCHSH=%d ns, tCHSH timing violation at %d \n", tCHSH_S, $time );
       if ( T_CS_P - T_SCLK_P < tCHSH_P  && P_Mode_Chk && T_CS_P > 0 )
	    $fwrite (AC_Check_File, "minimun Parallel CS# active hold time tCHSH=%d ns, tCHSH timing violation at %d \n", tCHSH_P, $time );

    end


    always @ ( negedge CS ) begin
        T_CS_N = $time;
        #0;
	//tCHSL
        if ( T_CS_N - T_SCLK_P < tCHSL  && T_CS_N > 0 )
	    $fwrite (AC_Check_File, "minimun CS# not active hold time tCHSL=%d ns, tCHSL timing violation at %d \n", tCHSL, $time );
	//tSHSL
        if ( T_CS_N - T_CS_P < tSHSL_R && T_CS_N > 0 && Read_SHSL)
            $fwrite (AC_Check_File, "minimun CS# deslect  time tSHSL_R=%d ns, tSHSL timing violation at %d \n", tSHSL_R, $time );
        if ( T_CS_N - T_CS_P < tSHSL_W && T_CS_N > 0 && Write_SHSL)
            $fwrite (AC_Check_File, "minimun CS# deslect  time tSHSL_W=%d ns, tSHSL timing violation at %d \n", tSHSL_W, $time );

	//tWHSL
        if ( T_CS_N - T_WP_P < tWHSL && WP_EN  && T_CS_N > 0 )
	    $fwrite (AC_Check_File, "minimun WP setup  time tWHSL=%d ns, tWHSL timing violation at %d \n", tWHSL, $time );

	//tDP
        if ( T_CS_N - T_CS_P < tDP && T_CS_N > 0 && tDP_Chk)
            $fwrite (AC_Check_File, "when transite from Standby Mode to Deep-Power Mode to Deep-Power Mode, CS# must remain high for at least tDP =%d ns, tDP timing violation at %d \n", tDP, $time );

	//tRES1/2
        if ( T_CS_N - T_CS_P < tRES1 && T_CS_N > 0 && tRES1_Chk)
            $fwrite (AC_Check_File, "when transite from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES1 =%d ns, tRES1 timing violation at %d \n", tRES1, $time );
        if ( T_CS_N - T_CS_P < tRES2 && T_CS_N > 0 && tRES2_Chk)
            $fwrite (AC_Check_File, "when transite from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES2 =%d ns, tRES2 timing violation at %d \n", tRES2, $time );
    end

    always @ ( posedge WP ) begin
        T_WP_P = $time;
        #0;  
    end

    always @ ( negedge WP ) begin
        T_WP_N = $time;
        #0;
	//tSHWL
        if ( ((T_WP_N - T_CS_P < tSHWL) || ~CS) && WP_EN && T_WP_N > 0 )
	    $fwrite (AC_Check_File, "minimun WP hold time tSHWL=%d ns, tSHWL timing violation at %d \n", tSHWL, $time );
    end

endmodule




