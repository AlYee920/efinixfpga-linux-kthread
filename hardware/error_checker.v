/////////////////////////////////
// Written by aytan
// increment pattern checker
/////////////////////////////////

module error_checker #(
parameter CNT_WIDTH = 8
)
(
input wire                  clk, rstn,
input wire [CNT_WIDTH-1:0]  data_in,
input wire                  data_valid,


output reg [CNT_WIDTH-1:0]  err_count
);

reg [CNT_WIDTH-1:0] count_r, data_reg,count_r2;

always@(posedge clk or negedge rstn) begin 
    if (~rstn) begin
        count_r <= {CNT_WIDTH{1'b0}};
        count_r2 <= {CNT_WIDTH{1'b0}};
        err_count <= {CNT_WIDTH{1'b0}};
        data_reg <= {CNT_WIDTH{1'b0}};
    end
    else begin
        if (data_valid) begin
            data_reg <= data_in;
            count_r2 <= count_r;
          if (data_reg != count_r2) begin
                count_r <= data_in+1'b1;
                err_count = err_count + 1'b1;
            end
            else begin
                count_r <= count_r+1'b1;
            end
        end
    end
end

endmodule