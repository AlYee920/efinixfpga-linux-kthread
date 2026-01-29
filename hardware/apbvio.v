////////////////////////////////////////////////////////////////////////////
//           _____
//          / _______    Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
//         / /       \
//        / /  ..    /   apbvio.v
//       / / .'     /
//    __/ /.'      /     Description: APB Virtual I/O
//   __   \       /
//  /_/ /\ \_____/ /
// ____/  \_______/
//
// *******************************
// Revisions:
// 0.0 Initial rev
//
// *******************************

module apbvio(
input  wire         apbclk,
input  wire         rstn,

input  wire [23:0]  paddr_i,
input  wire [31:0]  pwdata_i,
input  wire [3:0]   pstrb_i,
input  wire         write_i,
input  wire         start_i,
output reg  [31:0]  APB_PRDATA_reg,

output reg  [23:0]  APB_PADDR,
output reg          APB_PENABLE,
input  wire [31:0]  APB_PRDATA,
input  wire [3:0]   APB_PRDATA_PAR,
input  wire         APB_PREADY,
output reg          APB_PSEL,
input  wire         APB_PSLVERR,
output reg  [3:0]   APB_PSTRB,
output reg          APB_PSTRB_PAR,
output reg  [31:0]  APB_PWDATA,
output reg  [3:0]   APB_PWDATA_PAR,
output reg          APB_PWRITE
);
localparam
	PIDLE = 3'b000,
	PADR  = 3'b001,
	PENA  = 3'b010,
	PRDY  = 3'b011;

reg [2:0] pstates, n_pstates;
always @(pstates or start_trig or APB_PREADY) 
begin
	case (pstates) 
	PIDLE: 	if(start_trig)  n_pstates = PADR;
            else    	    n_pstates = PIDLE;
	PADR: 				    n_pstates = PENA;
	PENA:	if(APB_PREADY)  n_pstates = PRDY;
            else		    n_pstates = PENA;
	PRDY:				    n_pstates = PIDLE;
	endcase
end


always @(posedge apbclk or negedge rstn) 
begin
	if (!rstn) 
    begin
		pstates <= PIDLE;
	end else 
    begin
		pstates <= n_pstates;
	end
end

reg     start_i_reg;
wire    start_trig;
always @(posedge apbclk) begin
    start_i_reg <= start_i;
end
assign start_trig = (~start_i_reg) & start_i;

always @(posedge apbclk or negedge rstn) 
begin
	if (!rstn) 
    begin
		APB_PADDR                 <= 24'd0;
		APB_PSEL                  <= 1'b0;
		APB_PENABLE               <= 1'b0;
		APB_PWRITE                <= 1'b0;
		APB_PWDATA                <= 32'd0;
		APB_PWDATA_PAR            <= 4'd0;
		APB_PSTRB                 <= 4'd0;
		APB_PSTRB_PAR             <= 1'b0;
	end else 
    begin
        if (pstates == PIDLE) 
        begin
            APB_PENABLE           <= 1'b0;
            APB_PWRITE            <= 1'b0;
            APB_PSEL              <= 1'b0;
            APB_PWDATA            <= 32'd0;
            APB_PSTRB             <= 4'd0;
        end
		else if (pstates == PADR) 
        begin
			if (write_i) 
            begin
				APB_PWRITE        <= 1'b1;
				APB_PWDATA        <= pwdata_i;
                APB_PWDATA_PAR[0] <= ~(^APB_PWDATA[0*8+:8]);
                APB_PWDATA_PAR[1] <= ~(^APB_PWDATA[1*8+:8]);
                APB_PWDATA_PAR[2] <= ~(^APB_PWDATA[2*8+:8]);
                APB_PWDATA_PAR[3] <= ~(^APB_PWDATA[3*8+:8]);
				APB_PSTRB         <= pstrb_i;
                APB_PSTRB_PAR     <= ~(^APB_PSTRB);
			end else 
            begin
				APB_PWRITE        <= 1'b0;
			end
            
			APB_PSEL              <= 1'b1;
			APB_PENABLE           <= 1'b0;
			APB_PADDR             <= paddr_i;
		end else if (pstates == PENA) 
        begin
			APB_PADDR             <= APB_PADDR;
			APB_PWRITE            <= APB_PWRITE;
			APB_PWDATA            <= APB_PWDATA;
			APB_PSTRB             <= APB_PSTRB;
			if (APB_PREADY & APB_PENABLE) 
            begin
				APB_PENABLE       <= 1'b0;
				APB_PSEL          <= 1'b0;
                APB_PRDATA_reg    <= APB_PRDATA;  
			end else 
            begin
				APB_PENABLE       <= 1'b1;
				APB_PSEL          <= APB_PSEL;	
			end	
		end else if (pstates == PRDY) 
        begin
			APB_PENABLE           <= 1'b0;
			APB_PWRITE            <= 1'b0;
			APB_PSEL              <= 1'b0;
			APB_PWDATA            <= 32'd0;
			APB_PSTRB             <= 4'd0;
        end
    end
end
endmodule