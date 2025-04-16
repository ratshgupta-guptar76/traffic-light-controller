`define ON 1'b1
`define OFF 1'b0

module pedestrian_light_controller #(
    parameter CLK_FREQ = 50_000_000,          // Clock frequency in Hz
    parameter FREE_WALK_PERCENT = 70          // Percentage of total time for free walk
)(
    input clk,                                // Clock signal
    input rst,                                // Reset signal
    input pd_button_ns,                       // Pedestrian button for NORTH-SOUTH
    input pd_button_ew,                       // Pedestrian button for EAST-WEST
    input [31:0] ns_green_delay,              // Dynamic time duration of NS_GREEN state
    input [31:0] ew_green_delay,              // Dynamic time duration of EW_GREEN state
    input NS_RED,                             // NS vehicles stopped (from base FSM)
    input EW_RED,                             // EW vehicles stopped (from base FSM)
    output reg pd_FREE_NS,                    // Pedestrian light for NORTH-SOUTH FREE WALK
    output reg pd_CAUTION_NS,                 // Pedestrian light for NORTH-SOUTH CAUTION
    output reg pd_FREE_EW,                    // Pedestrian light for EAST-WEST FREE WALK
    output reg pd_CAUTION_EW,                 // Pedestrian light for EAST-WEST CAUTION

    output reg [31:0] pd_current_counter_ns,  // Current counter for NORTH-SOUTH pedestrian light
    output reg [31:0] pd_total_cycles_ns,     // Total cycles for NORTH-SOUTH pedestrian light
    output reg [31:0] pd_free_cycles_ns,      // Free walk cycles for NORTH-SOUTH

    output reg [31:0] pd_current_counter_ew,  // Current counter for EAST-WEST pedestrian light
    output reg [31:0] pd_total_cycles_ew,     // Total cycles for EAST-WEST pedestrian light
    output reg [31:0] pd_free_cycles_ew       // Free walk cycles for EAST-WEST
);

    // Dynamic Pedestrian Timing Calculation
    reg [31:0] PD_TOTAL_CYCLES_NS;            // Total cycles for NORTH-SOUTH pedestrian light
    reg [31:0] PD_FREE_CYCLES_NS;             // Free walk cycles for NORTH-SOUTH
    reg [31:0] PD_CAUTION_CYCLES_NS;          // Caution cycles for NORTH-SOUTH

    reg [31:0] PD_TOTAL_CYCLES_EW;            // Total cycles for EAST-WEST pedestrian light
    reg [31:0] PD_FREE_CYCLES_EW;             // Free walk cycles for EAST-WEST
    reg [31:0] PD_CAUTION_CYCLES_EW;          // Caution cycles for EAST-WEST

    // Calculate pedestrian timing dynamically
    always @(*) begin
        PD_TOTAL_CYCLES_NS = ns_green_delay / 2;  // Pedestrians get half of NS green time
        PD_TOTAL_CYCLES_EW = ew_green_delay / 2;  // Pedestrians get half of EW green time

        PD_FREE_CYCLES_NS = PD_TOTAL_CYCLES_NS * FREE_WALK_PERCENT / 100;
        PD_CAUTION_CYCLES_NS = PD_TOTAL_CYCLES_NS - PD_FREE_CYCLES_NS;

        PD_FREE_CYCLES_EW = PD_TOTAL_CYCLES_EW * FREE_WALK_PERCENT / 100;
        PD_CAUTION_CYCLES_EW = PD_TOTAL_CYCLES_EW - PD_FREE_CYCLES_EW;

        pd_total_cycles_ns <= PD_TOTAL_CYCLES_NS;
        pd_free_cycles_ns  <= PD_FREE_CYCLES_NS;
        pd_total_cycles_ew <= PD_TOTAL_CYCLES_EW;
        pd_free_cycles_ew  <= PD_FREE_CYCLES_EW;
    end

    // Counter for Pedestrian Light FSM
    reg [31:0] pd_counter_ns;                 // Counter for NORTH-SOUTH pedestrian light
    reg [31:0] pd_counter_ew;                 // Counter for EAST-WEST pedestrian light

    reg ns_active;                            // NORTH-SOUTH pedestrian light active
    reg ew_active;                            // EAST-WEST pedestrian light active

    //--------------------------------------------------------------------------
    // *NORTH-SOUTH* Pedestrian Controller
    //--------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pd_counter_ns <= 32'd0;
            ns_active <= `OFF;
            pd_FREE_NS <= `OFF;
            pd_CAUTION_NS <= `OFF;
            pd_current_counter_ns <= 32'd0;  // Ensure synchronous reset
        end
        else begin
            if (pd_button_ns && NS_RED && !ns_active) begin
                ns_active <= `ON;
                pd_counter_ns <= 32'd0;
            end

            if (!NS_RED) begin
                ns_active       <=  `OFF;
                pd_counter_ns   <=  32'd0;
                pd_FREE_NS      <=  `OFF;
                pd_CAUTION_NS   <=  `OFF;
            end

            if (ns_active) begin
                if (pd_counter_ns < PD_FREE_CYCLES_NS) begin
                    pd_FREE_NS <= `ON;
                    pd_CAUTION_NS <= `OFF;
                end
                else if (pd_counter_ns < PD_TOTAL_CYCLES_NS) begin
                    pd_FREE_NS <= `OFF;
                    pd_CAUTION_NS <= `ON;
                end
                else begin
                    ns_active <= `OFF;
                    pd_FREE_NS <= `OFF;
                    pd_CAUTION_NS <= `OFF;
                end

                if (ns_active)
                    pd_counter_ns <= pd_counter_ns + 1;
            end

            pd_current_counter_ns   <=  pd_counter_ns;

        end
    end

    //--------------------------------------------------------------------------
    // *EAST-WEST* Pedestrian Controller
    //--------------------------------------------------------------------------    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pd_counter_ew <= 32'd0;
            ew_active <= `OFF;
            pd_FREE_EW <= `OFF;
            pd_CAUTION_EW <= `OFF;
            pd_current_counter_ew <= 32'd0;  // Ensure synchronous reset
        end
        else begin
            if (pd_button_ew && EW_RED && !ew_active) begin
                ew_active <= `ON;
                pd_counter_ew <= 32'd0;
            end

            if (!EW_RED) begin
                ew_active <= `OFF;
                pd_counter_ew <= 32'd0;
                pd_FREE_EW <= `OFF;
                pd_CAUTION_EW <= `OFF;
            end

            if (ew_active) begin
                if (pd_counter_ew < PD_FREE_CYCLES_EW) begin
                    pd_FREE_EW <= `ON;
                    pd_CAUTION_EW <= `OFF;
                end
                else if (pd_counter_ew < PD_TOTAL_CYCLES_EW) begin
                    pd_FREE_EW <= `OFF;
                    pd_CAUTION_EW <= `ON;
                end
                else begin
                    ew_active <= `OFF;
                    pd_FREE_EW <= `OFF;
                    pd_CAUTION_EW <= `OFF;
                end

                if (ew_active)
                    pd_counter_ew <= pd_counter_ew + 1;

            end

            pd_current_counter_ew   <=  pd_counter_ew;

        end
    end

endmodule