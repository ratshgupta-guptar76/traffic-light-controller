// adaptive_time_delay.v
module adaptive_time_delay #(
    parameter   CLK_FREQ          =   50_000_000,
    parameter   BASE_TIME_DELAY   =   200
)(
    input       clk,
    input       rst,

    input       NS_SENSOR,
    input       EW_SENSOR,

    output reg [31:0]   NS_GREEN_DELAY,
    output reg [31:0]   EW_GREEN_DELAY
);

    // Defining BASE ClOCK CYCLES for GREEN phase (200ms)
    parameter   BASE_GREEN_CYCLES   =   BASE_TIME_DELAY * CLK_FREQ / 1000;

    // Multiplication factor (1.5x) for Active Sensor input
    parameter   FACTOR_NUMER        =   3;
    parameter   FACTOR_DENOM        =   2;

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            NS_GREEN_DELAY  <=  BASE_GREEN_CYCLES;
            EW_GREEN_DELAY  <=  BASE_GREEN_CYCLES;
        end
        else begin
            if (NS_SENSOR)
                NS_GREEN_DELAY      =       BASE_GREEN_CYCLES * FACTOR_NUMER / FACTOR_DENOM;
            else
                NS_GREEN_DELAY      =       BASE_GREEN_CYCLES;
        // ----
            if (EW_SENSOR)
                EW_GREEN_DELAY      =       BASE_GREEN_CYCLES * FACTOR_NUMER / FACTOR_DENOM;
            else
                EW_GREEN_DELAY      =       BASE_GREEN_CYCLES;
        end        

    end

endmodule
