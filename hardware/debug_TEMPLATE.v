edb_top edb_top_inst (
    .bscan_CAPTURE      ( jtag_inst1_CAPTURE ),
    .bscan_DRCK         ( jtag_inst1_DRCK ),
    .bscan_RESET        ( jtag_inst1_RESET ),
    .bscan_RUNTEST      ( jtag_inst1_RUNTEST ),
    .bscan_SEL          ( jtag_inst1_SEL ),
    .bscan_SHIFT        ( jtag_inst1_SHIFT ),
    .bscan_TCK          ( jtag_inst1_TCK ),
    .bscan_TDI          ( jtag_inst1_TDI ),
    .bscan_TMS          ( jtag_inst1_TMS ),
    .bscan_UPDATE       ( jtag_inst1_UPDATE ),
    .bscan_TDO          ( jtag_inst1_TDO ),
    .vio0_clk       ( $INSERT_YOUR_CLOCK_NAME ),
    .vio0_q0_ltssm_state( q0_ltssm_state ),
    .vio0_q0_link_status( q0_link_status ),
    .vio0_q0_pipe_p00_rate( q0_pipe_p00_rate ),
    .vio0_q0_cmn_ready( q0_cmn_ready ),
    .vio0_q0_TARGET_AXI_AWSIZE( q0_TARGET_AXI_AWSIZE ),
    .vio0_q0_TARGET_AXI_AWADDR( q0_TARGET_AXI_AWADDR ),
    .vio0_q0_TARGET_AXI_WDATA( q0_TARGET_AXI_WDATA ),
    .vio0_q0_TARGET_AXI_ARSIZE( q0_TARGET_AXI_ARSIZE ),
    .vio0_q0_TARGET_AXI_ARLEN( q0_TARGET_AXI_ARLEN ),
    .vio0_q0_TARGET_AXI_ARADDR( q0_TARGET_AXI_ARADDR ),
    .vio0_err_cnt   ( err_cnt ),
    .vio0_q0_TARGET_AXI_RDATA( q0_TARGET_AXI_RDATA ),
    .vio0_err_rst   ( err_rst ),
    .la0_clk            ( $INSERT_YOUR_CLOCK_NAME ),
    .la0_q0_TARGET_AXI_AWADDR       ( q0_TARGET_AXI_AWADDR ),
    .la0_q0_TARGET_AXI_AWLEN        ( q0_TARGET_AXI_AWLEN ),
    .la0_q0_TARGET_AXI_AWSIZE       ( q0_TARGET_AXI_AWSIZE ),
    .la0_q0_TARGET_AXI_AWVALID      ( q0_TARGET_AXI_AWVALID ),
    .la0_q0_TARGET_AXI_AWUSER       ( q0_TARGET_AXI_AWUSER ),
    .la0_q0_TARGET_AXI_WDATA        ( q0_TARGET_AXI_WDATA ),
    .la0_q0_TARGET_AXI_WVALID       ( q0_TARGET_AXI_WVALID ),
    .la0_q0_TARGET_AXI_WSTRB        ( q0_TARGET_AXI_WSTRB ),
    .la0_q0_TARGET_AXI_WLAST        ( q0_TARGET_AXI_WLAST ),
    .la0_q0_TARGET_AXI_BREADY       ( q0_TARGET_AXI_BREADY ),
    .la0_q0_TARGET_AXI_BVALID       ( q0_TARGET_AXI_BVALID ),
    .la0_q0_TARGET_AXI_BRESP        ( q0_TARGET_AXI_BRESP ),
    .la0_q0_TARGET_AXI_ARADDR       ( q0_TARGET_AXI_ARADDR ),
    .la0_q0_TARGET_AXI_ARVALID      ( q0_TARGET_AXI_ARVALID ),
    .la0_q0_TARGET_AXI_ARREADY      ( q0_TARGET_AXI_ARREADY ),
    .la0_q0_TARGET_AXI_ARUSER       ( q0_TARGET_AXI_ARUSER ),
    .la0_q0_TARGET_AXI_ARSIZE       ( q0_TARGET_AXI_ARSIZE ),
    .la0_q0_TARGET_AXI_ARLEN        ( q0_TARGET_AXI_ARLEN ),
    .la0_q0_TARGET_AXI_RVALID       ( q0_TARGET_AXI_RVALID ),
    .la0_q0_TARGET_AXI_RDATA        ( q0_TARGET_AXI_RDATA ),
    .la0_q0_TARGET_AXI_RLAST        ( q0_TARGET_AXI_RLAST ),
    .la0_err_cnt        ( err_cnt ),
    .la0_q0_MASTER_AXI_AWADDR       ( q0_MASTER_AXI_AWADDR ),
    .la0_q0_MASTER_AXI_AWREADY      ( q0_MASTER_AXI_AWREADY ),
    .la0_q0_MASTER_AXI_AWVALID      ( q0_MASTER_AXI_AWVALID ),
    .la0_q0_MASTER_AXI_WDATA        ( q0_MASTER_AXI_WDATA ),
    .la0_q0_MASTER_AXI_WSTRB        ( q0_MASTER_AXI_WSTRB ),
    .la0_q0_MASTER_AXI_WREADY       ( q0_MASTER_AXI_WREADY ),
    .la0_q0_MASTER_AXI_WVALID       ( q0_MASTER_AXI_WVALID ),
    .la0_q0_MASTER_AXI_WLAST        ( q0_MASTER_AXI_WLAST ),
    .la0_q0_MASTER_AXI_BVALID       ( q0_MASTER_AXI_BVALID ),
    .la0_q0_MASTER_AXI_BRESP        ( q0_MASTER_AXI_BRESP ),
    .la0_q0_MASTER_AXI_BREADY       ( q0_MASTER_AXI_BREADY ),
    .la0_state      ( state ),
    .vio1_clk       ( $INSERT_YOUR_CLOCK_NAME ),
    .vio1_q0_INTERRUPT_SIDEBAND_SIGNALS( q0_INTERRUPT_SIDEBAND_SIGNALS ),
    .vio1_q0_LOCAL_INTERRUPT( q0_LOCAL_INTERRUPT ),
    .vio1_AXI_ADDR  ( AXI_ADDR ),
    .vio1_AXI_DATA  ( AXI_DATA ),
    .vio1_AXI_WSTRB ( AXI_WSTRB ),
    .vio1_AXI_OPS   ( AXI_OPS ),
    .vio1_AXI_START ( AXI_START ),
    .vio1_VIO_AXI_AWUSER( VIO_AXI_AWUSER ),
    .vio1_MSI_TEST_INIT( MSI_TEST_INIT ),
    .apbvio_clk     ( $INSERT_YOUR_CLOCK_NAME ),
    .apbvio_apb_prdata( apb_prdata ),
    .apbvio_apb_write( apb_write ),
    .apbvio_apb_paddr( apb_paddr ),
    .apbvio_apb_pwdata( apb_pwdata ),
    .apbvio_apb_start( apb_start )
);

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.              
//
// This   document  contains  proprietary information  which   is        
// protected by  copyright. All rights  are reserved.  This notice       
// refers to original work by Efinix, Inc. which may be derivitive       
// of other work distributed under license of the authors.  In the       
// case of derivative work, nothing in this notice overrides the         
// original author's license agreement.  Where applicable, the           
// original license agreement is included in it's original               
// unmodified form immediately below this header.                        
//                                                                       
// WARRANTY DISCLAIMER.                                                  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
//                                                                       
// LIMITATION OF LIABILITY.                                              
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
//     APPLY TO LICENSEE.                                                
//
////////////////////////////////////////////////////////////////////////////////
