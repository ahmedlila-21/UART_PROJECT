module rx_fifo_baud #(
    parameter FIFO_WIDTH = 8,
    parameter FIFO_DEPTH = 512
)(
    input  wire clk,        // system clock for receiver
    input  wire rst_n,      // async reset
   
    input  wire rxd,        // serial input

    // FIFO read side
    input  wire ren_b,      // read enable
    output wire [FIFO_WIDTH-1:0] dout_b, // read data
    output wire fifo_empty,
    output wire fifo_full,

    // Error flags
    output wire rx_err_frame,
    output wire rx_err_parity
);
      wire rx_tick;

    // =================
    // baud generator instance
    // =================
    baud_generator baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_tick(rx_tick)
    );


    // -------------------------
    // Internal signals
    // -------------------------
    wire        rx_ready;
    wire        rx_valid;
    wire        rx_done;
    wire [7:0]  rx_data;
    wire        wen_a;  // fifo write enable

    // -------------------------
    // UART Receiver Instance
    // -------------------------
    reciver u_rx (
        .clk(clk),
        .rx_tick(rx_tick),
        .rst_n(rst_n),
        .rxd(rxd),
        .rx_ready(rx_ready),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_err_frame(rx_err_frame),
        .rx_err_parity(rx_err_parity)
    );

    // -------------------------
    // FIFO Instance
    // -------------------------
    assign wen_a = rx_done;  // Write into FIFO only when rx_done pulses

    fifo #(
        .FIFO_WIDTH(FIFO_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_fifo (
        .clk_a(clk),          // Receiver clock domain (write)
        .clk_b(clk),        
        .rst(!rst_n),         // FIFO reset is active-high
        .din_a(rx_data),      // Data from receiver
        .wen_a(wen_a),        // Write when rx_done=1
        .ren_b(ren_b),        // Read enable
        .dout_b(dout_b),      // Output data
        .full(fifo_full),     // FIFO full flag
        .empty(fifo_empty)    // FIFO empty flag
    );

endmodule
