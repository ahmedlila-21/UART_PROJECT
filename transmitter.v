module transmitter #(
    parameter IDLE  = 2'b00,
    parameter START = 2'b01,
    parameter DATA  = 2'b10,
    parameter STOP  = 2'b11
)(

    input clk, rst_n, 
    input tx_tick,              
    input [7:0] tx_data,
    input tx_start,
    output reg tx_busy,
    output reg tx_done,
    output reg tx_ready,
    output reg tx_out

);

reg [1:0] cs, ns;
reg [3:0] bit_count;
reg [8:0] data_reg; // extended to 9 bits for parity bit 

// State machine for transmitter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs <= IDLE;
        tx_busy <= 0;
        tx_done <= 0;
        tx_ready <= 1;
        tx_out <= 1; // Idle state for TX line
        bit_count <= 0;
        data_reg <= 0;
    end else if (tx_tick) begin   // enable with tx_tick
        cs <= ns;
    end
end

// Next state logic
always @(*) begin
    case (cs)
        IDLE: begin
            if (tx_start && tx_ready) begin
                ns = START;
            end else begin
                ns = IDLE;
            end
        end
        START : begin 
            ns = DATA;
        end
        DATA : begin
            if (bit_count == 8) begin
                ns = STOP;
            end else begin
                ns = DATA;
            end
        end

        STOP : begin
            if (!tx_start)
                ns = IDLE;
            else 
                ns = START;
        end
        default: ns = IDLE;
    endcase
end


// Output logic and data handling
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin
        tx_busy   <= 0;
        tx_done   <= 0;
        tx_ready  <= 1;
        tx_out    <= 1;
        bit_count <= 0;
        data_reg  <= 0;
    end else if (tx_tick) begin   // enable with tx_tick
        case (cs)
            IDLE: begin
                tx_busy <= 0;
                tx_done <= 0;  // pulsa done when transmission is complete
                tx_ready <= 1;
                tx_out <= 1; // Idle state for TX line
                bit_count <= 0; // Reset bit count
                
            end
            START: begin
                data_reg <=  {tx_data , 1'b0 }; // Load data to be transmitted and set parity bit to 0
                tx_busy <= 1;
                tx_ready <= 0;
                tx_out <= 0; // Start bit
                bit_count <= 0; // Reset bit count
                
                data_reg [0] <= ^data_reg [8:1]; //  parity bit calculation
            end
            DATA: begin
                tx_out <= data_reg[bit_count]; // Transmit data bit
                bit_count <= bit_count + 1; 
            end
            STOP: begin
                tx_out <= 1; // Stop bit
                tx_busy <= 0; // Transmission complete
                tx_done <= 1; // Indicate transmission done
                tx_ready <= 1; // Ready for next transmission
                bit_count <= 0; // Reset bit count for next transmission
            end
            default: begin
                tx_busy <= 0;
                tx_done <= 0;
                tx_ready <= 1;
                tx_out <= 1; // Idle state for TX line
            end
        endcase
    end
end

endmodule 
/*module transmitter #(
    parameter IDLE = 2'b00,
    parameter START = 2'b01,
    parameter DATA = 2'b10,
    parameter STOP = 2'b11
)(

    input tx_tick, rst_n, 
    input [7:0] tx_data,
    input tx_start,
    output reg tx_busy,
    output reg tx_done,
    output reg tx_ready,
    output reg tx_out

);

reg [1:0] cs, ns;
reg [3:0] bit_count;
reg [8:0] data_reg; // extended to 9 bits for parity bit 

// State machine for transmitter
always @(posedge tx_tick or negedge rst_n) begin
    if (!rst_n) begin
        cs <= IDLE;
        tx_busy <= 0;
        tx_done <= 0;
        tx_ready <= 1;
        tx_out <= 1; // Idle state for TX line
        bit_count <= 0;
        data_reg <= 0;
    end else begin
        cs <= ns;
    end
end

// Next state logic
always @(*) begin
    case (cs)
        IDLE: begin
            if (tx_start && tx_ready) begin
                ns = START;
            end else begin
                ns = IDLE;
            end
        end
        START : begin 
            ns = DATA;
        end
        DATA : begin
            if (bit_count == 8) begin
                ns = STOP;
            end else begin
                ns = DATA;
            end
        end

        STOP : begin
            if (!tx_start)
            ns = IDLE;
            else 
            ns = START;
        end
        default: ns = IDLE;
    endcase
end


// Output logic and data handling

always @(posedge tx_tick) begin 
    case (cs)
        IDLE: begin
            tx_busy <= 0;
            tx_done <= 0;  // pulsa done when transmission is complete
            tx_ready <= 1;
            tx_out <= 1; // Idle state for TX line
            bit_count <= 0; // Reset bit count
            data_reg <=  {tx_data , 1'b0 }; // Load data to be transmitted and set parity bit to 0
        end
        START: begin
            tx_busy <= 1;
            tx_ready <= 0;
            tx_out <= 0; // Start bit
            bit_count <= 0; // Reset bit count
            
            data_reg [0] <= ^data_reg [8:1]; //  parity bit calculation
        end
        DATA: begin
            tx_out <= data_reg[bit_count]; // Transmit data bit
            bit_count <= bit_count + 1; 

        end
        STOP: begin
            tx_out <= 1; // Stop bit
            tx_busy <= 0; // Transmission complete
            tx_done <= 1; // Indicate transmission done
            tx_ready <= 1; // Ready for next transmission
            bit_count <= 0; // Reset bit count for next transmission
        end
        default: begin
            tx_busy <= 0;
            tx_done <= 0;
            tx_ready <= 1;
            tx_out <= 1; // Idle state for TX line
        end

    endcase
end



endmodule */







