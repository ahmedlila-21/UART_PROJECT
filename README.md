This system is a complete UART transceiver implemented in Verilog, containing a baud generator, transmitter, receiver, and TX/RX FIFOs for serial communication.
The transmitter converts parallel data to serial data, while the receiver converts serial data back to parallel using FSM-based control and 16× oversampling for accurate sampling.
Its features include parity checking, frame error detection, synchronizer registers for metastability protection, and FIFOs to buffer data and prevent data loss during speed mismatch.

 the pdf file "my_uart" contain explanation for the design and the waveforms for visulization and full synthesize with vivade tool 

there is a do file can use to run the whole design 
