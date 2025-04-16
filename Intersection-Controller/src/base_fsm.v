// base_fsm.v
`define ON  1'b1
`define OFF 1'b0 

module base_fsm #(
    parameter CLK_FREQ = 50_000_000,
    parameter YELLOW_DELAY_TIME = 40
)(
    input       clk,
    input       rst,
    
    input [31:0] NS_GREEN_DELAY,    // dynamic time duration of NS_GREEN state
    input [31:0] EW_GREEN_DELAY,    // dynamic time duration of EW_GREEN state

    output reg  NS_RED,
    output reg  NS_YELLOW,
    output reg  NS_GREEN,

    output reg  EW_RED,
    output reg  EW_YELLOW,
    output reg  EW_GREEN
);

    // Constant duration for YELLOW phases
    parameter T_YELLOW = YELLOW_DELAY_TIME * CLK_FREQ / 1000;

    // FSM State Encoding
    localparam  NS_GREEN_ST     =   2'b00,
                NS_YELLOW_ST    =   2'b01,
                EW_GREEN_ST     =   2'b10,
                EW_YELLOW_ST    =   2'b11;

    reg [1:0] state;

    reg [32:0] counter;

    // Sequential Block: State Transition and Counter management
    always @(posedge clk) begin
        if (rst) begin
            state   <=  NS_GREEN_ST;
            counter <=  32'd0;
        end
        else begin
            counter <= counter + 1;

            case (state)

                NS_GREEN_ST: begin
                    if (counter >= NS_GREEN_DELAY - 1) begin
                        state   <=  NS_YELLOW_ST;
                        counter <=  32'd0;
                    end
                end

                NS_YELLOW_ST: begin
                    if (counter >= T_YELLOW) begin
                        state   <=  EW_GREEN_ST;
                        counter <=  32'd0;
                    end
                end

                EW_GREEN_ST: begin
                    if (counter >= EW_GREEN_DELAY) begin
                        state   <=  EW_YELLOW_ST;
                        counter <=  32'd0;
                    end
                end

                EW_YELLOW_ST: begin
                    if (counter >= T_YELLOW) begin
                        state   <=  NS_GREEN_ST;
                        counter <= 32'd0;
                    end
                end

                default: begin
                    state     <=  NS_GREEN_ST;
                    counter   <=  32'd0;
                end
            endcase
        end
    end

    // Combinational Block: Assign Light Outputs based`on State
    always @(*) begin
        // Default (all lights `OFF)
        NS_RED      =   `OFF;
        NS_YELLOW   =   `OFF;
        NS_GREEN    =   `OFF;

        EW_RED   =   `OFF;
        EW_YELLOW   =   `OFF; 
        EW_GREEN    =   `OFF;

        case (state)

            NS_GREEN_ST: begin
                NS_GREEN  =  `ON;
                EW_RED    =  `ON;
            end

            NS_YELLOW_ST: begin
                NS_YELLOW =  `ON;
                EW_RED    =  `ON;
            end 

            EW_GREEN_ST: begin
                NS_RED    =  `ON;
                EW_GREEN  =  `ON;
            end

            EW_YELLOW_ST: begin
                NS_RED    =  `ON;
                EW_YELLOW =  `ON;
            end

            default: ;  // All `OFF

        endcase
    end

endmodule