//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   07 October 2015
//////////////////////////////////////////////////////////////////////////////////
module fpga_dig_top #(

   // ADC_MAX_DATA_SIZE
   // Max number of ADC bits (resolution), actual number of bits is set using SPI on some ADCs
   // Range = 8 - 16
   parameter ADC_MAX_DATA_SIZE = 16,

   // BRAM_WORD_NUM
   // Number of data words per write/read cycle
   // Range = 8 MIN ... 64 MAX
   parameter BRAM_WORD_NUM = 16,  

   // SRAM_WORD_NUM
   // Number of data words per write/read cycle
   // Range = 4
   parameter SRAM_WORD_NUM = 4
   
   )
  (
   //============================================= 
   // DUT Eval Board Connections    
   //============================================= 

   // DUT data clock output 
   input                                             lvds_dco1_p,  
   input                                             lvds_dco1_n,     

   input                                             lvds_dco2_p,  
   input                                             lvds_dco2_n,     

   // DUT frame clock output
   input                                             lvds_fco1_p,  
   input                                             lvds_fco1_n,     

   input                                             lvds_fco2_p,  
   input                                             lvds_fco2_n,     

   // Data inputs from DUT
	input                                             lvds_data_a1_p, 
	input                                             lvds_data_a1_n,
	input                                             lvds_data_a2_p, 
	input                                             lvds_data_a2_n,

	input                                             lvds_data_b1_p, 
	input                                             lvds_data_b1_n,
	input                                             lvds_data_b2_p, 
	input                                             lvds_data_b2_n,

	input                                             lvds_data_c1_p, 
	input                                             lvds_data_c1_n,
	input                                             lvds_data_c2_p, 
	input                                             lvds_data_c2_n,

	input                                             lvds_data_d1_p, 
	input                                             lvds_data_d1_n,
	input                                             lvds_data_d2_p, 
	input                                             lvds_data_d2_n,   
   
	input                                             lvds_data_e1_p, 
	input                                             lvds_data_e1_n,
	input                                             lvds_data_e2_p, 
	input                                             lvds_data_e2_n,

	input                                             lvds_data_f1_p, 
	input                                             lvds_data_f1_n,
	input                                             lvds_data_f2_p, 
	input                                             lvds_data_f2_n,

	input                                             lvds_data_g1_p, 
	input                                             lvds_data_g1_n,
	input                                             lvds_data_g2_p, 
	input                                             lvds_data_g2_n,

	input                                             lvds_data_h1_p, 
	input                                             lvds_data_h1_n,
	input                                             lvds_data_h2_p, 
	input                                             lvds_data_h2_n,   

   //============================================= 
   // DUT SPI Connections    
   //============================================= 
   inout                                             dut_spi_sdio, 
   output                                            dut_spi_clk,  
   output                                            dut_spi_csb1, 
   output                                            dut_spi_csb2, 

   //============================================= 
   // Blackfin SPI Connections    
   //============================================= 
	input				                                   bf_spi_clk,
	input				                                   bf_spi_csb,
	input				                                   bf_spi_mosi,
	output			                                   bf_spi_miso,

   //============================================= 
   // IO Bank Supply Control
   //
   // 00 = 1.2V
   // 01 = 1.8V
   // 10 = 2.5V
   // 11 = not allowed   
   //============================================= 
   
   // Bank 34
   output                                            vadj_b34_sel0,
   output                                            vadj_b34_sel1,

   // Bank 35
   output                                            vadj_b35_sel0,
   output                                            vadj_b35_sel1,
   
   // Parallel data bus A, J2
   output                                            vadj_bus_a_sel0,
   output                                            vadj_bus_a_sel1,

   // Parallel data bus B, J3
   output                                            vadj_bus_b_sel0,
   output                                            vadj_bus_b_sel1,
   
   //============================================= 
   // SRAM Control Signals    
   //============================================= 
    
   // SRAM address
   output [20:0]                                     sram_addr_a,
   output [20:0]                                     sram_addr_b,

   // SRAM K clock
   output                                            sram_k_a_p,
   output                                            sram_k_b_p,

   // SRAM K clock, out of phase
   output                                            sram_k_a_n,
   output                                            sram_k_b_n,

   // SRAM C clock
   output                                            sram_c_a_p,
   output                                            sram_c_b_p,

   // SRAM C clock, out of phase
   output                                            sram_c_a_n,
   output                                            sram_c_b_n,

   // SRAM RW control
   output                                            sram_rw_a,
   output                                            sram_rw_b,

   // SRAM DLL control
   output                                            sram_dll_off_a,
   output                                            sram_dll_off_b,

   // SRAM LOAD control
   output                                            sram_load_a,
   output                                            sram_load_b,

   // SRAM common IO data lines, SRAM A
   inout   [ADC_MAX_DATA_SIZE*(SRAM_WORD_NUM/2)-1:0] sram_data_a,

   // SRAM common IO data lines, SRAM B
   inout   [ADC_MAX_DATA_SIZE*(SRAM_WORD_NUM/2)-1:0] sram_data_b,
   
   // SRAM JTAG connections
   output                                            sram_jtag_tck,
   output                                            sram_jtag_tms,
   output                                            sram_jtag_tdi,
   input                                             sram_jtag_tdo,

   //============================================= 
   // Misc Control Signals    
   //============================================= 

   // Reference clock, 100 MHz
   input                                             hadv6_ref_clk_p,
   input                                             hadv6_ref_clk_n,

   // External data capture trigger, SMA1, J201
   input                                             ext_trig,            
    
   // System clock ready indicator, SMA2, J202
   output                                            sysclk_ready,  

   //============================================= 
   // Data Output to USB Controller    
   //============================================= 
   
   // Blackfin data clock
   input                                             bf_data_clk,

   // Blackfin async read enable signal   
   input                                             bf_are_n,

   // Blackfin async enable signal   
	input                                             bf_async_ams1,

   // Read ready signal from FPGA
   output                                            bf_read_rdy,
    
   // data output to USB
   output [15:0]                                     bf_data_out
   ); 

   //-------------------------------------------------------------------------------------------
   // Wire and register declarations
   //-------------------------------------------------------------------------------------------
   wire                                          data_clk1;
   wire                                          data_clk2;
   wire                                          data_clk1_rdy;
   wire                                          data_clk2_rdy;
   wire                                          fco_clk_rdy;
   wire                                          fco_clk1_rdy;
   wire                                          fco_clk2_rdy;
   wire                                          fco_clk;
   wire                                          fco_clk1;
   wire                                          fco_clk2;
   wire                                          clk_sel;
   wire                                          clk_pdwn;
   wire                                          debug_ramp_en;
   wire                                          ext_trig_en;
   wire                                          spi_sys_clk;
   wire                                          spi_clk_2x;
   wire                                          spi_clk_x2_sel;
   wire                                          spi_master_sel;
   wire                                          spi_mmcm_locked;
   wire                                          sram_id_rst_n;
   wire                                          master_rst_n;
   wire                                          sram_dll_off; 
   wire                                          sram_load;      
   wire                                          sram_rw;      
   wire                                          sram_k;        
   wire                                          sram_k_b;
   wire                                          two_lane_en;
   wire                                          sel_num_bits;
   wire                                          read_interleaved;
   wire                                          main_memory_bram_wr_en;
   wire                                          main_memory_sram_wr_en;
   wire [2:0]                                    capture_mode;
   wire [2:0]                                    sram_id;
   wire [3:0]                                    bram_id;
   wire [2:0]                                    wr_chan_sel_first;
   wire [4:0]                                    capture_req_exp;
   wire [15:0]                                   spi_reg_0x0100;
   wire [15:0]                                   spi_reg_0x0101;
   wire [15:0]                                   spi_reg_0x0103;
   wire [15:0]                                   spi_reg_0x0104;
   wire [15:0]                                   spi_reg_0x0106;
   wire [15:0]                                   spi_reg_0x0120;
   wire [15:0]                                   spi_reg_0x0140;
   wire [15:0]                                   spi_reg_0x0141;
   wire [15:0]                                   spi_reg_0x014a;
   wire [15:0]                                   spi_reg_0x014b;
   wire [20:0]                                   sram_addr;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_A1;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_A2;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_B1;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_B2;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_C1;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_C2;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_D1;
   wire [ADC_MAX_DATA_SIZE-1:0]                  captured_data_D2;
   wire [ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:0]    main_memory_bram_wr_data;
   wire [ADC_MAX_DATA_SIZE*SRAM_WORD_NUM-1:0]    main_memory_sram_wr_data;
  
   //-------------------------------------------------------------------------------------------
   // Revision ID: YY_MM_DD_RR, year, month, day, intraday revision number
   // ***** MUST BE SHOWN in log when design is commited to SVN
   localparam REVISION_ID = 32'h16_10_11_00;
   //-------------------------------------------------------------------------------------------

   //-------------------------------------------------------------------------------------------
   // Assignments
   //-------------------------------------------------------------------------------------------
   assign bram_id             = 4'b0011;
   assign read_interleaved    = 1'b1;
   assign sysclk_ready        = fco_clk_rdy;
	assign two_lane_en         = 1'b1;

   assign capture_mode        = spi_reg_0x0103[2:0];
   assign wr_chan_sel_first   = spi_reg_0x0104[2:0];
   assign debug_ramp_en       = spi_reg_0x0106[0];
   assign ext_trig_en         = spi_reg_0x0106[1];
   assign spi_clk_x2_sel      = spi_reg_0x0106[2];
   assign sel_num_bits        = spi_reg_0x0120[0];
   assign clk_pdwn            = spi_reg_0x0120[2];
   assign clk_sel             = spi_reg_0x0120[3];
   assign sram_id_rst_n       = ~spi_reg_0x0140[0];
   assign master_rst_n        = ~spi_reg_0x0140[1];
   assign capture_req_exp     = spi_reg_0x0141[4:0];

   assign spi_reg_0x0100      =  REVISION_ID[31:16];
   assign spi_reg_0x0101      =  REVISION_ID[15:0];
   assign spi_reg_0x014a      = {11'b0, read_interleaved, bf_read_rdy, sram_id};
   assign spi_reg_0x014b      = {12'b0, bram_id};
         
   assign vadj_b34_sel0       = 1'b0; // 2.5V
   assign vadj_b34_sel1       = 1'b1; 
   assign vadj_b35_sel0       = 1'b0; // 2.5V
   assign vadj_b35_sel1       = 1'b1; 
   assign vadj_bus_a_sel0     = 1'b0; // 2.5V
   assign vadj_bus_a_sel1     = 1'b1; 
   assign vadj_bus_b_sel0     = 1'b0; // 1.2V
   assign vadj_bus_b_sel1     = 1'b0; 

   assign sram_dll_off_a      = sram_dll_off; 
   assign sram_dll_off_b      = sram_dll_off; 
   assign sram_load_a         = sram_load; 
   assign sram_load_b         = sram_load;    
   assign sram_rw_a           = sram_rw;      
   assign sram_rw_b           = sram_rw;      
   assign sram_k_a_p          = sram_k;      
   assign sram_k_a_n          = sram_k_b;      
   assign sram_k_b_p          = sram_k;        
   assign sram_k_b_n          = sram_k_b;
   assign sram_c_a_p          = 1'b1;      
   assign sram_c_a_n          = 1'b1;      
   assign sram_c_b_p          = 1'b1;        
   assign sram_c_b_n          = 1'b1;
   assign sram_addr_a         = sram_addr;
   assign sram_addr_b         = sram_addr;

   //==========================================================================
   // Determine presence and size of SRAM
   //==========================================================================
   gsi_jtag gsi_jtag
      (// Outputs
       .o_sram_id                        (sram_id),            
       .o_busy                           (),             
       .TCK                              (sram_jtag_tck),     
       .TMS                              (sram_jtag_tms),     
       .TDI                              (sram_jtag_tdi),     
       // Inputs
       .TDO                              (sram_jtag_tdo),     
       .i_clk                            (sram_jtag_clk),     
       .i_sys_rdy                        (spi_mmcm_locked),   
       .i_resetb                         (1'b1),              
       .i_sram_id_rst_n                  (sram_id_rst_n));      
       
   //==========================================================================
   // System Clock Control
   //==========================================================================
   sys_clk_ctrl sys_clk_ctrl 
     (// Outputs
      .bf_spi_clk_out                    (bf_spi_clk_buf),
      .hadv6_ref_clk_out                 (hadv6_ref_clk), // 100 MHz clock for frequency measurement
      .bf_rd_clk_out                     (bf_rd_clk),     // 240 MHz FIFO read clock
      .spi_sys_clk_out                   (spi_sys_clk),   // 200 MHz SPI sysclk
      .spi_clk_x2_out                    (spi_clk_x2),    //  15 MHz or 60 MHz spi_x2 for DUT
      .enc_clk_x2_out                    (),              //  15 MHz not used
      .sram_jtag_clk                     (sram_jtag_clk), //  20 MHz clock for SRAM ID
      .locked                            (spi_mmcm_locked),
      // Inputs
      .hadv6_ref_clk_in_p                (hadv6_ref_clk_p),
      .hadv6_ref_clk_in_n                (hadv6_ref_clk_n),
      .spi_clk_x2_sel                    (spi_clk_x2_sel),
      .bf_spi_clk_in                     (bf_spi_clk),
      .bf_data_clk_in                    (bf_data_clk));

   //-------------------------------------------------------------------------------------------
   //-------------------------------------------------------------------------------------------
   // Instantiate SPI controller
   //
   // SPI map for register 0x0100, Revision ID of the source files
   // bit[15:8]: YY = 2-digit year
   // bit[7:0]:  MM = 2-digit month 
   //
   // SPI map for register 0x0101, Revision ID of the source files
   // bit[15:8]: DD = 2-digit day
   // bit[7:0]:  RR = intraday revision number 
   //
   // SPI map for register 0x0103, bit[2:0]
   // 000 = Single channel data capture mode, 256k BRAM plus SRAM
   // 011 = Octal channel capture mode, 32k BRAM per channel, no SRAM
   // 
   // SPI map for register 0x0104, bit[2:0]
   // bit[2:0] channel select for single capture mode
   // 000: Channel A1
   // 001: Channel C1
   // 010: Channel E1
   // 011: Channel G1
   // 100: Channel A2
   // 101: Channel C2
   // 110: Channel E2
   // 111: Channel G2
   //
   // SPI map for register 0x0106
   // bit[0]: 0 = Normal data, 1 = debug ramp enable
   // bit[1]: 0 = External trigger disabled, 1 = external trigger enabled, pulse must be wider than ADC sample period
   // bit[2]: SPI clock frequency select: 0 = 7.5 MHz, 1 = 30 MHz
   //
   // SPI map for register 0x0120
   // bit[0]: sel_num_bits,  0 = 16-bits,         1 = 12-bits
   // bit[2]: clk_pdwn,      0 = both die active,    1 = one die powered down
   // bit[3]: clk_sel,       0 = use DCO1/FCO1,      1 = DCO2/FCO2
   //
   // SPI map for register 0x0140
   // bit[0]: Self-clearing SRAM ID start
   // bit[1]: Self-clearing master reset
   //
   // SPI map for register 0x0141
   // bit[4:0]: Capture request exponent, capture size = 2^^exp, where exp = register plus 8
   //           Range = 0 to 16, for capture size of 256 to 16M
   //           Examples: 00101 = 8k, 00110 = 16k, 01000 = 64k, 01110 = 1M, etc.
   //
   // SPI map for register 0x014A - Read Only
   // bit[2:0]: SRAM ID
   //              000 =  No SRAM installed
   //              001 =  2M max capture size
   //              010 =  4M max capture size
   //              011 =  8M max capture size
   //              100 = 16M max capture size
   // bit[3]:   FIFO Read Ready flag, high when FIFO is full, remains high until all read cycles are complete
   // bit[4]:   Read Interleaved Flag, 1 = multi-channel data output is interleaved
   //
   // SPI map for register 0x014B - Read Only
   // bit[3:0]: BRAM ID, 0011 = 256k max capture size using BRAM
   //
   //-------------------------------------------------------------------------------------------
   //-------------------------------------------------------------------------------------------
   spi_fpga_top spi_fpga_top 
     (// Slave Outputs
      .spi_miso                          (bf_spi_miso),
      // Slave Inputs
      .sys_rst_n                         (spi_mmcm_locked),
      .sys_clk                           (spi_sys_clk),
      .spi_cs_n                          (bf_spi_csb),
      .spi_clk                           (bf_spi_clk_buf),
      .spi_mosi                          (bf_spi_mosi),
      // Master Outputs                                    
      .p1_spi_cs_x                       ({dut_spi_csb2, dut_spi_csb1}),  
      .p1_spi_clk                        (dut_spi_clk),
      .p1_spi_data3                      (dut_spi_sdio),	    // mosi for 4-wire, sdio for 3 wire
      // Master Inputs
      .p1_spi_x2_clk                     (spi_clk_x2),
      .p1_spi_data4                      (1'B0),             // miso for 4-wire, not used for 3 wire
      // Master Input, shared
      .p_spi_x2_rst_n                    (spi_mmcm_locked),
      // FPGA Register Outputs
      .fpga_spi_reg_0x103                (spi_reg_0x0103),   // 0x100 Generic registers
      .fpga_spi_reg_0x104                (spi_reg_0x0104),
      .fpga_spi_reg_0x106                (spi_reg_0x0106),
      .fpga_spi_reg_0x120                (spi_reg_0x0120),   // 0x120 Product specific registers
      .fpga_spi_reg_0x140                (spi_reg_0x0140),   // 0x140 Data capture control
      .fpga_spi_reg_0x141                (spi_reg_0x0141), 
      // read Register Inputs
      .fpga_spi_reg_0x100                (spi_reg_0x0100),
      .fpga_spi_reg_0x101                (spi_reg_0x0101),
      .fpga_spi_reg_0x14a                (spi_reg_0x014a),
      .fpga_spi_reg_0x14b                (spi_reg_0x014b));

   //==========================================================================
   // Data Path Clock control, serial data clock, DCO1
   //==========================================================================
   data_clock_ctrl 
    #(// Parameters
      // Data clock frequency measurement            // Range 5: >R4_MAX 
      .R4_MAX                          (350000000),  // Range 4: <R4_MAX, >R3_MAX
      .R3_MAX                          (155000000),  // Range 3: <R3_MAX, >R2_MAX
      .R2_MAX                          ( 70000000),  // Range 2: <R2_MAX, >R1_MAX
      .R1_MAX                          ( 33000000),  // Range 1: <R1_MAX
      // MMCM Initial State
      .CLKFBOUT_MULT_F                 (10),  
      .DIVCLK_DIVIDE                   (5),
      .CLKOUT1_DIVIDE                  (2),
      .CLKOUT1_PHASE                   (0), 
      // MMCM State 1 - Range 5, highest frequencies
      .S1_CLKFBOUT_MULT                (10),  
      .S1_DIVCLK_DIVIDE                (5),
      .S1_CLKOUT1_DIVIDE               (2),
      .S1_CLKOUT1_PHASE                (0), 
      // MMCM State 2 - Range 4
      .S2_CLKFBOUT_MULT                (20),  
      .S2_DIVCLK_DIVIDE                (5),
      .S2_CLKOUT1_DIVIDE               (4),
      .S2_CLKOUT1_PHASE                (-112500), 
      // MMCM State 3 - Range 3
      .S3_CLKFBOUT_MULT                (9),  
      .S3_DIVCLK_DIVIDE                (1),
      .S3_CLKOUT1_DIVIDE               (9),
      .S3_CLKOUT1_PHASE                (-112500), 
      // MMCM State 4 - Range 2
      .S4_CLKFBOUT_MULT                (20),  
      .S4_DIVCLK_DIVIDE                (1),
      .S4_CLKOUT1_DIVIDE               (20),
      .S4_CLKOUT1_PHASE                (0), 
      // MMCM State 5 - Range 1, lowest frequencies
      .S5_CLKFBOUT_MULT                (40),  
      .S5_DIVCLK_DIVIDE                (1),
      .S5_CLKOUT1_DIVIDE               (32),
      .S5_CLKOUT1_PHASE                (0)
      ) 
      data_clock_ctrl1
     (// Outputs
      .data_clk                         (data_clk1),
      .data_clk_rdy                     (data_clk1_rdy),
      // Inputs
      .user_reset_n                     (master_rst_n),
      .drp_ref_clk                      (hadv6_ref_clk),
      .dco_p                            (lvds_dco1_p),
      .dco_n                            (lvds_dco1_n));

   //==========================================================================
   // Data Path Clock control, serial data clock, DCO2
   //==========================================================================
   data_clock_ctrl 
    #(// Parameters
      // Data clock frequency measurement            // Range 5: >R4_MAX 
      .R4_MAX                          (330000000),  // Range 4: <R4_MAX, >R3_MAX
      .R3_MAX                          (155000000),  // Range 3: <R3_MAX, >R2_MAX
      .R2_MAX                          ( 70000000),  // Range 2: <R2_MAX, >R1_MAX
      .R1_MAX                          ( 33000000),  // Range 1: <R1_MAX
      // MMCM Initial State
      .CLKFBOUT_MULT_F                 (10),  
      .DIVCLK_DIVIDE                   (5),
      .CLKOUT1_DIVIDE                  (2),
      .CLKOUT1_PHASE                   (0), 
      // MMCM State 1 - Range 5, highest frequencies
      .S1_CLKFBOUT_MULT                (10),  
      .S1_DIVCLK_DIVIDE                (5),
      .S1_CLKOUT1_DIVIDE               (2),
      .S1_CLKOUT1_PHASE                (0), 
      // MMCM State 2 - Range 4
      .S2_CLKFBOUT_MULT                (20),  
      .S2_DIVCLK_DIVIDE                (5),
      .S2_CLKOUT1_DIVIDE               (4),
      .S2_CLKOUT1_PHASE                (-112500), 
      // MMCM State 3 - Range 3
      .S3_CLKFBOUT_MULT                (9),  
      .S3_DIVCLK_DIVIDE                (1),
      .S3_CLKOUT1_DIVIDE               (9),
      .S3_CLKOUT1_PHASE                (-112500), 
      // MMCM State 4 - Range 2
      .S4_CLKFBOUT_MULT                (20),  
      .S4_DIVCLK_DIVIDE                (1),
      .S4_CLKOUT1_DIVIDE               (20),
      .S4_CLKOUT1_PHASE                (0), 
      // MMCM State 5 - Range 1, lowest frequencies
      .S5_CLKFBOUT_MULT                (40),  
      .S5_DIVCLK_DIVIDE                (1),
      .S5_CLKOUT1_DIVIDE               (32),
      .S5_CLKOUT1_PHASE                (0)
      ) 
      data_clock_ctrl2
     (// Outputs
      .data_clk                         (data_clk2),
      .data_clk_rdy                     (data_clk2_rdy),
      // Inputs
      .user_reset_n                     (master_rst_n),
      .drp_ref_clk                      (hadv6_ref_clk),
      .dco_p                            (lvds_dco2_p),
      .dco_n                            (lvds_dco2_n));

   //==========================================================================
   // Deserialize and format input data, IC1
   //==========================================================================
   iser_top 
     iser_top1 
     (// Outputs
      .iser_chan_a                      (captured_data_A1),
      .iser_chan_c                      (captured_data_B1),
      .iser_chan_e                      (captured_data_C1),
      .iser_chan_g                      (captured_data_D1),
      .fco_clk                          (fco_clk1),
      .fco_clk_rdy                      (fco_clk1_rdy),
      // Inputs
      .data_clk                         (data_clk1),
      .data_clk_rdy                     (data_clk1_rdy),
      .din_rst_n                        (master_rst_n),
      .din_fco_p                        (lvds_fco1_p),
      .din_fco_n                        (lvds_fco1_n),
      .din_a_p                          (lvds_data_a1_p),
      .din_a_n                          (lvds_data_a1_n),
      .din_b_p                          (lvds_data_b1_p),
      .din_b_n                          (lvds_data_b1_n),
      .din_c_p                          (lvds_data_c1_p),
      .din_c_n                          (lvds_data_c1_n),
      .din_d_p                          (lvds_data_d1_p),
      .din_d_n                          (lvds_data_d1_n),
      .din_e_p                          (lvds_data_e1_p),
      .din_e_n                          (lvds_data_e1_n),
      .din_f_p                          (lvds_data_f1_p),
      .din_f_n                          (lvds_data_f1_n),
      .din_g_p                          (lvds_data_g1_p),
      .din_g_n                          (lvds_data_g1_n),
      .din_h_p                          (lvds_data_h1_p),
      .din_h_n                          (lvds_data_h1_n),
      .sel_2lane                        (two_lane_en),
      .sel_num_bits                     (sel_num_bits));

   //==========================================================================
   // Deserialize and format input data, IC2
   //==========================================================================
   iser_top 
     iser_top2 
     (// Outputs
      .iser_chan_a                      (captured_data_A2),
      .iser_chan_c                      (captured_data_B2),
      .iser_chan_e                      (captured_data_C2),
      .iser_chan_g                      (captured_data_D2),
      .fco_clk                          (fco_clk2),
      .fco_clk_rdy                      (fco_clk2_rdy),
      // Inputs
      .data_clk                         (data_clk2),
      .data_clk_rdy                     (data_clk2_rdy),
      .din_rst_n                        (master_rst_n),
      .din_fco_p                        (lvds_fco2_p),
      .din_fco_n                        (lvds_fco2_n),
      .din_a_p                          (lvds_data_a2_p),
      .din_a_n                          (lvds_data_a2_n),
      .din_b_p                          (lvds_data_b2_p),
      .din_b_n                          (lvds_data_b2_n),
      .din_c_p                          (lvds_data_c2_p),
      .din_c_n                          (lvds_data_c2_n),
      .din_d_p                          (lvds_data_d2_p),
      .din_d_n                          (lvds_data_d2_n),
      .din_e_p                          (lvds_data_e2_p),
      .din_e_n                          (lvds_data_e2_n),
      .din_f_p                          (lvds_data_f2_p),
      .din_f_n                          (lvds_data_f2_n),
      .din_g_p                          (lvds_data_g2_p),
      .din_g_n                          (lvds_data_g2_n),
      .din_h_p                          (lvds_data_h2_p),
      .din_h_n                          (lvds_data_h2_n),
      .sel_2lane                        (two_lane_en),
      .sel_num_bits                     (sel_num_bits));

   //==========================================================================
   // System Parallel Data Clock Selection
   //
   //==========================================================================
   par_clk_mux
     par_clk_mux
     (// Outputs
      .par_clk                         (fco_clk),
      .par_clk_rdy                     (fco_clk_rdy),
      // Inputs
      .clk_reset_n                     (master_rst_n),
      .clk_pdwn                        (clk_pdwn),
      .clk_sel                         (clk_sel),
      .clk1_in                         (fco_clk1),
      .clk2_in                         (fco_clk2),
      .clk1_rdy                        (fco_clk1_rdy),
      .clk2_rdy                        (fco_clk2_rdy));
    
   //==========================================================================
   // DUT Format Block
   //==========================================================================
   dut_format 
       #(// Parameters
         .ADC_MAX_DATA_SIZE               (ADC_MAX_DATA_SIZE),
         .BRAM_WORD_NUM                   (BRAM_WORD_NUM),
         .SRAM_WORD_NUM                   (SRAM_WORD_NUM)
         )
      dut_format
       (// Outputs
        .o_dut_format_bram_data_en       (main_memory_bram_wr_en),
        .o_dut_format_bram_data_out      (main_memory_bram_wr_data),
        .o_dut_format_sram_data_en       (main_memory_sram_wr_en),
        .o_dut_format_sram_data_out      (main_memory_sram_wr_data),
        // Inputs
        .i_dut_format_reset_n            (master_rst_n),
        .i_dut_format_capture_mode       (capture_mode),
        .i_dut_format_two_lane_en        (two_lane_en),
        .i_dut_format_ramp_en            (debug_ramp_en),
        .i_dut_format_wr_chan_sel_first  (wr_chan_sel_first),
        .i_dut_format_clk                (fco_clk),
        .i_dut_format_data_a1            (captured_data_A1),
        .i_dut_format_data_c1            (captured_data_B1),
        .i_dut_format_data_e1            (captured_data_C1),
        .i_dut_format_data_g1            (captured_data_D1),
        .i_dut_format_data_a2            (captured_data_A2),
        .i_dut_format_data_c2            (captured_data_B2),
        .i_dut_format_data_e2            (captured_data_C2),
        .i_dut_format_data_g2            (captured_data_D2),
        .i_dut_format_system_rdy         (fco_clk_rdy));
   
   //==========================================================================
   // Write To and Read From FIFO
   //==========================================================================
   main_memory_top 
      #(// Parameters
        .ADC_MAX_DATA_SIZE               (ADC_MAX_DATA_SIZE),
        .BRAM_WORD_NUM                   (BRAM_WORD_NUM),
        .SRAM_WORD_NUM                   (SRAM_WORD_NUM)
        )
      main_memory_top
       (// Outputs
        .o_main_memory_rd_ready          (bf_read_rdy),
        .o_main_memory_rd_data           (bf_data_out),
        .o_main_memory_sram_address      (sram_addr),      
        .o_main_memory_sram_k_clk        (sram_k),
        .o_main_memory_sram_k_clk_n      (sram_k_b),
        .o_main_memory_sram_r_w          (sram_rw),
        .o_main_memory_sram_dll_off      (sram_dll_off),
        .o_main_memory_sram_load         (sram_load),
        // Inouts
        .io_main_memory_sram_a_data      (sram_data_a),
        .io_main_memory_sram_b_data      (sram_data_b),
        // Inputs
        .i_main_memory_reset_n           (master_rst_n),
        .i_main_memory_capture_req_exp   (capture_req_exp),
        .i_main_memory_ext_trig          (ext_trig),
        .i_main_memory_ext_trig_en       (ext_trig_en),
        .i_main_memory_capture_mode      (capture_mode),
        .i_main_memory_wr_clk            (fco_clk),
        .i_main_memory_bram_wr_clk_en    (main_memory_bram_wr_en),
        .i_main_memory_bram_wr_data      (main_memory_bram_wr_data),
        .i_main_memory_sram_wr_clk_en    (main_memory_sram_wr_en),
        .i_main_memory_sram_wr_data      (main_memory_sram_wr_data),
        .i_main_memory_rd_are_n          (bf_are_n),
        .i_main_memory_rd_async          (bf_async_ams1),
        .i_main_memory_rd_clk            (bf_rd_clk)); 

endmodule
