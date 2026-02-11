module msi_test_axi_master
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

    // input   wire [255:0]    MASTER_AXI_RDATA    ,
    // input   wire [31:0]     MASTER_AXI_RDATA_PAR,
    // input   wire [7:0]      MASTER_AXI_RID      ,
    // input   wire            MASTER_AXI_RID_PAR  ,
    // input   wire            MASTER_AXI_RLAST    ,
    // output  reg             MASTER_AXI_RREADY   ,
    // input   wire [1:0]      MASTER_AXI_RRESP    ,
    // input   wire            MASTER_AXI_RRESP_PAR,
    // input   wire            MASTER_AXI_RVALID   ,

    output  reg  [255:0]    MASTER_AXI_WDATA    ,
    output  wire [31:0]     MASTER_AXI_WDATA_PAR,
    output  reg             MASTER_AXI_WLAST    ,
    input   wire            MASTER_AXI_WREADY   ,
    output  reg  [31:0]     MASTER_AXI_WSTRB    ,
    output  wire [3:0]      MASTER_AXI_WSTRB_PAR,
    output  reg             MASTER_AXI_WVALID   ,
    
    input   wire [31:0]     VIO_MSI_ADDR,
    input   wire [15:0]     VIO_MSI_DATA,
    input   wire            VIO_MSI_START,

    output reg             MSI_LED,
    output wire [31:0]     MSI_1_DLY
);

localparam  IDLE        = 8'b0000_0000,
            MSI_WRITE_1 = 8'b0000_0001,
            MSI_WRITE_2 = 8'b0000_0010;


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

assign VIO_AXI_START_trig = (~VIO_AXI_START_reg2) & VIO_MSI_START;
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        VIO_AXI_START_reg <= 1'b0;
        VIO_AXI_START_reg2 <= 1'b0;
    end
    else begin
        VIO_AXI_START_reg <= VIO_MSI_START;
        VIO_AXI_START_reg2 <= VIO_AXI_START_reg;
    end
end

//random counter
localparam TEST_CNT_WIDTH = 10;
reg [TEST_CNT_WIDTH-1:0]    test_cnt,rand_delay;
reg delay_start,delay_start_1r, delay_done;

wire delay_done_w;
assign delay_done_w = (test_cnt == rand_delay);

wire delay_start_trig;
assign delay_start_trig = delay_start & (~delay_start_1r);

always @(posedge clk or negedge rstn) begin                                        
    if(!rstn) begin                               
        test_cnt <= {TEST_CNT_WIDTH{1'b0}};
        delay_done <= 1'b0;
        MSI_LED <= 1'b0;
    end
    else if (delay_start) begin
        test_cnt <= test_cnt + 1'b1;
        delay_start_1r<=delay_start; 
        if(delay_done_w) begin
            test_cnt <= {TEST_CNT_WIDTH{1'b0}};
            MSI_LED = ~MSI_LED; //toggle LED everytime demay complete
        end
    end                                     
end

wire [TEST_CNT_WIDTH-1:0] MSI_2_DLY;
//wire [TEST_CNT_WIDTH-1:0] MSI_1_DLY, MSI_2_DLY;
lfsr #(
    .WIDTH  (TEST_CNT_WIDTH),
    .POLY_N (10'hABB),
    .SEED   (10'h34A)
)
lfsrinst0
(
    .clk            (clk),
    .rstn           (rstn),
    .lfsr_enable    (MSI_LED),
    .lfsr_out       (MSI_1_DLY),
    .lfsr_out_r     (MSI_2_DLY),
    .lfsr_bit       ()
);


always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        MASTER_AXI_AWADDR   <= {32'b0,32'h0000_0000};
        MASTER_AXI_AWID     <= {8{1'b0}};
        MASTER_AXI_AWLEN    <= {8{1'b0}};
        MASTER_AXI_AWSIZE   <= {3{1'b0}};
        MASTER_AXI_AWUSER   <= {88{1'b0}};
        MASTER_AXI_AWVALID  <= 1'b0;
        MASTER_AXI_WDATA    <= {256{1'b0}};
        MASTER_AXI_WLAST    <= 1'b0;
        MASTER_AXI_WSTRB    <= {32{1'b0}};
        MASTER_AXI_WVALID   <= 1'b0;
        MASTER_AXI_BREADY   <= 1'b0;
        delay_start         <= 1'b0;
        rand_delay          <= MSI_1_DLY;
        state               <= IDLE;   
    end 
    else begin
        if (state == IDLE) begin
            if (VIO_MSI_START) begin
                    MASTER_AXI_AWADDR <= VIO_MSI_ADDR; 
                    MASTER_AXI_WDATA <= VIO_MSI_DATA << (VIO_MSI_ADDR[5:0]<<3); 
                    MASTER_AXI_AWLEN <= 8'h0;
                    MASTER_AXI_AWSIZE <= 3'h5;
                    MASTER_AXI_AWUSER <= {1'b1,31'b0, 32'b0, 24'h00_0002};
                    MASTER_AXI_WSTRB <=  2'b11 << VIO_MSI_ADDR[5:0];
                    MASTER_AXI_AWVALID <= 1'b1;
                    //MASTER_AXI_BREADY <= 1'b1;
                    state <= MSI_WRITE_1;
                end
       end 
        
        if (state == MSI_WRITE_1) begin
            // if (~MASTER_AXI_BREADY) begin
            //     MASTER_AXI_BREADY <= 1'b1;
            // end

            if (MASTER_AXI_AWVALID && MASTER_AXI_AWREADY) begin
                MASTER_AXI_BREADY <= 1'b1;
                MASTER_AXI_AWVALID <= 1'b0;
                MASTER_AXI_WVALID <= 1'b1;
                MASTER_AXI_WLAST <= 1'b1;
            end
            else if (MASTER_AXI_WVALID && MASTER_AXI_WREADY) begin
                MASTER_AXI_WVALID <= 1'b0;
                MASTER_AXI_WLAST <= 1'b0;

                // state <= MSI_WRITE_2;
                // MASTER_AXI_WDATA <= (VIO_MSI_DATA + 1'b1)<< (VIO_MSI_ADDR[5:0]*8); 
                // MASTER_AXI_AWVALID <= 1'b1;
            end
             else if (MASTER_AXI_BVALID) begin
                MASTER_AXI_BREADY <= 1'b0;
                delay_start <=  1'b1;
                rand_delay <= MSI_1_DLY;
             end
            //wait for random delay
            if (delay_done_w) begin
                delay_start <=  1'b0;
                MASTER_AXI_WDATA <= (VIO_MSI_DATA + 1'b1)<< (VIO_MSI_ADDR[5:0]*8); 
                MASTER_AXI_AWVALID <= 1'b1;
                state <= MSI_WRITE_2;
            end

        end

        if (state == MSI_WRITE_2) begin
            if (MASTER_AXI_AWVALID && MASTER_AXI_AWREADY) begin
                MASTER_AXI_BREADY <= 1'b1;
                MASTER_AXI_AWVALID <= 1'b0;
                MASTER_AXI_WVALID <= 1'b1;
                MASTER_AXI_WLAST <= 1'b1;
            end
            else if (MASTER_AXI_WVALID && MASTER_AXI_WREADY) begin
                MASTER_AXI_WVALID <= 1'b0;
                MASTER_AXI_WLAST <= 1'b0;
                // state <= IDLE;
            end
            else if (MASTER_AXI_BVALID) begin
                MASTER_AXI_BREADY <= 1'b0;
                delay_start <=  1'b1;
                rand_delay <= MSI_2_DLY;
            end  
            if (delay_done_w) begin
                delay_start <=  1'b0;
                state <= IDLE;
            end
        end
    end
end


endmodule
