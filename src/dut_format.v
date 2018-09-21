//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		IK
// Create Date:   11 June 2013
//////////////////////////////////////////////////////////////////////////////////
module dut_format #
   (
    parameter ADC_MAX_DATA_SIZE = 16,
    parameter BRAM_WORD_NUM     = 16,
    parameter SRAM_WORD_NUM     = 4
   )
   (
   //============================================= 
   // Data, Clock and Control Inputs    
   //============================================= 

   // Input data
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_a1, // Channel A1
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_c1, // Channel B1
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_e1, // Channel C1
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_g1, // Channel D1
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_a2, // Channel A2
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_c2, // Channel B2
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_e2, // Channel C2
   input  [ADC_MAX_DATA_SIZE-1:0]                   i_dut_format_data_g2, // Channel D2
   
   // Input data clock
   input                                            i_dut_format_clk,

   // Active low, master reset from FIFO5 USB controller
   input                                            i_dut_format_reset_n,

   // Data capture mode select
   input  [2:0]                                     i_dut_format_capture_mode,
   
   // 2 lane mode enable
   input                                            i_dut_format_two_lane_en,

   // Debug ramp enable
   input                                            i_dut_format_ramp_en,
        
   // Channel select for single channel capture mode
   input  [2:0]                                     i_dut_format_wr_chan_sel_first,
   
   // System ready signal, MMCM is locked and settled
   input                                            i_dut_format_system_rdy,
   
   //============================================= 
   // Data Outputs    
   //============================================= 
   
   // Data enable signal for block RAM
   output                                           o_dut_format_bram_data_en,
  
   // Data outputs for block RAM
   output     [ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:0] o_dut_format_bram_data_out,

   // Data enable signal for SRAM
   output                                           o_dut_format_sram_data_en,
  
   // Data outputs for SRAM
   output     [ADC_MAX_DATA_SIZE*SRAM_WORD_NUM-1:0] o_dut_format_sram_data_out
      
   );

   //==========================================================================
   // REGS & WIRES
   //==========================================================================
   reg                                              dut_format_bram_data_en;
   reg                                              dut_format_sram_data_en;
   reg  [3:0]                                       dut_format_en_count;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_a1;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_c1;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_e1;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_g1;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_a2;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_c2;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_e2;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_data_g2;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_ramp_up;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_ramp_dn;
   reg  [ADC_MAX_DATA_SIZE-1:0]                     dut_format_wr_chan8_first;
   reg  [ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:0]       dut_format_wr_first8_pipe;
   reg  [ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:0]       dut_format_wr_octal_pipe;
   reg  [ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:0]       dut_format_bram_data_out;
   reg  [ADC_MAX_DATA_SIZE*SRAM_WORD_NUM-1:0]       dut_format_sram_data_out;
   
   //==========================================================================
   // ASSIGNMENTS
   //==========================================================================
   
   
   //==========================================================================
   // Keep track of enable count
   //==========================================================================
   always @(posedge i_dut_format_clk or negedge i_dut_format_reset_n)
      if(i_dut_format_reset_n == 1'b0)
         dut_format_en_count <= 4'b0;
      else if(i_dut_format_system_rdy == 1'b1)
         dut_format_en_count <= dut_format_en_count + 1;

   //==========================================================================
   // Generate debug ramp
   //==========================================================================
   always @(posedge i_dut_format_clk or negedge i_dut_format_reset_n)
      if(i_dut_format_reset_n == 1'b0)
         begin
            dut_format_ramp_up <= {ADC_MAX_DATA_SIZE{1'b0}};
            dut_format_ramp_dn <= {ADC_MAX_DATA_SIZE{1'b1}};
         end
      else if(i_dut_format_system_rdy == 1'b1)
         begin
            dut_format_ramp_up <= dut_format_ramp_up + 1;
            dut_format_ramp_dn <= dut_format_ramp_dn - 1;
         end

   //==========================================================================
   // Select data or debug ramp
   //==========================================================================
   always @(posedge i_dut_format_clk)
      if(i_dut_format_ramp_en == 1'b1)
         begin
            dut_format_data_a1 <= dut_format_ramp_up;
            dut_format_data_c1 <= dut_format_ramp_up;
            dut_format_data_e1 <= dut_format_ramp_up;
            dut_format_data_g1 <= dut_format_ramp_up;
            dut_format_data_a2 <= dut_format_ramp_up;
            dut_format_data_c2 <= dut_format_ramp_up;
            dut_format_data_e2 <= dut_format_ramp_up;
            dut_format_data_g2 <= dut_format_ramp_up;
         end
      else
         begin
            dut_format_data_a1 <= i_dut_format_data_a1;
            dut_format_data_c1 <= i_dut_format_data_c1;
            dut_format_data_e1 <= i_dut_format_data_e1;
            dut_format_data_g1 <= i_dut_format_data_g1;
            dut_format_data_a2 <= i_dut_format_data_a2;
            dut_format_data_c2 <= i_dut_format_data_c2;
            dut_format_data_e2 <= i_dut_format_data_e2;
            dut_format_data_g2 <= i_dut_format_data_g2;
         end         
      
   //==========================================================================
   // Select channel for single capture mode
   // when in dual-lane, 8-channel mode
   //==========================================================================  
   always @(posedge i_dut_format_clk)
      case(i_dut_format_wr_chan_sel_first[2:0])
         3'b000:   dut_format_wr_chan8_first <= dut_format_data_a1;
         3'b001:   dut_format_wr_chan8_first <= dut_format_data_c1;
         3'b010:   dut_format_wr_chan8_first <= dut_format_data_e1;
         3'b011:   dut_format_wr_chan8_first <= dut_format_data_g1;
         3'b100:   dut_format_wr_chan8_first <= dut_format_data_a2;
         3'b101:   dut_format_wr_chan8_first <= dut_format_data_c2;
         3'b110:   dut_format_wr_chan8_first <= dut_format_data_e2;
         3'b111:   dut_format_wr_chan8_first <= dut_format_data_g2;
         default:  dut_format_wr_chan8_first <= dut_format_data_a1;
      endcase
      
   //==========================================================================
   // Pipeline data for all capture modes
   //==========================================================================
   always @(posedge i_dut_format_clk)
      dut_format_wr_first8_pipe <= {dut_format_wr_chan8_first, dut_format_wr_first8_pipe[ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:ADC_MAX_DATA_SIZE]}; 

   always @(posedge i_dut_format_clk)
      dut_format_wr_octal_pipe <= {dut_format_data_g2, dut_format_data_e2, 
                                   dut_format_data_c2, dut_format_data_a2, 
                                   dut_format_data_g1, dut_format_data_e1, 
                                   dut_format_data_c1, dut_format_data_a1, 
                                   dut_format_wr_octal_pipe[ADC_MAX_DATA_SIZE*BRAM_WORD_NUM-1:ADC_MAX_DATA_SIZE*8]}; 

   //==========================================================================
   // Generate block RAM output enable signal 
   //==========================================================================
   always @(posedge i_dut_format_clk or negedge i_dut_format_reset_n)
      if(i_dut_format_reset_n == 1'b0)
         dut_format_bram_data_en <= 1'b0;
      else if((i_dut_format_system_rdy == 1'b1) && (i_dut_format_capture_mode == 3'b000))
         dut_format_bram_data_en <= (dut_format_en_count[3:0] == 4'b1111);
      else if((i_dut_format_system_rdy == 1'b1) && (i_dut_format_capture_mode == 3'b011))
         dut_format_bram_data_en <= (dut_format_en_count[0]   == 1'b1); 

   assign o_dut_format_bram_data_en = dut_format_bram_data_en;

   //==========================================================================
   // Register block RAM output data
   //
   // BRAM_WORD_NUM = 16
   //
   // Data format for each capture mode is as follows:
   //
   // Single channel capture = f15,f14,f13,f12,f11,f10,f9,f8,f7,f6,f5,f4,f3,f2,f1,f0
   //   
   // Octal channel capture = h1, g1, g1, e1, d1, c1, b1, a1, h0, g0, f0, e0, d0, c0, b0, a0
   //    
   //==========================================================================
   always @(posedge i_dut_format_clk or negedge i_dut_format_reset_n)
      if(i_dut_format_reset_n == 1'b0)
         dut_format_bram_data_out <= {ADC_MAX_DATA_SIZE*BRAM_WORD_NUM{1'b0}};           
      else if((o_dut_format_bram_data_en == 1'b1) && (i_dut_format_two_lane_en == 1'b1) && (i_dut_format_capture_mode == 3'b000))
         dut_format_bram_data_out <= dut_format_wr_first8_pipe;                        
      else if((o_dut_format_bram_data_en == 1'b1) && (i_dut_format_two_lane_en == 1'b1) && (i_dut_format_capture_mode == 3'b011))
         dut_format_bram_data_out <= dut_format_wr_octal_pipe;
      
	assign o_dut_format_bram_data_out = dut_format_bram_data_out;

   //==========================================================================
   // Generate SRAM output enable signal 
   //==========================================================================
   always @(posedge i_dut_format_clk or negedge i_dut_format_reset_n)
      if(i_dut_format_reset_n == 1'b0)
         dut_format_sram_data_en <= 1'b0;
      else if((i_dut_format_system_rdy == 1'b1) && (i_dut_format_capture_mode == 3'b000))
         dut_format_sram_data_en <= (dut_format_en_count[1:0] == 2'b11);
      else if((i_dut_format_system_rdy == 1'b1) && (i_dut_format_capture_mode == 3'b001))
         dut_format_sram_data_en <= (dut_format_en_count[0] == 1'b1);

   assign o_dut_format_sram_data_en = dut_format_sram_data_en;

   //==========================================================================
   // Register SRAM output data
   //
   // SRAM_WORD_NUM = 4
   //
   // Data format for each capture mode is as follows:
   //
   // Single channel capture = f3,f2,f1,f0
   //
   // Dual channel capture = s1, f1, s0, f0  (f = first channel, s = second channel)
   //
   //==========================================================================
   always @(posedge i_dut_format_clk)
      if((o_dut_format_sram_data_en == 1'b1) && (i_dut_format_capture_mode == 3'b000))
          case(dut_format_en_count[3:2])
             2'b01:   dut_format_sram_data_out <= dut_format_bram_data_out[ 63:  0];
             2'b10:   dut_format_sram_data_out <= dut_format_bram_data_out[127: 64];
             2'b11:   dut_format_sram_data_out <= dut_format_bram_data_out[191:128];
             2'b00:   dut_format_sram_data_out <= dut_format_bram_data_out[255:192];
             default: dut_format_sram_data_out <= {ADC_MAX_DATA_SIZE*SRAM_WORD_NUM{1'b0}};
          endcase
       else if((o_dut_format_sram_data_en == 1'b1) && (i_dut_format_capture_mode == 3'b001))
          case(dut_format_en_count[2:1])
             2'b00:   dut_format_sram_data_out <= dut_format_bram_data_out[ 63:  0];
             2'b01:   dut_format_sram_data_out <= dut_format_bram_data_out[127: 64];
             2'b10:   dut_format_sram_data_out <= dut_format_bram_data_out[191:128];
             2'b11:   dut_format_sram_data_out <= dut_format_bram_data_out[255:192];
             default: dut_format_sram_data_out <= {ADC_MAX_DATA_SIZE*SRAM_WORD_NUM{1'b0}};
          endcase
         
   assign o_dut_format_sram_data_out = dut_format_sram_data_out;

endmodule
