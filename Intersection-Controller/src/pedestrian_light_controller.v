`define ON 1'b1
`define OFF 1'b0

module pedestrian_light_controller #(
    parameter CLK_FREQ = 50_000_000,
    parameter FREE_WALK_PERCENT = 70
)(
    input clk,
    input rst,
    input pd_button_ns,
    input pd_button_ew,
    input [31:0] ns_green_delay,
    input [31:0] ew_green_delay,
    input NS_RED,
    input EW_RED,
    output reg pd_FREE_NS,
    output reg pd_CAUTION_NS,
    output reg pd_FREE_EW,
    output reg pd_CAUTION_EW,
    output reg [31:0] pd_current_counter_ns,
    output reg [31:0] pd_total_cycles_ns,
    output reg [31:0] pd_free_cycles_ns,
    output reg [31:0] pd_current_counter_ew,
    output reg [31:0] pd_total_cycles_ew,
    output reg [31:0] pd_free_cycles_ew
);

    reg [31:0] PD_TOTAL_CYCLES_NS;
    reg [31:0] PD_FREE_CYCLES_NS;
    reg [31:0] PD_CAUTION_CYCLES_NS;

    reg [31:0] PD_TOTAL_CYCLES_EW;
    reg [31:0] PD_FREE_CYCLES_EW;
    reg [31:0] PD_CAUTION_CYCLES_EW;

    always @(*) begin
        PD_TOTAL_CYCLES_NS = ns_green_delay / 2;
        PD_TOTAL_CYCLES_EW = ew_green_delay / 2;

        PD_FREE_CYCLES_NS = PD_TOTAL_CYCLES_NS * FREE_WALK_PERCENT / 100;
        PD_CAUTION_CYCLES_NS = PD_TOTAL_CYCLES_NS - PD_FREE_CYCLES_NS;

        PD_FREE_CYCLES_EW = PD_TOTAL_CYCLES_EW * FREE_WALK_PERCENT / 100;
        PD_CAUTION_CYCLES_EW = PD_TOTAL_CYCLES_EW - PD_FREE_CYCLES_EW;

        // Changed from <= to = because this is combinational
        pd_total_cycles_ns = PD_TOTAL_CYCLES_NS;
        pd_free_cycles_ns = PD_FREE_CYCLES_NS;
        pd_total_cycles_ew = PD_TOTAL_CYCLES_EW;
        pd_free_cycles_ew = PD_FREE_CYCLES_EW;
    end

    reg [31:0] pd_counter_ns;
    reg [31:0] pd_counter_ew;
    reg ns_active;
    reg ew_active;

    // NORTH-SOUTH pedestrian FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pd_counter_ns <= 0;
            ns_active <= `OFF;
            pd_FREE_NS <= `OFF;
            pd_CAUTION_NS <= `OFF;
            pd_current_counter_ns <= 0;
        end else begin
            if (pd_button_ns && NS_RED && !ns_active) begin
                ns_active <= `ON;
                pd_counter_ns <= 0;
            end

            if (!NS_RED) begin
                ns_active <= `OFF;
                pd_counter_ns <= 0;
                pd_FREE_NS <= `OFF;
                pd_CAUTION_NS <= `OFF;
            end

            if (ns_active) begin
                if (pd_counter_ns < PD_FREE_CYCLES_NS) begin
                    pd_FREE_NS <= `ON;
                    pd_CAUTION_NS <= `OFF;
                end else if (pd_counter_ns < PD_TOTAL_CYCLES_NS) begin
                    pd_FREE_NS <= `OFF;
                    pd_CAUTION_NS <= `ON;
                end else begin
                    ns_active <= `OFF;
                    pd_FREE_NS <= `OFF;
                    pd_CAUTION_NS <= `OFF;
                end

                if (ns_active)
                    pd_counter_ns <= pd_counter_ns + 1;
            end

            pd_current_counter_ns <= pd_counter_ns;
        end
    end

    // EAST-WEST pedestrian FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pd_counter_ew <= 0;
            ew_active <= `OFF;
            pd_FREE_EW <= `OFF;
            pd_CAUTION_EW <= `OFF;
            pd_current_counter_ew <= 0;
        end else begin
            if (pd_button_ew && EW_RED && !ew_active) begin
                ew_active <= `ON;
                pd_counter_ew <= 0;
            end

            if (!EW_RED) begin
                ew_active <= `OFF;
                pd_counter_ew <= 0;
                pd_FREE_EW <= `OFF;
                pd_CAUTION_EW <= `OFF;
            end

            if (ew_active) begin
                if (pd_counter_ew < PD_FREE_CYCLES_EW) begin
                    pd_FREE_EW <= `ON;
                    pd_CAUTION_EW <= `OFF;
                end else if (pd_counter_ew < PD_TOTAL_CYCLES_EW) begin
                    pd_FREE_EW <= `OFF;
                    pd_CAUTION_EW <= `ON;
                end else begin
                    ew_active <= `OFF;
                    pd_FREE_EW <= `OFF;
                    pd_CAUTION_EW <= `OFF;
                end

                if (ew_active)
                    pd_counter_ew <= pd_counter_ew + 1;
            end

            pd_current_counter_ew <= pd_counter_ew;
        end
    end

endmodule
