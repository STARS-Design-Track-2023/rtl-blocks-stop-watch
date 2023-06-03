`default_nettype none

`timescale 1ms/100us
module tb();

enum logic[2:0] {IDLE = 3'b100, CLEAR = 3'b010, RUNNING = 3'b001} MODE_TYPES; 

localparam CLK_PERIOD = 10; // 100 Hz clk

integer tb_test_num;
string tb_test_case; 


// TB Signals

logic[4:0] tb_time_o; 
logic [2:0] tb_mode; 
logic tb_clk, tb_Rst_i; 
logic tb_button_i; 


task single_button_press;
begin
    @(negedge tb_clk);
    tb_button_i = 1'b1; 
    @(negedge tb_clk);
    tb_button_i = 1'b0; 
    @(posedge tb_clk); 
end
endtask

task check_mode;
input logic[2:0] expected_mode; 
input string string_mode; 
begin
    @(negedge tb_clk); 
    if(tb_mode == expected_mode)
        $display("Correct Mode: %s.", string_mode);
    else
        $error("Incorrect mode. Expected %s.", string_mode); 
end
endtask

task reset_dut;
    @(negedge tb_clk);
    tb_Rst_i = 1'b1; 
    @(negedge tb_clk); 
    tb_Rst_i = 1'b0; 
endtask

task check_time_o;
input logic[4:0] exp_time_o; 
begin
    @(negedge tb_clk); 
    if(tb_time_o == exp_time_o)
        $display("Correct time_o: %0d.", exp_time_o);
    else
        $error("Incorrect mode. Expected %0d. Actual: %0d", exp_time_o, tb_time_o); 
end
endtask


always begin
    tb_clk = 1'b0; 
    #(CLK_PERIOD / 2);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2); 
end


stop_watch DUT(.clk(tb_clk),
               .Rst_i(tb_Rst_i),
               .button_i(tb_button_i),
               .mode(tb_mode),
               .time_o(tb_time_o)); 

initial begin

    $dumpfile("stop_watch.vcd");
    $dumpvars; 

    tb_button_i = 1'b0; 
    tb_Rst_i = 1'b1; 
    tb_test_num = 0; 
    tb_test_case = "Initializing"; 


    // TEST CASE 1: Iterating through the different modes
    reset_dut; 
    tb_test_num += 1; 
    $display("\n\nTEST CASE1: Iterating through the different modes\n\n");
    check_mode(IDLE, "IDLE"); 

    single_button_press; 
    #(CLK_PERIOD * 5); // allow for sync + edge det + fsm delay 
    check_mode(CLEAR, "CLEAR"); 

    single_button_press; 
    #(CLK_PERIOD * 5);
    check_mode(RUNNING, "RUNNING"); 

    single_button_press; 
    #(CLK_PERIOD * 5);
    check_mode(IDLE, "IDLE"); 
    

    // TEST CASE 2: Only Changes Modes during Rising edges
    $display("\n\nTEST CASE 2: Stop watch changes mode once for each button press\n\n");

    tb_test_num += 1; 
    reset_dut;

    @(negedge tb_clk); 
    tb_button_i = 1'b1;

    #(CLK_PERIOD * 20); 
    check_mode(CLEAR, "CLEAR"); 
    @(negedge tb_clk); 
    tb_button_i = 1'b0; 

    // TEST CASE 3: simple usage 
    $display("\n\nTEST CASE 3: Simple usage\n\n");
    tb_test_num += 1; 
    reset_dut; 
    single_button_press; 
    single_button_press; 

    // should be in the running state right now

    @(posedge tb_clk); 
    #(1000 * 15.5); // leave 500 ms for delay
    check_time_o(5'd15);

    #(1000 * 16); 
    check_time_o(5'd31); 

    #(1000 * 1); 
    check_time_o(5'd0); // test that it wraps around

    #(1000 * 23); 
    check_time_o(5'd23); 

    single_button_press; 

    // Test Idle Mode
    #(CLK_PERIOD * 5); 
    check_mode(IDLE, "IDLE"); 
    check_time_o(5'd23); 

    single_button_press; 
    #(CLK_PERIOD * 5); 
    check_mode(CLEAR, "CLEAR");
    check_time_o(5'd0); 

    $finish; 
end

endmodule 