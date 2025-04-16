module pedestrian_timer_display #(
    parameter CLK_FREQ = 50_000_000,
    parameter MS_CONV = 1000
)(
    input clk,
    input rst,
    input pd_caution,
    input [31:0] pd_counter,
    input [31:0] pd_total_cycles,
    input [31:0] pd_free_cycles,
    output reg [31:0] time_left_ms
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            time_left_ms <= 0;
        end else if (pd_caution && (pd_counter >= pd_free_cycles)) begin
            if (pd_total_cycles > pd_counter)
                time_left_ms <= ((pd_total_cycles - pd_counter) * MS_CONV) / CLK_FREQ;
            else
                time_left_ms <= 0;
        end else begin
            time_left_ms <= 0;
        end
    end

endmodule
