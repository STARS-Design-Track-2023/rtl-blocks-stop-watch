# Stop Watch Module

# Specifications

Module name: stop_watch

Module Inputs:
- logic clk 
- logic Rst_i
- logic button_i

Module Ouputs:
- logic[2:0] mode
- logic[4:0] time_o
  
The clock provided to your module will be a 100 Hz clock. 

The mode output needs to be 3'b100 when the state of the stop watch is Idle, 3'b010 when the state is Clear, and 3'b001 when the state is Running. 

The time_o outputs needs to count to go from 0 (5'b00000) to 31 (5'b11111) and wrap up arround back to 0. 


# Behavior

- When the state of the stop watch is Idle the time_o value should not change.

- When the state of the stop watch is Clear the time_o value should be cleared to 0. 

- When the state of the stop watch is running, the time_o value should increment by every second and wrap around to the value 0.


# Instructions 

1. Prepare an RTL diagram for your stop_watch module and have it approved by a TA. 
2. Prepare a timing diagram using wavedrom that illustrates the operation of your stop watch module and have it approved by a TA. 
3. implement your stop_watch module and other supporting modules you need in the top.sv file underneath the top module. 
4. To test your module, type the following command in your terminal:
      - make verify 
  
This is going to pass your design through a testbench that will test whether your design meets the specifications. In the terminal, you should see the test cases as well as whether you passed them or not.

To help you debug your design, type the following command to show the waveforms for your design as well as the test inputs:
   - make view_waveforms

This will open up gtkwave and show the traces for your modules inputs and outputs. Look through those traces to help you debug your design. 
    
5. After you are module is working correctly, and you are not getting any error messages after running 'make verify', you can move on to the next section of implementing the design on the FPGA. 


# Implementation on FPGA 

To implement your design on the FPGA, instantiate it within the top module in top.sv. 

Make the following connections in the top module:
   - connect the clk input to hz100 (this is the 100 Hz clk of the FPGA)
   - connect Rst_i to pb[0].
   - connect button_i to pb[1]. 
   - connect time_o to right[4:0].
   - connect mode to left[2:0]

After you have made all the connections and instantiated your stop watch module within the top module, you can flash you design to the FPGA by running the following command in your terminal: 
   - make 

Demo your design to a TA


# Optional Steps

If you have time, try to display the time_o value in decimal to the seven segment displays on the FPGA. 

You will probably need to write extra modules that will decode the decimal digits to the FPGA as well convert the binary representation to BCD representation. 


The final output should be something like this when the stop watch is in the running state:



<img src="./imgs/fpga_implementation.jpg" alt="fpga implementations" height=300>