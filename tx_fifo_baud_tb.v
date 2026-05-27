module tx_fifo_baud_tb (); 
 
    reg clk, rst_n;
    reg [7:0] data_in;
    reg write_en;
    wire fifo_full, fifo_empty, tx_out;

    // Instantiate the tx_fifo_baud module
    tx_fifo_baud uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .write_en(write_en),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty),
        .tx_out(tx_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Testbench stimulus
    initial begin
        rst_n = 0; // Assert reset
        #10;
        rst_n = 1; // Deassert reset

        // Write data into FIFO
        data_in = 8'hA5; // Example data
        write_en = 1;
        #10;

        write_en = 0; // Stop writing

        // Wait for some time to observe FIFO behavior
        repeat (100000) @(negedge clk); 

        $stop; // End simulation
    end

    endmodule