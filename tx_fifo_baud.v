module tx_fifo_baud (
    input wire clk, rst_n,

    input wire [7:0] data_in,
    input wire write_en,
    output wire fifo_full,
    output wire fifo_empty,
    output wire tx_out
);


    wire tx_tick;
    wire [7:0] fifo_dout;
    reg fifo_ren;

    // TX signals
    reg tx_start;
    wire tx_busy, tx_done, tx_ready;

    // =================
    // baud generator instance
    // =================
    baud_generator baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_tick(tx_tick)
    );

    // =================
    // FIFO instance
    // =================
    fifo #(8, 512) fifo_inst (
        .clk_a(clk),
        .clk_b(clk),
        .rst(~rst_n),
        .din_a(data_in),
        .wen_a(write_en),
        .ren_b(fifo_ren),
        .dout_b(fifo_dout),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    // =================
    // Transmitter instance
    // =================
    transmitter tx_inst (
        .clk(clk),
        .tx_tick(tx_tick),
        .rst_n(rst_n),
        .tx_data(fifo_dout),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_out(tx_out)
    );

    // =================
    // Control Logic
    // =================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_ren <= 0;
            tx_start <= 0;
        end 
        if ( tx_tick ) 
            if (!fifo_empty && tx_ready) begin
                fifo_ren <= 1;       // pop data from FIFO
                tx_start <= 1;       // start transmission
            end else begin
                 fifo_ren <= 0;
                 tx_start <= 0;
            end

    end
  

endmodule
