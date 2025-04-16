`timescale 1ns / 1ps

module intersection_controller_tb;
    // Testbench signals
    reg clk, rst;
    reg ns_sensor, ew_sensor;
    reg pd_button_ns, pd_button_ew;

    wire NS_RED, NS_YELLOW, NS_GREEN;
    wire EW_RED, EW_YELLOW, EW_GREEN;
    wire pd_FREE_NS, pd_CAUTION_NS, pd_FREE_EW, pd_CAUTION_EW;
    wire [31:0] time_left_ms_ns, time_left_ms_ew;

    // Instantiate the DUT (Device Under Test)
    intersection_controller dut (
        .clk(clk),
        .rst(rst),
        .ns_sensor(ns_sensor),
        .ew_sensor(ew_sensor),
        .pd_button_ns(pd_button_ns),
        .pd_button_ew(pd_button_ew),
        .NS_RED(NS_RED),
        .NS_YELLOW(NS_YELLOW),
        .NS_GREEN(NS_GREEN),
        .EW_RED(EW_RED),
        .EW_YELLOW(EW_YELLOW),
        .EW_GREEN(EW_GREEN),
        .pd_FREE_NS(pd_FREE_NS),
        .pd_CAUTION_NS(pd_CAUTION_NS),
        .pd_FREE_EW(pd_FREE_EW),
        .pd_CAUTION_EW(pd_CAUTION_EW),
        .time_left_ms_ns(time_left_ms_ns),
        .time_left_ms_ew(time_left_ms_ew)
    );

    // Clock generation (50 MHz)
    always #10 clk = ~clk; // 10ns period => 50MHz clock

    // Testbench procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        ns_sensor = 0;
        ew_sensor = 0;
        pd_button_ns = 0;
        pd_button_ew = 0;

        // Dump waveforms for GTKWave
        $dumpfile("waveform.vcd");
        $dumpvars(0, intersection_controller_tb);

        // Reset system
        #50;
        rst = 0;

        // Scenario 1: No cars, no pedestrians
        #100000;

        // Scenario 2: North-South vehicle detected
        ns_sensor = 1;
        #50000;
        ns_sensor = 0;

        // Scenario 3: East-West vehicle detected
        ew_sensor = 1;
        #50000;
        ew_sensor = 0;

        // Scenario 4: Pedestrian request North-South
        pd_button_ns = 1;
        #50000;
        pd_button_ns = 0;

        // Scenario 5: Pedestrian request East-West
        pd_button_ew = 1;
        #50000;
        pd_button_ew = 0;

        // Let simulation run for a while
        #500000;

        // End simulation
        $finish;
    end
endmodule
