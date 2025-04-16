`define ON  1'b1
`define OFF 1'b0

module intersection_controller (
  input clk,                                // Clock signal
  input rst,                                // Reset signal

    // Vehicle and pedestrian inputs
  input ns_sensor,                          // North-South vehicle sensor
  input ew_sensor,                          // East-West vehicle sensor
  input pd_button_ns,                       // North-South pedestrian button
  input pd_button_ew,                       // East-West pedestrian button

    // Vehicle light outputs
  output NS_RED,                            // North-South red light
  output NS_YELLOW,                         // North-South yellow light
  output NS_GREEN,                          // North-South green light
  output EW_RED,                            // East-West red light
  output EW_YELLOW,                         // East-West yellow light
  output EW_GREEN,                          // East-West green light

    // Pedestrian light outputs
  output pd_FREE_NS,                        // North-South pedestrian free walk
  output pd_CAUTION_NS,                     // North-South pedestrian caution
  output pd_FREE_EW,                        // East-West pedestrian free walk
   output pd_CAUTION_EW,                     // East-West pedestrian caution

    // Pedestrian timer outputs
  output [31:0] time_left_ms_ns,            // Time left for North-South pedestrian
  output [31:0] time_left_ms_ew             // Time left for East-West pedestrian
);

// Local parameters for configuration
    localparam CLK_FREQ = 50_000_000;         // Clock frequency in Hz
    localparam BASE_TIME_DELAY = 200;         // Base delay for green light (ms)
    localparam YELLOW_DELAY_TIME = 40;        // Delay for yellow light (ms)
    localparam FREE_WALK_PERCENT = 70;        // Percentage of green time for pedestrian free walk

    // Internal signals
    wire [31:0] ns_green_delay;               // Dynamic green delay for North-South
    wire [31:0] ew_green_delay;               // Dynamic green delay for East-West

// Adaptive Time Delay Instantiation
    adaptive_time_delay #(
        .CLK_FREQ(CLK_FREQ),
        .BASE_TIME_DELAY(BASE_TIME_DELAY)
    ) DYNAMIC_DELAY_CALCULATOR (
        .clk(clk),
        .rst(rst),
        .NS_SENSOR(ns_sensor),
        .EW_SENSOR(ew_sensor),
        .NS_GREEN_DELAY(ns_green_delay),
        .EW_GREEN_DELAY(ew_green_delay)
    );

// Base Traffic Controller Instantiation
    base_fsm #(
        .YELLOW_DELAY_TIME(YELLOW_DELAY_TIME),
        .CLK_FREQ(CLK_FREQ)
    ) TRAFFIC_LIGHT_CONTROLLER (
        .clk(clk),
        .rst(rst),
        .NS_GREEN_DELAY(ns_green_delay),
        .EW_GREEN_DELAY(ew_green_delay),
        .NS_RED(NS_RED),
        .NS_YELLOW(NS_YELLOW),
        .NS_GREEN(NS_GREEN),
        .EW_RED(EW_RED),
        .EW_YELLOW(EW_YELLOW),
        .EW_GREEN(EW_GREEN)
    );

// Pedestrian Light Controller
    // Internal Signals for Pedestrian Light Controller
    wire [31:0] pd_total_cycles_ns;           // Total cycles for North-South pedestrian
    wire [31:0] pd_free_cycles_ns;            // Free walk cycles for North-South
    wire [31:0] pd_total_cycles_ew;           // Total cycles for East-West pedestrian
    wire [31:0] pd_free_cycles_ew;            // Free walk cycles for East-West
    wire [31:0] pd_current_counter_ns;        // Current counter for North-South pedestrian
    wire [31:0] pd_current_counter_ew;        // Current counter for East-West pedestrian

    // Pedestrian Light Controller Instantiation
    pedestrian_light_controller #(
        .CLK_FREQ(CLK_FREQ),
        .FREE_WALK_PERCENT(FREE_WALK_PERCENT)
    ) PEDESTRIAN_LIGHT_CONTROLLER (
        .clk(clk),
        .rst(rst),
        .pd_button_ns(pd_button_ns),
        .pd_button_ew(pd_button_ew),
        .ns_green_delay(ns_green_delay),
        .ew_green_delay(ew_green_delay),
        .NS_RED(NS_RED),
        .EW_RED(EW_RED),
        .pd_FREE_NS(pd_FREE_NS),
        .pd_CAUTION_NS(pd_CAUTION_NS),
        .pd_FREE_EW(pd_FREE_EW),
        .pd_CAUTION_EW(pd_CAUTION_EW),
        .pd_total_cycles_ns(pd_total_cycles_ns),
        .pd_free_cycles_ns(pd_free_cycles_ns),
        .pd_total_cycles_ew(pd_total_cycles_ew),
        .pd_free_cycles_ew(pd_free_cycles_ew),
        .pd_current_counter_ns(pd_current_counter_ns),
        .pd_current_counter_ew(pd_current_counter_ew)
    );

    // Pedestrian Timer Display Instantiation
    pedestrian_timer_display #(
        .CLK_FREQ(CLK_FREQ)
    ) LCD_TIMER_DISPLAY_NS (
        .clk(clk),
        .rst(rst),
        .pd_caution(pd_CAUTION_NS),
        .pd_counter(pd_current_counter_ns),
        .pd_total_cycles(pd_total_cycles_ns),
        .pd_free_cycles(pd_free_cycles_ns),
        .time_left_ms(time_left_ms_ns)
    );

    // Pedestrian Timer Display Instantiation
    pedestrian_timer_display #(
        .CLK_FREQ(CLK_FREQ)
    ) LCD_TIMER_DISPLAY_EW (
        .clk(clk),
        .rst(rst),
        .pd_caution(pd_CAUTION_EW),
        .pd_counter(pd_current_counter_ew),
        .pd_total_cycles(pd_total_cycles_ew),
        .pd_free_cycles(pd_free_cycles_ew),
        .time_left_ms(time_left_ms_ew)
    );

endmodule