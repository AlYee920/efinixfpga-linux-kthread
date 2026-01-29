////////////////////////////////////////////////////////////////////////////
//           _____
//          / _______    Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
//         / /       \
//        / /  ..    /   pcie_top.v
//       / / .'     /
//    __/ /.'      /     Description: top file for PCIe driver hardware
//   __   \       /
//  /_/ /\ \_____/ /
// ____/  \_______/
//
// *******************************
// Revisions:
// 0.0 Initial rev
//
// *******************************
module top(
//TB
input   wire        in_user,
//PLL TL0   
input   wire        axiclk,
input   wire        apbclk,

// PCIE Quad 0 - EP, PCIE Quad 2 - RC

input   wire            q0_HOT_RESET_OUT        ,
input   wire            q0_LINK_DOWN_RESET_OUT  ,
output  wire            q0_RESET_ACK            ,
input   wire            q0_RESET_REQ            ,

//AXI
output  wire            q0_USER_AXI_RESET_N     ,
//======================     Q0 AXI MASTER     ===    Q2 AXI MASTER    === ---> FPGA(AXI Slave), PCIe (AXI Master)
input   wire [63:0]     q0_TARGET_AXI_ARADDR    ,
input   wire [7:0]      q0_TARGET_AXI_ARID      ,
input   wire [7:0]      q0_TARGET_AXI_ARLEN     ,
output  wire            q0_TARGET_AXI_ARREADY   ,
input   wire [2:0]      q0_TARGET_AXI_ARSIZE    ,
input   wire [87:0]     q0_TARGET_AXI_ARUSER    ,
input   wire            q0_TARGET_AXI_ARVALID   ,
                                                 
input   wire [63:0]     q0_TARGET_AXI_AWADDR    ,
input   wire [7:0]      q0_TARGET_AXI_AWID      ,
input   wire [7:0]      q0_TARGET_AXI_AWLEN     ,
output  wire            q0_TARGET_AXI_AWREADY   ,
input   wire [2:0]      q0_TARGET_AXI_AWSIZE    ,
input   wire [87:0]     q0_TARGET_AXI_AWUSER    ,
input   wire            q0_TARGET_AXI_AWVALID   ,
                                                 
output  wire [7:0]      q0_TARGET_AXI_BID       ,
output  wire            q0_TARGET_AXI_BID_PAR   ,
input   wire            q0_TARGET_AXI_BREADY    ,
output  wire [1:0]      q0_TARGET_AXI_BRESP     ,
output  wire            q0_TARGET_AXI_BRESP_PAR ,
output  reg            q0_TARGET_AXI_BVALID    ,
                                                 
output  wire [255:0]    q0_TARGET_AXI_RDATA     ,
output  wire [31:0]     q0_TARGET_AXI_RDATA_PAR ,
output  wire [7:0]      q0_TARGET_AXI_RID       ,
output  wire            q0_TARGET_AXI_RID_PAR   ,
output  reg            q0_TARGET_AXI_RLAST     ,
input   wire            q0_TARGET_AXI_RREADY    ,
output  wire [1:0]      q0_TARGET_AXI_RRESP     ,
output  wire            q0_TARGET_AXI_RRESP_PAR ,
output  reg            q0_TARGET_AXI_RVALID    ,
                                                 
input   wire [255:0]    q0_TARGET_AXI_WDATA     ,
input   wire [31:0]     q0_TARGET_AXI_WDATA_PAR ,
input   wire            q0_TARGET_AXI_WLAST     ,
output  wire            q0_TARGET_AXI_WREADY    ,
input   wire [31:0]     q0_TARGET_AXI_WSTRB     ,
input   wire [3:0]      q0_TARGET_AXI_WSTRB_PAR ,
input   wire            q0_TARGET_AXI_WVALID    ,

 output  wire            q0_TARGET_NON_POSTED_REJ,
 
//======================     Q0 AXI SLAVE      ===    Q2 AXI SLAVE     === ---> FPGA(AXI Master), PCIe (AXI Slave)
 output  wire [63:0]     q0_MASTER_AXI_ARADDR    ,
 output  wire [7:0]      q0_MASTER_AXI_ARID      ,
 output  wire [7:0]      q0_MASTER_AXI_ARLEN     ,
 input   wire            q0_MASTER_AXI_ARREADY   ,
 output  wire [2:0]      q0_MASTER_AXI_ARSIZE    ,
 output  wire [87:0]     q0_MASTER_AXI_ARUSER    ,
 output  wire            q0_MASTER_AXI_ARVALID   ,
                                               
 output  wire [63:0]     q0_MASTER_AXI_AWADDR    ,
 output  wire [7:0]      q0_MASTER_AXI_AWID      ,
 output  wire [7:0]      q0_MASTER_AXI_AWLEN     ,
 input   wire            q0_MASTER_AXI_AWREADY   ,
 output  wire [2:0]      q0_MASTER_AXI_AWSIZE    ,
 output  wire [87:0]     q0_MASTER_AXI_AWUSER    ,
 output  wire            q0_MASTER_AXI_AWVALID   ,
                                               
 input   wire [7:0]      q0_MASTER_AXI_BID       ,
 input   wire            q0_MASTER_AXI_BID_PAR   ,
 output  wire            q0_MASTER_AXI_BREADY    ,
 input   wire [1:0]      q0_MASTER_AXI_BRESP     ,
 input   wire            q0_MASTER_AXI_BRESP_PAR ,
 input   wire            q0_MASTER_AXI_BVALID    ,
                                               
 input   wire [255:0]    q0_MASTER_AXI_RDATA     ,
 input   wire [31:0]     q0_MASTER_AXI_RDATA_PAR ,
 input   wire [7:0]      q0_MASTER_AXI_RID       ,
 input   wire            q0_MASTER_AXI_RID_PAR   ,
 input   wire            q0_MASTER_AXI_RLAST     ,
 output  wire            q0_MASTER_AXI_RREADY    ,
 input   wire [1:0]      q0_MASTER_AXI_RRESP     ,
 input   wire            q0_MASTER_AXI_RRESP_PAR ,
 input   wire            q0_MASTER_AXI_RVALID    ,

 output  wire [255:0]    q0_MASTER_AXI_WDATA     ,
 output  wire [31:0]     q0_MASTER_AXI_WDATA_PAR ,
 output  wire            q0_MASTER_AXI_WLAST     ,
 input   wire            q0_MASTER_AXI_WREADY    ,
 output  wire [31:0]     q0_MASTER_AXI_WSTRB     ,
 output  wire [3:0]      q0_MASTER_AXI_WSTRB_PAR ,
 output  wire            q0_MASTER_AXI_WVALID    ,



//Interrupt Pin // Unused
input   wire [27:0]     q0_INTERRUPT_SIDEBAND_SIGNALS  ,
input   wire            q0_LOCAL_INTERRUPT             ,
//Legacy Interrupt Pin //Unused                          
// output  wire            q0_INTA_IN                     ,
// output  wire            q0_INTB_IN                     ,
// output  wire            q0_INTC_IN                     ,
// output  wire            q0_INTD_IN                     ,
// input   wire            q0_INT_ACK                     ,
// output  wire [3:0]      q0_INT_PENDING_STATUS          ,
//Message Pin //Unused 
// input   wire [255:0]    q0_MSG                         ,
// input   wire [31:0]     q0_MSG_BYTE_EN                 ,
// input   wire            q0_MSG_DATA                    ,
// input   wire            q0_MSG_END                     ,
// input   wire [21:0]     q0_MSG_PASID                   ,
// input   wire            q0_MSG_PASID_PRESENT           ,
// input   wire            q0_MSG_START                   ,
// input   wire            q0_MSG_VALID                   ,
// input   wire            q0_MSG_VDH                     ,

//Error Pin                                              
output  wire            q0_CORRECTABLE_ERROR_IN   ,
input   wire            q0_CORRECTABLE_ERROR_OUT  ,
input   wire            q0_FATAL_ERROR_OUT        ,
input   wire            q0_NON_FATAL_ERROR_OUT    ,
output  wire            q0_UNCORRECTABLE_ERROR_IN ,
//APB Pin                                           
output  wire [23:0]     q0_USER_APB_PADDR         , 
output  wire            q0_USER_APB_PENABLE       , 
input   wire [31:0]     q0_USER_APB_PRDATA        , 
input   wire [3:0]      q0_USER_APB_PRDATA_PAR    , 
input   wire            q0_USER_APB_PREADY        , 
output  wire            q0_USER_APB_PSEL          , 
input   wire            q0_USER_APB_PSLVERR       , 
output  wire [3:0]      q0_USER_APB_PSTRB         , 
output  wire            q0_USER_APB_PSTRB_PAR     , 
output  wire [31:0]     q0_USER_APB_PWDATA        , 
output  wire [3:0]      q0_USER_APB_PWDATA_PAR    , 
output  wire            q0_USER_APB_PWRITE        , 

//FLR --> skip                                           
//Status Pin                                             
input   wire            q0_CORE_CLK_SHUTOFF            ,
input   wire [15:0]     q0_FUNCTION_STATUS             ,
input   wire [1:0]      q0_LINK_STATUS                 ,
input   wire [5:0]      q0_LTSSM_STATE                 ,
input   wire [2:0]      q0_PCIE_MAX_PAYLOAD_SIZE       ,
input   wire [2:0]      q0_PCIE_MAX_READ_REQ_SIZE      ,
input   wire [1:0]      q0_PIPE_P00_RATE               ,
input   wire            q0_PMA_CMN_READY               ,
input   wire            q0_REG_ACCESS_CLK_SHUTOFF      ,
//Configuration Snoop Pin
// input   wire [7:0]      q0_CONFIG_FUNCTION_NUM         , q2_CONFIG_FUNCTION_NUM,
// output  wire [31:0]     q0_CONFIG_READ_DATA            , q2_CONFIG_READ_DATA,
// output  wire [3:0]      q0_CONFIG_READ_DATA_PAR        , q2_CONFIG_READ_DATA_PAR,
// output  wire            q0_CONFIG_READ_DATA_VALID      , q2_CONFIG_READ_DATA_VALID,
// input   wire            q0_CONFIG_READ_RECEIVED        , q2_CONFIG_READ_RECEIVED,
// input   wire [9:0]      q0_CONFIG_REG_NUM              , q2_CONFIG_REG_NUM,
// input   wire [3:0]      q0_CONFIG_WRITE_BYTE_ENABLE    , q2_CONFIG_WRITE_BYTE_ENABLE,
// input   wire            q0_CONFIG_WRITE_BYTE_ENABLE_PAR, q2_CONFIG_WRITE_BYTE_ENABLE_PAR,
// input   wire [31:0]     q0_CONFIG_WRITE_DATA           , q2_CONFIG_WRITE_DATA,
// input   wire [3:0]      q0_CONFIG_WRITE_DATA_PAR       , q2_CONFIG_WRITE_DATA_PAR,
// input   wire            q0_CONFIG_WRITE_RECEIVED       , q2_CONFIG_WRITE_RECEIVED,

//JTAG
input   wire            jtag_inst1_DRCK,
input   wire            jtag_inst1_RESET,
input   wire            jtag_inst1_TMS,
input   wire            jtag_inst1_RUNTEST,
input   wire            jtag_inst1_SEL,
input   wire            jtag_inst1_SHIFT,
input   wire            jtag_inst1_TDI,
input   wire            jtag_inst1_CAPTURE,
input   wire            jtag_inst1_TCK,
input   wire            jtag_inst1_UPDATE,
output  wire            jtag_inst1_TDO
);
reg [63:0] q0_obs_tawaddr;
reg [255:0] q0_obs_twdata; 
reg [63:0] q0_obs_taraddr;
reg [2:0] q0_obs_tarsize;
reg [2:0] q0_obs_tawsize;
reg [7:0] q0_obs_tarlen;

wire [255:0] q0_vio_trdata;
//RESET
assign q0_RESET_ACK = q0_RESET_REQ;
assign q0_USER_AXI_RESET_N = 1'b1;
 
//reset_n for restarting pcie link
//soft reset for axi

assign q0_CORRECTABLE_ERROR_IN= 1'b0;
assign q0_UNCORRECTABLE_ERROR_IN= 1'b0;
assign q0_TARGET_NON_POSTED_REJ = 1'b0;

//slave axi
assign q0_TARGET_AXI_AWREADY   = 1'b1;
assign q0_TARGET_AXI_ARREADY   = 1'b1;
assign q0_TARGET_AXI_BID       = 8'hff;
assign q0_TARGET_AXI_BID_PAR   = 1'b1;
assign q0_TARGET_AXI_BRESP     = 2'b00;
assign q0_TARGET_AXI_BRESP_PAR = 1'b1;
assign q0_TARGET_AXI_RID       = 8'h00;
assign q0_TARGET_AXI_RID_PAR   = 1'b1;
assign q0_TARGET_AXI_RRESP     = 2'b00;
assign q0_TARGET_AXI_RRESP_PAR = 1'b1;
assign q0_TARGET_AXI_WREADY    = 1'b1;

genvar i;
generate
    for (i=0; i<32; i=i+1)
    begin
        assign q0_TARGET_AXI_RDATA_PAR[i] = ~(^q0_TARGET_AXI_RDATA[i*8+:8]);
    end
endgenerate

always @ (negedge in_user or posedge axiclk)
begin
  if (~in_user) begin
     q0_TARGET_AXI_BVALID <=    1'b0;
     q0_TARGET_AXI_RLAST <=     1'b0;
     q0_TARGET_AXI_RVALID <=    1'b0;
  end else begin
     q0_TARGET_AXI_BVALID <= q0_TARGET_AXI_WLAST;
     q0_TARGET_AXI_RLAST <= q0_TARGET_AXI_ARVALID;
     q0_TARGET_AXI_RVALID <= q0_TARGET_AXI_ARVALID;
     if (q0_TARGET_AXI_WVALID)
        q0_obs_twdata <= q0_TARGET_AXI_WDATA;
  end
end

wire        err_rst;
wire [15:0] err_cnt;

error_checker #(
.CNT_WIDTH (16)
) err_chk_inst1 (
.clk        (axiclk), 
.rstn       (~err_rst),
.data_in    (q0_TARGET_AXI_WDATA[15:0]),
.data_valid (q0_TARGET_AXI_WVALID),
.err_count  (err_cnt)
);

wire [7:0] state_q0;
wire [87:0]     VIO_AXI_AWUSER;
wire [63:0]     VIO_AXI_ADDR ;
wire [255:0]    VIO_AXI_DATA ;
wire            VIO_AXI_OPS  ;
wire            VIO_AXI_START;
wire [31:0]     VIO_AXI_WSTRB;

//AUTOMATED INTERRUPT TEST FOR MSI TRIGGERED READ
wire MSI_TEST_INIT;
wire MSI_TEST_TRIG;
reg [7:0] MSI_TEST_CNT;

assign MSI_TEST_TRIG = MSI_TEST_CNT[6];
always@(posedge axiclk or negedge MSI_TEST_INIT) begin
    if (~MSI_TEST_INIT) begin
        MSI_TEST_CNT <= 8'h0;
    end
    else begin
        MSI_TEST_CNT <= MSI_TEST_CNT + 1'b1;
    end
end

axictrl_pcie_master q0_axim
(
    .clk                 (axiclk                 ),
    .rstn                (in_user ),
    .state               (state_q0               ),
    
    .MASTER_AXI_ARADDR   (q0_MASTER_AXI_ARADDR   ),
    .MASTER_AXI_ARID     (q0_MASTER_AXI_ARID     ),
    .MASTER_AXI_ARLEN    (q0_MASTER_AXI_ARLEN    ),
    .MASTER_AXI_ARREADY  (q0_MASTER_AXI_ARREADY  ),
    .MASTER_AXI_ARSIZE   (q0_MASTER_AXI_ARSIZE   ),
    .MASTER_AXI_ARUSER   (q0_MASTER_AXI_ARUSER   ),
    .MASTER_AXI_ARVALID  (q0_MASTER_AXI_ARVALID  ),
                         
    .MASTER_AXI_AWADDR   (q0_MASTER_AXI_AWADDR   ),
    .MASTER_AXI_AWID     (q0_MASTER_AXI_AWID     ),
    .MASTER_AXI_AWLEN    (q0_MASTER_AXI_AWLEN    ),
    .MASTER_AXI_AWREADY  (q0_MASTER_AXI_AWREADY  ),
    .MASTER_AXI_AWSIZE   (q0_MASTER_AXI_AWSIZE   ),
    .MASTER_AXI_AWUSER   (q0_MASTER_AXI_AWUSER   ),
    .MASTER_AXI_AWVALID  (q0_MASTER_AXI_AWVALID  ),
                         
    .MASTER_AXI_BID      (q0_MASTER_AXI_BID      ),
    .MASTER_AXI_BID_PAR  (q0_MASTER_AXI_BID_PAR  ),
    .MASTER_AXI_BREADY   (q0_MASTER_AXI_BREADY   ),
    .MASTER_AXI_BRESP    (q0_MASTER_AXI_BRESP    ),
    .MASTER_AXI_BRESP_PAR(q0_MASTER_AXI_BRESP_PAR),
    .MASTER_AXI_BVALID   (q0_MASTER_AXI_BVALID   ),
                         
    .MASTER_AXI_RDATA    (q0_MASTER_AXI_RDATA    ),
    .MASTER_AXI_RDATA_PAR(q0_MASTER_AXI_RDATA_PAR),
    .MASTER_AXI_RID      (q0_MASTER_AXI_RID      ),
    .MASTER_AXI_RID_PAR  (q0_MASTER_AXI_RID_PAR  ),
    .MASTER_AXI_RLAST    (q0_MASTER_AXI_RLAST    ),
    .MASTER_AXI_RREADY   (q0_MASTER_AXI_RREADY   ),
    .MASTER_AXI_RRESP    (q0_MASTER_AXI_RRESP    ),
    .MASTER_AXI_RRESP_PAR(q0_MASTER_AXI_RRESP_PAR),
    .MASTER_AXI_RVALID   (q0_MASTER_AXI_RVALID   ),
                         
    .MASTER_AXI_WDATA    (q0_MASTER_AXI_WDATA    ),
    .MASTER_AXI_WDATA_PAR(q0_MASTER_AXI_WDATA_PAR),
    .MASTER_AXI_WLAST    (q0_MASTER_AXI_WLAST    ),
    .MASTER_AXI_WREADY   (q0_MASTER_AXI_WREADY   ),
    .MASTER_AXI_WSTRB    (q0_MASTER_AXI_WSTRB    ),
    .MASTER_AXI_WSTRB_PAR(q0_MASTER_AXI_WSTRB_PAR),
    .MASTER_AXI_WVALID   (q0_MASTER_AXI_WVALID   ),
    
    .VIO_AXI_AWUSER     (VIO_AXI_AWUSER),
    .VIO_AXI_ADDR        (VIO_AXI_ADDR ),
    .VIO_AXI_DATA        (VIO_AXI_DATA ),
    .VIO_AXI_OPS         (VIO_AXI_OPS  ),
    .VIO_AXI_WSTRB       (VIO_AXI_WSTRB),
    .VIO_AXI_START       (VIO_AXI_START | MSI_TEST_TRIG)
);


//APB INBOUND CONFIGURATOR

//PARITY FOR APB

generate
    for (i=0; i<4; i=i+1) begin
        assign q0_USER_APB_PWDATA_PAR[i] = ~(^q0_USER_APB_PWDATA[i*8 +: 8]);
    end
endgenerate
assign q0_USER_APB_PSTRB = 4'hf;
assign q0_USER_APB_PSTRB_PAR = ~(^q0_USER_APB_PSTRB);

//Q0 APB Arbiter
wire  [23:0]  q0_USER_MIF_APB_PADDR     ;
wire          q0_USER_MIF_APB_PENABLE   ;
wire          q0_USER_MIF_APB_PSEL      ;
wire  [31:0]  q0_USER_MIF_APB_PWDATA    ;
wire          q0_USER_MIF_APB_PWRITE    ;
wire [31:0]  q0_USER_MIF_APB_PRDATA    ;
wire         q0_USER_MIF_APB_PREADY    ;
wire         q0_USER_MIF_APB_PSLVERR   ;

wire [23:0]  q0_USER_DBG_APB_PADDR     ;
wire         q0_USER_DBG_APB_PENABLE   ;
wire         q0_USER_DBG_APB_PSEL      ;
wire [31:0]  q0_USER_DBG_APB_PWDATA    ;
wire         q0_USER_DBG_APB_PWRITE    ;
wire [31:0]  q0_USER_DBG_APB_PRDATA    ;
wire         q0_USER_DBG_APB_PREADY    ;
wire         q0_USER_DBG_APB_PSLVERR   ;

wire [2-1:0]     s_q0_apb_psel   ;
wire [2-1:0]     s_q0_apb_penable;
wire [2-1:0]     s_q0_apb_pwrite ;
wire [24*2-1:0]  s_q0_apb_paddr  ;
wire [32*2-1:0]  s_q0_apb_pwdata ;
wire [32*2-1:0]  s_q0_apb_prdata ;
wire [2-1:0]     s_q0_apb_pready ;
wire [2-1:0]     s_q0_apb_pslverr;

assign s_q0_apb_psel    = {q0_USER_MIF_APB_PSEL   ,q0_USER_DBG_APB_PSEL   };
assign s_q0_apb_penable = {q0_USER_MIF_APB_PENABLE,q0_USER_DBG_APB_PENABLE};
assign s_q0_apb_pwrite  = {q0_USER_MIF_APB_PWRITE ,q0_USER_DBG_APB_PWRITE };
assign s_q0_apb_paddr   = {q0_USER_MIF_APB_PADDR  ,q0_USER_DBG_APB_PADDR  };
assign s_q0_apb_pwdata  = {q0_USER_MIF_APB_PWDATA ,q0_USER_DBG_APB_PWDATA };

assign {q0_USER_MIF_APB_PRDATA , q0_USER_DBG_APB_PRDATA } = s_q0_apb_prdata;
assign {q0_USER_MIF_APB_PREADY , q0_USER_DBG_APB_PREADY } = s_q0_apb_pready;
assign {q0_USER_MIF_APB_PSLVERR, q0_USER_DBG_APB_PSLVERR} = s_q0_apb_pslverr;


apb_interconnect u_apb_interconnect
(
  .clk              (apbclk),
  .rst_n            (1'b1),
  .grant_o          (),  
  .apb_psel_o       (q0_USER_APB_PSEL),
  .apb_penable_o    (q0_USER_APB_PENABLE),
  .apb_pwrite_o     (q0_USER_APB_PWRITE),
  .apb_paddr_o      (q0_USER_APB_PADDR),
  .apb_pwdata_o     (q0_USER_APB_PWDATA),
  .apb_prdata_i     (q0_USER_APB_PRDATA),
  .apb_pready_i     (q0_USER_APB_PREADY),
  .apb_pslverr_i    (q0_USER_APB_PSLVERR),
    
  .s_apb_psel_i     (s_q0_apb_psel   ),
  .s_apb_penable_i  (s_q0_apb_penable),
  .s_apb_pwrite_i   (s_q0_apb_pwrite ),
  .s_apb_paddr_i    (s_q0_apb_paddr  ),
  .s_apb_pwdata_i   (s_q0_apb_pwdata ),
  .s_apb_prdata_o   (s_q0_apb_prdata ),
  .s_apb_pready_o   (s_q0_apb_pready ),
  .s_apb_pslverr_o  (s_q0_apb_pslverr)
);

wire [23:0] q0_vio_apb_paddr ;
wire [31:0] q0_vio_apb_pwdata;
wire [3:0]  q0_vio_apb_pstrb ;
wire        q0_vio_apb_writei;
wire        q0_vio_apb_start ;
wire [31:0] q0_vio_apb_prdata;

apbvio vio_inst(
    .apbclk         (apbclk),
    .rstn           (1'b1),
    .paddr_i        (q0_vio_apb_paddr ),
    .pwdata_i       (q0_vio_apb_pwdata),
    .pstrb_i        (4'hf ),
    .write_i        (q0_vio_apb_writei),
    .start_i        (q0_vio_apb_start ),
    .APB_PRDATA_reg (q0_vio_apb_prdata),
    
    .APB_PADDR      (q0_USER_DBG_APB_PADDR),
    .APB_PENABLE    (q0_USER_DBG_APB_PENABLE),
    .APB_PRDATA     (q0_USER_DBG_APB_PRDATA),
    .APB_PREADY     (q0_USER_DBG_APB_PREADY),
    .APB_PSEL       (q0_USER_DBG_APB_PSEL),
    .APB_PSLVERR    (q0_USER_DBG_APB_PSLVERR),
    .APB_PWDATA     (q0_USER_DBG_APB_PWDATA),
    .APB_PWRITE     (q0_USER_DBG_APB_PWRITE)
);

pcie_apb_master #(
    .ROM_MIF        ("pcie_inbound_mif.mem" ),
    .ROM_DEPTH      (32              ),
    .RAM_ADDR_W     (5             ),
    .PADDR_WIDTH    (24            ),
    .PDATA_WIDTH    (32            )
) u_pcie_apb_master(    
    .PCLK              (apbclk        ),//i
    .PRESETn           (q0_LINK_STATUS == 3'b11    ),//i
    .apb_halt_i        (1'b0                ),
    .PSEL              (q0_USER_MIF_APB_PSEL      ),//o
    .PWRITE            (q0_USER_MIF_APB_PWRITE    ),//o
    .PENABLE           (q0_USER_MIF_APB_PENABLE   ),//o
    .PADDR             (q0_USER_MIF_APB_PADDR   ),//o
    .PWDATA            (q0_USER_MIF_APB_PWDATA    ),//o
    .PWDATA_PAR        (                    ),//o
    .PSTRB             (    ),//o  
    .PSTRB_PAR         (                    ),//o      
    .PRDATA            (q0_USER_MIF_APB_PRDATA    ),//i
    .PREADY            (q0_USER_MIF_APB_PREADY    ),//i
    .PSLVERR           (1'b0 ) //i
);

edb_top edb_top_inst(
    .bscan_CAPTURE          ( jtag_inst1_CAPTURE ),
    .bscan_DRCK             ( jtag_inst1_DRCK    ),
    .bscan_RESET            ( jtag_inst1_RESET   ),
    .bscan_RUNTEST          ( jtag_inst1_RUNTEST ),
    .bscan_SEL              ( jtag_inst1_SEL     ),
    .bscan_SHIFT            ( jtag_inst1_SHIFT   ),
    .bscan_TCK              ( jtag_inst1_TCK     ),
    .bscan_TDI              ( jtag_inst1_TDI     ),
    .bscan_TMS              ( jtag_inst1_TMS     ),
    .bscan_UPDATE           ( jtag_inst1_UPDATE  ),
    .bscan_TDO              ( jtag_inst1_TDO     ),
    .vio0_clk               ( axiclk             ),
    .vio0_q0_ltssm_state    ( q0_LTSSM_STATE     ),
    .vio0_q0_link_status    ( q0_LINK_STATUS     ),
    .vio0_q0_pipe_p00_rate  ( q0_PIPE_P00_RATE   ),
    .vio0_q0_cmn_ready      ( q0_PMA_CMN_READY   ),
    
    .vio0_q0_TARGET_AXI_AWSIZE    ( q0_TARGET_AXI_AWSIZE     ),
    .vio0_q0_TARGET_AXI_AWADDR    ( q0_TARGET_AXI_AWADDR     ),
    .vio0_q0_TARGET_AXI_WDATA     ( q0_obs_twdata            ),
    .vio0_q0_TARGET_AXI_ARSIZE    ( q0_TARGET_AXI_ARSIZE     ),
    .vio0_q0_TARGET_AXI_ARLEN     ( q0_TARGET_AXI_ARLEN      ),
    .vio0_q0_TARGET_AXI_ARADDR    ( q0_TARGET_AXI_ARADDR     ),
    .vio0_q0_TARGET_AXI_RDATA     ( q0_TARGET_AXI_RDATA      ),
    
    .vio0_err_rst (err_rst),
    .vio0_err_cnt (err_cnt),
    
    .vio1_clk                            (axiclk),
    .vio1_q0_INTERRUPT_SIDEBAND_SIGNALS  (q0_INTERRUPT_SIDEBAND_SIGNALS),
    .vio1_q0_LOCAL_INTERRUPT             (q0_LOCAL_INTERRUPT           ),
    .vio1_AXI_ADDR                        (VIO_AXI_ADDR ),
    .vio1_AXI_DATA                        (VIO_AXI_DATA ),
    .vio1_AXI_OPS                         (VIO_AXI_OPS  ),
    .vio1_AXI_START                       (VIO_AXI_START),
    .vio1_AXI_WSTRB                       (VIO_AXI_WSTRB),
    .vio1_VIO_AXI_AWUSER                  (VIO_AXI_AWUSER),
    .vio1_MSI_TEST_INIT                   (MSI_TEST_INIT),
    
    .la0_clk                  (axiclk),
    .la0_q0_TARGET_AXI_AWADDR (q0_TARGET_AXI_AWADDR ),
    .la0_q0_TARGET_AXI_AWLEN  (q0_TARGET_AXI_AWLEN  ),
    .la0_q0_TARGET_AXI_AWSIZE  (q0_TARGET_AXI_AWSIZE  ),
    .la0_q0_TARGET_AXI_AWVALID(q0_TARGET_AXI_AWVALID),
    .la0_q0_TARGET_AXI_WDATA  (q0_TARGET_AXI_WDATA  ),
    .la0_q0_TARGET_AXI_WVALID (q0_TARGET_AXI_WVALID ),
    .la0_q0_TARGET_AXI_WSTRB  (q0_TARGET_AXI_WSTRB  ),
    .la0_q0_TARGET_AXI_WLAST  (q0_TARGET_AXI_WLAST  ),
    .la0_q0_TARGET_AXI_BREADY    (q0_TARGET_AXI_BREADY   ),
    .la0_q0_TARGET_AXI_BRESP     (q0_TARGET_AXI_BRESP    ),
    .la0_q0_TARGET_AXI_BVALID    (q0_TARGET_AXI_BVALID   ),
    
    .la0_q0_TARGET_AXI_ARADDR       ( q0_TARGET_AXI_ARADDR     ),
    .la0_q0_TARGET_AXI_ARVALID      ( q0_TARGET_AXI_ARVALID),
    .la0_q0_TARGET_AXI_ARREADY      ( q0_TARGET_AXI_ARREADY),
    .la0_q0_TARGET_AXI_ARSIZE       ( q0_TARGET_AXI_ARSIZE     ),
    .la0_q0_TARGET_AXI_ARLEN        ( q0_TARGET_AXI_ARLEN      ),
    .la0_q0_TARGET_AXI_RVALID       ( q0_TARGET_AXI_RVALID ),
    .la0_q0_TARGET_AXI_RLAST        (q0_TARGET_AXI_RLAST),
    .la0_q0_TARGET_AXI_RDATA        ( q0_TARGET_AXI_RDATA      ),
    
    .la0_q0_TARGET_AXI_ARUSER   (q0_TARGET_AXI_ARUSER),
    .la0_q0_TARGET_AXI_AWUSER   (q0_TARGET_AXI_AWUSER),
    
    .la0_err_cnt (err_cnt),
    .la0_q0_MASTER_AXI_AWADDR       ( q0_MASTER_AXI_AWADDR   ),
    .la0_q0_MASTER_AXI_AWREADY      ( q0_MASTER_AXI_AWREADY ),
    .la0_q0_MASTER_AXI_AWVALID      ( q0_MASTER_AXI_AWVALID ),
    .la0_q0_MASTER_AXI_WDATA        ( q0_MASTER_AXI_WDATA ),
    .la0_q0_MASTER_AXI_WREADY       ( q0_MASTER_AXI_WREADY ),
    .la0_q0_MASTER_AXI_WVALID       ( q0_MASTER_AXI_WVALID ),
    .la0_q0_MASTER_AXI_WLAST        ( q0_MASTER_AXI_WLAST ),
    .la0_q0_MASTER_AXI_BVALID       ( q0_MASTER_AXI_BVALID ),
    .la0_q0_MASTER_AXI_BRESP        ( q0_MASTER_AXI_BRESP ),
    .la0_q0_MASTER_AXI_BREADY       ( q0_MASTER_AXI_BREADY ),
    .la0_state      (state_q0),
    
    .apbvio_clk                             ( apbclk                         ),
    .apbvio_apb_paddr                       ( q0_vio_apb_paddr               ),
    .apbvio_apb_pwdata                      ( q0_vio_apb_pwdata              ),
    .apbvio_apb_write                       ( q0_vio_apb_writei              ),
    .apbvio_apb_start                       ( q0_vio_apb_start               ),
    .apbvio_apb_prdata                      ( q0_vio_apb_prdata              )
);

endmodule
