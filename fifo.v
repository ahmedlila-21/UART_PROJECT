module fifo #(
    parameter FIFO_WIDTH = 8,
    parameter FIFO_DEPTH = 512
)(
    input wire clk_a,
    input wire clk_b,
    input wire rst,
    input wire [FIFO_WIDTH-1:0] din_a,
    input wire wen_a,
    input wire ren_b,
    output reg [FIFO_WIDTH-1:0] dout_b,
    output wire full,
    output wire empty
);



reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1 :0];
    reg [$clog2(FIFO_DEPTH):0] wr_ptr ; 
    reg [$clog2(FIFO_DEPTH):0] rd_ptr ;

assign full = ((wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)]) && 
                  (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0])) ;

assign empty = (rd_ptr == wr_ptr) ;

always @(posedge clk_a or posedge rst) begin
    if (rst) begin
        wr_ptr <= 0;
        
    end else if (wen_a && !full) begin
        
        mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= din_a;
        wr_ptr <= wr_ptr + 1;
       
    end
end

always @(posedge clk_b or posedge rst) begin
    if (rst) begin
        dout_b <= 0;
        rd_ptr <= 0;
        
    end else if (ren_b && !empty) begin
        dout_b <= mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
        rd_ptr <= rd_ptr + 1;
       
    end
end

endmodule 



