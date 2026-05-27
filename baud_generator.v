module baud_generator #(
    parameter NTX = 434,
    parameter NRX = 27 // for 115200 baud rare and 50mhz clock 
)(
    input clk,
    input rst_n,
    output reg tx_tick,
    output reg rx_tick
);

reg [8:0] tx_counter;
reg [4:0] rx_counter;


// Generate TX tick based on the NTX value
always @( posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        tx_counter <= 0;
        tx_tick <= 0;
    end else begin
        if (tx_counter == NTX - 1) begin
            tx_counter <= 0;
            tx_tick <= 1;
        end else begin
            tx_counter <= tx_counter + 1;
            tx_tick <= 0;
        end
    end
    
end





// Generate RX tick based on the NRX value
always @( posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        rx_counter <= 0;
        rx_tick <= 0;
    end else begin
        if (rx_counter == NRX - 1) begin
            rx_counter <= 0;
            rx_tick <= 1;
        end else begin
            rx_counter <= rx_counter + 1;
            rx_tick <= 0;
        end
    end
    
end





endmodule