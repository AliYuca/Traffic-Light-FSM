`timescale 1ns/1ps

module tb_traffic_light();
    logic clk;
    logic reset;
    logic TAORB;
    logic [1:0] LA, LB;

    // Instantiate the Module Under Test (DUT)
    traffic_light dut (
        .clk(clk),
        .reset(reset),
        .TAORB(TAORB),
        .LA(LA),
        .LB(LB)
    );

    // Generate Clock Signal (Toggle every 5ns for a 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk = 0;
        reset = 1;
        TAORB = 1; // Traffic exists on Street A

        // Apply Reset
        #20 reset = 0;

        // Scenario 1: Wait while there is traffic on Street A (Should stay in S0)
        #50;

        // Scenario 2: Street A becomes empty (TAORB = 0) -> Should transition to S1
        TAORB = 0;
        
        // Observe waiting for 5 clock cycles in S1 (Yellow light duration)
        #100;

        // Scenario 3: While Street B is green (S2), traffic arrives on A (TAORB = 1) -> Should move to S3
        TAORB = 1;
        
        // Observe waiting for 5 clock cycles in S3
        #100;

        $display("Simulation completed.");
        $stop;
    end
endmodule