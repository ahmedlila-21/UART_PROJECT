module uart_top (
    input  wire        clk,
    input  wire        rst_n,

    // TX FIFO interface
    input  wire [7:0]  tx_din,
    input  wire        tx_wen,
    output wire        tx_full,
    output wire        tx_empty,

    // RX FIFO interface
    output wire [7:0]  rx_dout,
    input  wire        rx_ren,
    output wire        rx_empty,
    output wire        rx_full,
    output wire        rx_err_frame,
    output wire        rx_err_parity,

    // UART serial lines
    output wire        txd,
    input  wire        rxd
);

    //----------------------------------
    // Baud Generator
    //----------------------------------
    wire tx_tick;
    wire rx_tick;

    baud_generator #(
        .NTX(434),     // for 115200 baud @ 50MHz
        .NRX(27)
    ) baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_tick(tx_tick),
        .rx_tick(rx_tick)
    );

    //----------------------------------
    // TX FIFO + Transmitter
    //----------------------------------
    tx_fifo tx_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(tx_din),
        .write_en(tx_wen),
        .fifo_full(tx_full),
        .fifo_empty(tx_empty),
        .tx_tick(tx_tick),
        .tx_out(txd)
    );


    //----------------------------------
    // RX FIFO + Receiver
    //----------------------------------
    rx_fifo rx_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rxd(rxd),
        .rx_tick(rx_tick),
        .dout_b(rx_dout),
        .ren_b(rx_ren),
        .fifo_empty(rx_empty),
        .fifo_full(rx_full),
        .rx_err_frame(rx_err_frame),
        .rx_err_parity(rx_err_parity)
    );

endmodule
