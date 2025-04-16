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
    always #10 clk = ~clk; // 20ns period -> 50MHz

    // Button/sensor press task
    task press_button(input reg button);
        begin
            button = 1;
            #50000;
            button = 0;
        end
    endtask

    // Sensor trigger task
    task trigger_sensor(input reg sensor);
        begin
            sensor = 1;
            #50000;
            sensor = 0;
        end
    endtask

    // Testbench procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        ns_sensor = 0;
        ew_sensor = 0;
        pd_button_ns = 0;
        pd_button_ew = 0;

        // Dump waveforms
        $dumpfile("waveform.vcd");
        $dumpvars(0, intersection_controller_tb);
        $dumpvars(0, dut);

        // Reset system
        #50;
        rst = 1;
        #100;
        rst = 0;

        // Scenario 1: Idle state
        #100000;

        // Scenario 2: NS car triggers sensor
        trigger_sensor(ns_sensor);

        // Scenario 3: EW car triggers sensor
        trigger_sensor(ew_sensor);

        // Scenario 4: Pedestrian presses NS button
        press_button(pd_button_ns);

        // Scenario 5: Pedestrian presses EW button
        press_button(pd_button_ew);

        // Wait and observe
        #500000;

        $finish;
    end
endmodule
