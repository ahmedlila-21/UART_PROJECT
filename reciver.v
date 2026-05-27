module reciver #(
    parameter IDLE = 2'b00,
    parameter START = 2'b01,
    parameter DATA = 2'b10,
    parameter STOP = 2'b11
)(
    input clk,rx_tick, rst_n,
    input rxd,
    output reg rx_ready,  // Indicates the receiver is ready to receive data
    output reg rx_valid , // Indicates that the received data is valid for register
    output reg [7:0] rx_data,
    output reg rx_done, // Indicates that data reception is complete and valid from register for fifo
    output reg rx_err_frame , // Indicates if there was a framing error
    output reg rx_err_parity // Indicates if there was a parity error

);

reg rxd_r;
reg rxd_synch; // For synchronizing the rxd signal

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rxd_synch <= 1'b1; // Default to idle state
    end else begin
        rxd_r <= rxd; 
        rxd_synch <= rxd_r; // Synchronize the rxd signal
    end
end

reg rx_valid_r1, rx_valid_r2 , rx_valid_pulse ; // Registers to create a pulse for rx_valid
reg [1:0] cs, ns;
reg [3:0] bit_count;
reg [4:0] rx_counter;
reg [8:0] data_reg; 

// State machine for receiver
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs <= IDLE;
        rx_ready <= 1;
        rx_valid <= 0;
        rx_done <= 0;
        bit_count <= 0;
        rx_counter <= 0;
        data_reg <= 0;
        rx_err_frame <= 0;
        rx_err_parity <= 0;
        rx_data <= 0;
        
    end else begin
        cs <= ns;
    end
end

// Next state logic

always @ (*)begin
    case (cs) 
        IDLE : begin 
            if (!rxd_synch && rx_ready) begin 
                ns = START ;
            end else begin
                ns = IDLE;
            end 
        end 
        START : begin 

            if (rx_counter == 8) begin 
            
                if (rxd_synch == 1'b0) begin     
                    rx_counter <= 0;  // reset counter, found the middle
                    ns <= DATA; // go to data state
                end else 
                    ns <= IDLE; // if not found, stay in idle
              end

          end 

        DATA : begin
            if (bit_count == 9) begin
                ns = STOP;
            end else begin
                ns = DATA;
            end
        end 

        STOP : begin
        if  ( rx_counter == 9 ) begin
            rx_counter = 0; // reset counter
            ns = IDLE; // After stop bit, go back to idle
        end else
            ns = STOP; // Stay in stop state until the stop bit is received
            
        end
        default: ns = IDLE;
    endcase
end

// Output logic

always @(posedge clk ) begin 
    case (cs)
        IDLE : begin 
            rx_ready <= 1;
            rx_valid <= 0;
            rx_done <= 0;
            bit_count <= 0;
            rx_counter <= 0; // Reset the counter
            data_reg <= 0;
            rx_err_frame <= 0;
            rx_err_parity <= 0;
        end

        START : begin 
            rx_ready <= 0; // Not ready to receive data
             if (rx_tick) rx_counter <= rx_counter + 1;
        end

        DATA : begin 
      
            if (rx_tick) begin

                if  ( rx_counter == 16 ) begin
                data_reg[bit_count] <= rxd_synch; // Capture the data bit after 16 rx_ticks from checkin the start bit but after the 8 rx_ticks from the tx_tick high 
                bit_count <= bit_count + 1;
                rx_counter <= 0;
                end else begin 
                rx_counter <= rx_counter + 1; // Increment the counter
                end
            end
        end
        STOP : begin
             if  ( rx_counter == 8 ) begin
                if (rxd_synch == 1'b1) begin // Check for stop bit
                   rx_valid_pulse <= (rx_valid_r1)  & ( ~ rx_valid_r2); // pulse for one clk 
                   rx_valid <= 1; // Data is valid 
                   rx_err_frame <= 0; // No framing error
               end else begin
                    rx_err_frame <= 1; // Framing error if stop bit is not high
                    rx_valid <= 0;
               end
             end

          if (rx_tick) begin

                    rx_counter <= rx_counter + 1; // Increment the counter

          end
           
         
            
            // Check for parity error 
            if ( ^data_reg == 1) begin // Check parity 
                rx_err_parity <= 1; // Parity error
            end else begin
                rx_err_parity <= 0; // No parity error
            end

            
        end
        default: begin
            rx_ready <= 1;
            rx_valid <= 0;
            rx_done <= 0;
            bit_count <= 0;
            data_reg <= 0;
            rx_err_frame <= 0;
            rx_err_parity <= 0;
        end

    endcase
    end



 // store the date to register if rx_valid high

always @ (posedge clk ) begin 

    if (rx_valid_pulse) begin
        rx_done <= 1; // Data reception is complete and indicate the fifo
        rx_data <= data_reg [8:1]; // Store the received data without the parity bit
    end else begin
        rx_done <= 0;
    end
end 

// register rx_valid to make pulse 



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_valid_r1 <= 0;
        rx_valid_r2 <= 0;
    end else begin
        rx_valid_r1 <= rx_valid;
        rx_valid_r2 <= rx_valid_r1;
    end
end






endmodule

   
