

module uart_tb;

    reg clk;
    reg rst_n;

    // TX side
    reg  [7:0] tx_din;
    reg        tx_wen;
    wire       tx_full;
    wire       tx_empty;

    // RX side
    wire [7:0] rx_dout;
    reg        rx_ren;
    wire       rx_empty;
    wire       rx_full;
    wire       rx_err_frame;
    wire       rx_err_parity;

    // UART lines
    wire txd;
    wire rxd;

    // DUT
    uart_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_din(tx_din),
        .tx_wen(tx_wen),
        .tx_full(tx_full),
        .tx_empty(tx_empty),
        .rx_dout(rx_dout),
        .rx_ren(rx_ren),
        .rx_empty(rx_empty),
        .rx_full(rx_full),
        .rx_err_frame(rx_err_frame),
        .rx_err_parity(rx_err_parity),
        .txd(txd),
        .rxd(rxd)
    );

    // loopback
    assign rxd = txd;

    // clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk;   // 50 MHz
    end

    // stimulus
    initial begin
        rst_n = 0;
        tx_din = 0;
        tx_wen = 0;
        rx_ren = 0;
        #100;
        rst_n = 1;

        // write a byte into TX
        #100;
        tx_din = 8'h55;   // send 0x55
        tx_wen = 1;
        #20;
        tx_wen = 0;
        // read received byte


        // wait some time for UART transmission
        #150000;

        // read received byte
        if (!rx_empty) begin
            rx_ren = 1;
            #20;
            rx_ren = 0;
        end

        #10000;
        
        $stop;
    end

endmodule
