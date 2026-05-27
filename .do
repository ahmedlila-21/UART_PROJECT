
vlib work
vlog baud_generator.v fifo.v reciver.v rx_fifo.v transmitter.v tx_fifo.v uart_top.v uart_tb.v
vsim -voptargs=+acc work.uart_tb
add wave *
add wave -position insertpoint  \
sim:/uart_tb/dut/tx_fifo_inst/tx_tick \
sim:/uart_tb/dut/tx_fifo_inst/tx_out \
sim:/uart_tb/dut/tx_fifo_inst/fifo_ren \
sim:/uart_tb/dut/tx_fifo_inst/tx_start \
sim:/uart_tb/dut/tx_fifo_inst/tx_busy \
sim:/uart_tb/dut/tx_fifo_inst/tx_done \
sim:/uart_tb/dut/tx_fifo_inst/tx_ready\
sim:/uart_tb/dut/rx_fifo_inst/ren_b \
sim:/uart_tb/dut/rx_fifo_inst/fifo_empty \
sim:/uart_tb/dut/rx_fifo_inst/rx_ready \
sim:/uart_tb/dut/rx_fifo_inst/rx_valid \
sim:/uart_tb/dut/rx_fifo_inst/rx_done \
sim:/uart_tb/dut/rx_fifo_inst/rx_data \
sim:/uart_tb/dut/rx_fifo_inst/wen_a\
sim:/uart_tb/dut/rx_fifo_inst/u_rx/rx_data \
sim:/uart_tb/dut/rx_fifo_inst/u_rx/rx_done \
sim:/uart_tb/dut/rx_fifo_inst/u_rx/bit_count \
sim:/uart_tb/dut/rx_fifo_inst/u_rx/rx_counter \
sim:/uart_tb/dut/rx_fifo_inst/u_rx/data_reg
run -all
#quit -sim