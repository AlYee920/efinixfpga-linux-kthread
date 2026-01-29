module axictrl_pcie_master
(
    input                   clk                 ,
    input                   rstn                ,
    output  reg [7:0]       state               ,
    

    output  reg  [63:0]     MASTER_AXI_ARADDR   ,
    output  reg  [7:0]      MASTER_AXI_ARID     ,
    output  reg  [7:0]      MASTER_AXI_ARLEN    ,
    input   wire            MASTER_AXI_ARREADY  ,
    output  reg  [2:0]      MASTER_AXI_ARSIZE   ,
    output  reg  [87:0]     MASTER_AXI_ARUSER   ,
    output  reg             MASTER_AXI_ARVALID  ,

    output  reg  [63:0]     MASTER_AXI_AWADDR   ,
    output  reg  [7:0]      MASTER_AXI_AWID     ,
    output  reg  [7:0]      MASTER_AXI_AWLEN    ,
    input   wire            MASTER_AXI_AWREADY  ,
    output  reg  [2:0]      MASTER_AXI_AWSIZE   ,
    output  reg  [87:0]     MASTER_AXI_AWUSER   ,
    output  reg             MASTER_AXI_AWVALID  ,

    input   wire [7:0]      MASTER_AXI_BID      ,
    input   wire            MASTER_AXI_BID_PAR  ,
    output  reg             MASTER_AXI_BREADY   ,
    input   wire [1:0]      MASTER_AXI_BRESP    ,
    input   wire            MASTER_AXI_BRESP_PAR,
    input   wire            MASTER_AXI_BVALID   ,

    input   wire [255:0]    MASTER_AXI_RDATA    ,
    input   wire [31:0]     MASTER_AXI_RDATA_PAR,
    input   wire [7:0]      MASTER_AXI_RID      ,
    input   wire            MASTER_AXI_RID_PAR  ,
    input   wire            MASTER_AXI_RLAST    ,
    output  reg             MASTER_AXI_RREADY   ,
    input   wire [1:0]      MASTER_AXI_RRESP    ,
    input   wire            MASTER_AXI_RRESP_PAR,
    input   wire            MASTER_AXI_RVALID   ,

    output  reg  [255:0]    MASTER_AXI_WDATA    ,
    output  wire [31:0]     MASTER_AXI_WDATA_PAR,
    output  reg             MASTER_AXI_WLAST    ,
    input   wire            MASTER_AXI_WREADY   ,
    output  reg  [31:0]     MASTER_AXI_WSTRB    ,
    output  wire [3:0]      MASTER_AXI_WSTRB_PAR,
    output  reg             MASTER_AXI_WVALID   ,
    
    input   wire [87:0]     VIO_AXI_AWUSER,
    input   wire [63:0]     VIO_AXI_ADDR,
    input   wire [255:0]    VIO_AXI_DATA,
    input   wire            VIO_AXI_OPS,
    input   wire [31:0]     VIO_AXI_WSTRB,
    input   wire            VIO_AXI_START
    
);

localparam  IDLE    = 8'b0000_0000,
            WRITE   = 8'b0000_0001,
            READ    = 8'b0000_0010;


//reg [3:0] state;


genvar i;
generate
    for (i=0; i<32; i=i+1) begin
        assign MASTER_AXI_WDATA_PAR[i] = ~(^MASTER_AXI_WDATA[i*8 +: 8]);
    end
endgenerate

genvar j;
generate
    for (j=0; j<4; j=j+1) begin
        assign MASTER_AXI_WSTRB_PAR[j] = ~(^MASTER_AXI_WSTRB[j*8 +: 8]);
    end
endgenerate

reg VIO_AXI_START_reg;
reg VIO_AXI_START_reg2;
wire VIO_AXI_START_trig;

assign VIO_AXI_START_trig = (~VIO_AXI_START_reg2) & VIO_AXI_START;
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        VIO_AXI_START_reg <= 1'b0;
        VIO_AXI_START_reg2 <= 1'b0;
    end
    else begin
        VIO_AXI_START_reg <= VIO_AXI_START;
        VIO_AXI_START_reg2 <= VIO_AXI_START_reg;
    end
end

always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        MASTER_AXI_ARADDR   <= {32'b0,32'h0000_0000};
        MASTER_AXI_ARID     <= {8{1'b0}};
        MASTER_AXI_ARLEN    <= {8{1'b0}};
        MASTER_AXI_ARSIZE   <= {3{1'b0}};
        MASTER_AXI_ARUSER   <= {88{1'b0}};
        MASTER_AXI_ARVALID  <= 1'b0;
        MASTER_AXI_AWADDR   <= {32'b0,32'h0000_0000};
        MASTER_AXI_AWID     <= {8{1'b0}};
        MASTER_AXI_AWLEN    <= {8{1'b0}};
        MASTER_AXI_AWSIZE   <= {3{1'b0}};
        MASTER_AXI_AWUSER   <= {88{1'b0}};
        MASTER_AXI_AWVALID  <= 1'b0;
        MASTER_AXI_RREADY   <= 1'b0;
        MASTER_AXI_WDATA    <= {256{1'b0}};
        MASTER_AXI_WLAST    <= 1'b0;
        MASTER_AXI_WSTRB    <= {32{1'b0}};
        MASTER_AXI_WVALID   <= 1'b0;
        MASTER_AXI_BREADY   <= 1'b0;
        state               <= IDLE;   
    end 
    else begin
        if (state==IDLE) begin
            if (VIO_AXI_START_trig) begin
                if (VIO_AXI_OPS == 1'b0) begin
                    MASTER_AXI_AWADDR <= VIO_AXI_ADDR; 
                    MASTER_AXI_WDATA <= VIO_AXI_DATA; 
                    MASTER_AXI_AWLEN <= 8'h0;
                    MASTER_AXI_AWSIZE <= 3'h5;
                    //MASTER_AXI_AWUSER <= {1'b1,31'b0, 32'b0, 24'h00_0002};
                    MASTER_AXI_AWUSER <= VIO_AXI_AWUSER;
                    MASTER_AXI_WSTRB <= VIO_AXI_WSTRB;
                    MASTER_AXI_AWVALID <= 1'b1;
                    state <= WRITE;
                end
                else if (VIO_AXI_OPS == 1'b1) begin
                    MASTER_AXI_ARADDR <= VIO_AXI_ADDR; 
                    MASTER_AXI_ARLEN  <= 8'h0;
                    MASTER_AXI_ARUSER <= VIO_AXI_AWUSER;
                    MASTER_AXI_ARVALID  <= 1'b1;
                    MASTER_AXI_ARSIZE <= 3'h5;
                    state <= READ;
                end
                end
       end 
        
        if (state==WRITE) begin
            if (~MASTER_AXI_BREADY) begin 
                MASTER_AXI_AWVALID <= 1'b1;
                MASTER_AXI_BREADY <= 1'b1;
            end
            if (MASTER_AXI_AWVALID && MASTER_AXI_AWREADY) begin
                MASTER_AXI_AWVALID <= 1'b0;
                MASTER_AXI_WVALID <= 1'b1;
                MASTER_AXI_WLAST <= 1'b1;
            end
            else if (MASTER_AXI_WVALID && MASTER_AXI_WREADY) begin
                MASTER_AXI_WVALID <= 1'b0;
                MASTER_AXI_WLAST <= 1'b0;
            end
            else if (MASTER_AXI_BVALID) begin
                MASTER_AXI_BREADY <= 1'b0;
                state <= IDLE;
            end  
        end
      
        
        if (state==READ) begin
            if (MASTER_AXI_ARREADY & MASTER_AXI_ARVALID) begin
                 MASTER_AXI_ARID     <= MASTER_AXI_ARID + 1'b1;
                 MASTER_AXI_ARADDR   <= MASTER_AXI_ARADDR[21:0] + 8'h40;
                 MASTER_AXI_ARVALID  <= 1'b0;
                 MASTER_AXI_RREADY   <= 1'b1;
            end
            else begin
                 MASTER_AXI_ARVALID  <= 1'b1;
            end
            
            if (MASTER_AXI_RLAST) begin
                state <= IDLE;
            end
        end
    end
end


endmodule
