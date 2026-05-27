
module rx_fifo_baud_tb();

    reg clk;
    reg rst_n;
    reg rxd;
    reg ren_b;
    wire [7:0] dout_b;
    wire fifo_empty;
    wire fifo_full;
    wire rx_err_frame;
    wire rx_err_parity;

    // DUT
    rx_fifo_baud #(
        .FIFO_WIDTH(8),
        .FIFO_DEPTH(16)   // small depth for sim
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rxd(rxd),
        .ren_b(ren_b),
        .dout_b(dout_b),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .rx_err_frame(rx_err_frame),
        .rx_err_parity(rx_err_parity)
    );

    // 50MHz clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        // init
        rst_n = 0;
        rxd   = 1;   // idle
        ren_b = 0;
        #100;
        rst_n = 1;

        // ===== Send 1 byte = 0x55 (01010101) =====
        // start bit
        rxd = 0;  #8680;
        // bit0
        rxd = 1;  #8680;
        // bit1
        rxd = 0;  #8680;
        // bit2
        rxd = 1;  #8680;
        // bit3
        rxd = 0;  #8680;
        // bit4
        rxd = 1;  #8680;
        // bit5
        rxd = 0;  #8680;
        // bit6
        rxd = 1;  #8680;
        // bit7
        rxd = 0;  #8680;
        // stop bit
        rxd = 1;  #8680;

        // wait to push into FIFO
        #50000;

        // read out from FIFO
        ren_b = 1;
        #20;
        ren_b = 0;

        #1000;
        $finish;
    end

endmodule
