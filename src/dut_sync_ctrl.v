//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   02-09-2012 
//////////////////////////////////////////////////////////////////////////////////
module dut_sync_ctrl # 
   (
   parameter R4_MAX            = 330000000,  // Maximum frequency of range 4
   parameter R3_MAX            = 155000000,  // Maximum frequency of range 3
   parameter R2_MAX            =  70000000,  // Maximum frequency of range 2
   parameter R1_MAX            =  35000000,   // Maximum frequency of range 1
   parameter CLKFBOUT_MULT_F   =        30,
   parameter DIVCLK_DIVIDE     =        15,
   parameter CLKOUT1_DIVIDE    =         2,
   parameter CLKOUT1_PHASE     =         0,
   parameter CLKOUT2_DIVIDE    =         2,
   parameter CLKOUT2_PHASE     =         0,
   parameter CLKOUT3_DIVIDE    =         2,
   parameter CLKOUT3_PHASE     =         0,
   parameter CLKOUT4_DIVIDE    =         2,
   parameter CLKOUT4_PHASE     =         0,
   parameter S1_CLKFBOUT_MULT  =        30,
   parameter S1_DIVCLK_DIVIDE  =        15,
   parameter S1_CLKOUT1_DIVIDE =         2,
   parameter S1_CLKOUT1_PHASE  =         0,
   parameter S1_CLKOUT2_DIVIDE =         2,
   parameter S1_CLKOUT2_PHASE  =         0,
   parameter S1_CLKOUT3_DIVIDE =         2,
   parameter S1_CLKOUT3_PHASE  =         0,
   parameter S1_CLKOUT4_DIVIDE =         2,
   parameter S1_CLKOUT4_PHASE  =         0,
   parameter S2_CLKFBOUT_MULT  =        30,
   parameter S2_DIVCLK_DIVIDE  =        15,
   parameter S2_CLKOUT1_DIVIDE =         2,
   parameter S2_CLKOUT1_PHASE  =         0,
   parameter S2_CLKOUT2_DIVIDE =         2,
   parameter S2_CLKOUT2_PHASE  =         0,
   parameter S2_CLKOUT3_DIVIDE =         2,
   parameter S2_CLKOUT3_PHASE  =         0,
   parameter S2_CLKOUT4_DIVIDE =         2,
   parameter S2_CLKOUT4_PHASE  =         0,
   parameter S3_CLKFBOUT_MULT  =        30,
   parameter S3_DIVCLK_DIVIDE  =        15,
   parameter S3_CLKOUT1_DIVIDE =         2,
   parameter S3_CLKOUT1_PHASE  =         0,
   parameter S3_CLKOUT2_DIVIDE =         2,
   parameter S3_CLKOUT2_PHASE  =         0,
   parameter S3_CLKOUT3_DIVIDE =         2,
   parameter S3_CLKOUT3_PHASE  =         0,
   parameter S3_CLKOUT4_DIVIDE =         2,
   parameter S3_CLKOUT4_PHASE  =         0,
   parameter S4_CLKFBOUT_MULT  =        30,
   parameter S4_DIVCLK_DIVIDE  =        15,
   parameter S4_CLKOUT1_DIVIDE =         2,
   parameter S4_CLKOUT1_PHASE  =         0,
   parameter S4_CLKOUT2_DIVIDE =         2,
   parameter S4_CLKOUT2_PHASE  =         0,
   parameter S4_CLKOUT3_DIVIDE =         2,
   parameter S4_CLKOUT3_PHASE  =         0,
   parameter S4_CLKOUT4_DIVIDE =         2,
   parameter S4_CLKOUT4_PHASE  =         0,
   parameter S5_CLKFBOUT_MULT  =        30,
   parameter S5_DIVCLK_DIVIDE  =        15,
   parameter S5_CLKOUT1_DIVIDE =         2,
   parameter S5_CLKOUT1_PHASE  =         0,
   parameter S5_CLKOUT2_DIVIDE =         2,
   parameter S5_CLKOUT2_PHASE  =         0,
   parameter S5_CLKOUT3_DIVIDE =         2,
   parameter S5_CLKOUT3_PHASE  =         0,
   parameter S5_CLKOUT4_DIVIDE =         2,
   parameter S5_CLKOUT4_PHASE  =         0
    )
   (
   output        dut_sync,
   output        dut_sync_rdy,
   input         user_reset_n,
   input         drp_ref_clk,
   input         sync_en,
   input         sync_mode,
   input  [2:0]  sync_phase,
   input         clk_in_p,
   input         clk_in_n
   );

   //==========================================================================
   // Wire and register declarations
   //==========================================================================
   reg                               dut_sync_reg0;
   reg                               dut_sync_reg45;
   reg                               dut_sync_reg90;
   reg                               dut_sync_reg135;
   reg                               dut_sync_reg180;
   reg                               dut_sync_reg225;
   reg                               dut_sync_reg270;
   reg                               dut_sync_reg315;
   reg                               dut_sync_rdy_reg;
   reg  [1:0]                        dut_sync_cnt0;
   reg  [1:0]                        dut_sync_cnt45;
   reg  [1:0]                        dut_sync_cnt90;
   reg  [1:0]                        dut_sync_cnt135;
   reg  [1:0]                        dut_sync_cnt180;
   reg  [1:0]                        dut_sync_cnt225;
   reg  [1:0]                        dut_sync_cnt270;
   reg  [1:0]                        dut_sync_cnt315;
   reg  [7:0]                        dut_sync_rdy_cnt;
   
   wire                              sync_clk1;
   wire                              sync_clk2;
   wire                              sync_clk3;
   wire                              sync_clk4;
   wire                              sync_clk_rdy;
   wire                              clk_in_buf;
   wire [2:0]                        freq_mode;     

   //==========================================================================
   // Input clock buffer
   //==========================================================================
   IBUFGDS bufds (.I(clk_in_p), .IB(clk_in_n), .O(clk_in_buf));
   
   //==========================================================================
   // Instantiate MMCM frequency counter
   //==========================================================================
   mmcm_freq_counter # (                         // Range 5: >R4_MAX 
      .R4_MAX                         (R4_MAX),  // Range 4: <R4_MAX, >R3_MAX
      .R3_MAX                         (R3_MAX),  // Range 3: <R3_MAX, >R2_MAX
      .R2_MAX                         (R2_MAX),  // Range 2: <R2_MAX, >R1_MAX
      .R1_MAX                         (R1_MAX)   // Range 1: <R1_MAX
      ) 
      mmcm_freq_count 
     (// Outputs
      .freq_mode                      (freq_mode),
      .count_done                     (count_done),
      // Inputs
      .reset_n                        (user_reset_n),
      .dut_sync_rdy                   (1'b1),
      .drp_refclk                     (drp_ref_clk), 
      .dco_clk                        (clk_in_buf)); 

   //==========================================================================
   // Reset controller
   //==========================================================================
   drp_start_ctrl drp_start_ctrl 
     (// Outputs
      .drp_start                      (drp_start),
      // Inputs
      .reset_n                        (user_reset_n),
      .clkin                          (drp_ref_clk),
      .count_done                     (count_done));
 
   //==========================================================================
   // Instantiate MMCM with DRP controller
   // M and D parameters must be set per DUT
   //==========================================================================
   mmcm_top # (
      // Initial State
      .CLKFBOUT_MULT_F                (CLKFBOUT_MULT_F),  
      .DIVCLK_DIVIDE                  (DIVCLK_DIVIDE),
      .CLKOUT1_DIVIDE                 (CLKOUT1_DIVIDE),
      .CLKOUT1_PHASE                  (CLKOUT1_PHASE),
      .CLKOUT2_DIVIDE                 (CLKOUT2_DIVIDE),
      .CLKOUT2_PHASE                  (CLKOUT2_PHASE),
      .CLKOUT3_DIVIDE                 (CLKOUT3_DIVIDE),
      .CLKOUT3_PHASE                  (CLKOUT3_PHASE),
      .CLKOUT4_DIVIDE                 (CLKOUT4_DIVIDE),
      .CLKOUT4_PHASE                  (CLKOUT4_PHASE),
      // State 1
      .S1_CLKFBOUT_MULT               (S1_CLKFBOUT_MULT),  
      .S1_DIVCLK_DIVIDE               (S1_DIVCLK_DIVIDE),
      .S1_CLKOUT1_DIVIDE              (S1_CLKOUT1_DIVIDE),
      .S1_CLKOUT1_PHASE               (S1_CLKOUT1_PHASE),
      .S1_CLKOUT2_DIVIDE              (S1_CLKOUT2_DIVIDE),
      .S1_CLKOUT2_PHASE               (S1_CLKOUT2_PHASE),
      .S1_CLKOUT3_DIVIDE              (S1_CLKOUT3_DIVIDE),
      .S1_CLKOUT3_PHASE               (S1_CLKOUT3_PHASE),
      .S1_CLKOUT4_DIVIDE              (S1_CLKOUT4_DIVIDE),
      .S1_CLKOUT4_PHASE               (S1_CLKOUT4_PHASE),
      // State 2
      .S2_CLKFBOUT_MULT               (S2_CLKFBOUT_MULT),  
      .S2_DIVCLK_DIVIDE               (S2_DIVCLK_DIVIDE),
      .S2_CLKOUT1_DIVIDE              (S2_CLKOUT1_DIVIDE),
      .S2_CLKOUT1_PHASE               (S2_CLKOUT1_PHASE),
      .S2_CLKOUT2_DIVIDE              (S2_CLKOUT2_DIVIDE),
      .S2_CLKOUT2_PHASE               (S2_CLKOUT2_PHASE),
      .S2_CLKOUT3_DIVIDE              (S2_CLKOUT3_DIVIDE),
      .S2_CLKOUT3_PHASE               (S2_CLKOUT3_PHASE),
      .S2_CLKOUT4_DIVIDE              (S2_CLKOUT4_DIVIDE),
      .S2_CLKOUT4_PHASE               (S2_CLKOUT4_PHASE),
      // State 3
      .S3_CLKFBOUT_MULT               (S3_CLKFBOUT_MULT),  
      .S3_DIVCLK_DIVIDE               (S3_DIVCLK_DIVIDE),
      .S3_CLKOUT1_DIVIDE              (S3_CLKOUT1_DIVIDE),
      .S3_CLKOUT1_PHASE               (S3_CLKOUT1_PHASE),
      .S3_CLKOUT2_DIVIDE              (S3_CLKOUT2_DIVIDE),
      .S3_CLKOUT2_PHASE               (S3_CLKOUT2_PHASE),
      .S3_CLKOUT3_DIVIDE              (S3_CLKOUT3_DIVIDE),
      .S3_CLKOUT3_PHASE               (S3_CLKOUT3_PHASE),
      .S3_CLKOUT4_DIVIDE              (S3_CLKOUT4_DIVIDE),
      .S3_CLKOUT4_PHASE               (S3_CLKOUT4_PHASE),
      // State 4
      .S4_CLKFBOUT_MULT               (S4_CLKFBOUT_MULT),  
      .S4_DIVCLK_DIVIDE               (S4_DIVCLK_DIVIDE),
      .S4_CLKOUT1_DIVIDE              (S4_CLKOUT1_DIVIDE),
      .S4_CLKOUT1_PHASE               (S4_CLKOUT1_PHASE),
      .S4_CLKOUT2_DIVIDE              (S4_CLKOUT2_DIVIDE),
      .S4_CLKOUT2_PHASE               (S4_CLKOUT2_PHASE),
      .S4_CLKOUT3_DIVIDE              (S4_CLKOUT3_DIVIDE),
      .S4_CLKOUT3_PHASE               (S4_CLKOUT3_PHASE),
      .S4_CLKOUT4_DIVIDE              (S4_CLKOUT4_DIVIDE),
      .S4_CLKOUT4_PHASE               (S4_CLKOUT4_PHASE),
      // State 5
      .S5_CLKFBOUT_MULT               (S5_CLKFBOUT_MULT),  
      .S5_DIVCLK_DIVIDE               (S5_DIVCLK_DIVIDE),
      .S5_CLKOUT1_DIVIDE              (S5_CLKOUT1_DIVIDE),
      .S5_CLKOUT1_PHASE               (S5_CLKOUT1_PHASE),
      .S5_CLKOUT2_DIVIDE              (S5_CLKOUT2_DIVIDE),
      .S5_CLKOUT2_PHASE               (S5_CLKOUT2_PHASE),
      .S5_CLKOUT3_DIVIDE              (S5_CLKOUT3_DIVIDE),
      .S5_CLKOUT3_PHASE               (S5_CLKOUT3_PHASE),
      .S5_CLKOUT4_DIVIDE              (S5_CLKOUT4_DIVIDE),
      .S5_CLKOUT4_PHASE               (S5_CLKOUT4_PHASE)
      )
      mmcm_top
     (// Outputs
      .CLK1OUT                        (sync_clk1),
      .CLK2OUT                        (sync_clk2),
      .CLK3OUT                        (sync_clk3),
      .CLK4OUT                        (sync_clk4),
      .SRDY                           (sync_clk_rdy),  // drp_ref_clk domain, 100 MHz
      // Inputs
      .RST_N                          (user_reset_n),  
      .SSTEP                          (drp_start),     // SSTEP is the input to start a reconfiguration.  It should only be pulsed for one clock cycle.
      .STATE                          (freq_mode),     // STATE determines which state the MMCM_ADV will be reconfigured to.  
      .CLKIN                          (clk_in_buf), 
      .CLKIN_DRP                      (drp_ref_clk));  

   //==========================================================================
   // Generate SYNC pulse for each phase
   //==========================================================================

   // 0 degrees
   always @(posedge sync_clk1, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt0 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt0 != 2'b11))
         dut_sync_cnt0 <= dut_sync_cnt0 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt0 <= dut_sync_cnt0 + 1;

   always @(posedge sync_clk1, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg0 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg0 <= (dut_sync_cnt0 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg0 <= dut_sync_cnt0[0];

   // 45 degrees
   always @(posedge sync_clk2, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt45 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt45 != 2'b11))
         dut_sync_cnt45 <= dut_sync_cnt45 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt45 <= dut_sync_cnt45 + 1;

   always @(posedge sync_clk2, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg45 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg45 <= (dut_sync_cnt45 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg45 <= dut_sync_cnt45[0];

   // 90 degrees
   always @(posedge sync_clk3, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt90 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt90 != 2'b11))
         dut_sync_cnt90 <= dut_sync_cnt90 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt90 <= dut_sync_cnt90 + 1;

   always @(posedge sync_clk3, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg90 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg90 <= (dut_sync_cnt90 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg90 <= dut_sync_cnt90[0];

   // 135 degrees
   always @(posedge sync_clk4, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt135 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt135 != 2'b11))
         dut_sync_cnt135 <= dut_sync_cnt135 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt135 <= dut_sync_cnt135 + 1;

   always @(posedge sync_clk4, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg135 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg135 <= (dut_sync_cnt135 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg135 <= dut_sync_cnt135[0];

   // 180 degrees
   always @(negedge sync_clk1, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt180 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt180 != 2'b11))
         dut_sync_cnt180 <= dut_sync_cnt180 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt180 <= dut_sync_cnt180 + 1;

   always @(negedge sync_clk1, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg180 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg180 <= (dut_sync_cnt180 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg180 <= dut_sync_cnt180[0];

   // 225 degrees
   always @(negedge sync_clk2, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt225 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt225 != 2'b11))
         dut_sync_cnt225 <= dut_sync_cnt225 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt225 <= dut_sync_cnt225 + 1;

   always @(negedge sync_clk2, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg225 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg225 <= (dut_sync_cnt225 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg225 <= dut_sync_cnt225[0];

   // 270 degrees
   always @(negedge sync_clk3, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt270 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt270 != 2'b11))
         dut_sync_cnt270 <= dut_sync_cnt270 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt270 <= dut_sync_cnt270 + 1;

   always @(negedge sync_clk3, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg270 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg270 <= (dut_sync_cnt270 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg270 <= dut_sync_cnt270[0];

   // 315 degrees
   always @(negedge sync_clk4, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_cnt315 <= 2'b0;
      else if((sync_mode == 1'b0) && (sync_clk_rdy == 1'b1) && (dut_sync_cnt315 != 2'b11))
         dut_sync_cnt315 <= dut_sync_cnt315 + 1;
      else if((sync_mode == 1'b1) && (sync_clk_rdy == 1'b1))
         dut_sync_cnt315 <= dut_sync_cnt315 + 1;

   always @(negedge sync_clk4, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_reg315 <= 1'b0;
      else if((sync_en == 1'b1) && (sync_mode == 1'b0))
         dut_sync_reg315 <= (dut_sync_cnt315 == 2'b01);
      else if((sync_en == 1'b1) && (sync_mode == 1'b1))
         dut_sync_reg315 <= dut_sync_cnt315[0];

   //==========================================================================
   // Select SYNC pulse output phase
   //==========================================================================
   assign dut_sync = (sync_phase == 3'b000) ? dut_sync_reg0   :
                     (sync_phase == 3'b001) ? dut_sync_reg45  :
                     (sync_phase == 3'b010) ? dut_sync_reg90  :
                     (sync_phase == 3'b011) ? dut_sync_reg135 :
                     (sync_phase == 3'b100) ? dut_sync_reg180 :
                     (sync_phase == 3'b101) ? dut_sync_reg225 :
                     (sync_phase == 3'b110) ? dut_sync_reg270 :
                     (sync_phase == 3'b111) ? dut_sync_reg315 : 1'b0;
   
   //==========================================================================
   // Generate SYNC ready signal
   //==========================================================================
   always @(posedge drp_ref_clk, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_rdy_cnt <= 8'b0;
      else if((sync_clk_rdy == 1'b1) && (dut_sync_rdy_cnt != 8'hFF))
         dut_sync_rdy_cnt <= dut_sync_rdy_cnt + 1;
   
   always @(posedge drp_ref_clk, negedge user_reset_n)
      if(user_reset_n == 1'b0)
         dut_sync_rdy_reg <= 1'b0;
      else if(sync_en == 1'b0)
         dut_sync_rdy_reg <= 1'b1;
      else if(dut_sync_rdy_cnt == 8'hFF)
         dut_sync_rdy_reg <= 1'b1;

   assign dut_sync_rdy = dut_sync_rdy_reg;

endmodule
