// -----------------------------------------------------------------------------
// counter -- parameterized up-counter with synchronous load and wrap pulse.
// Spec: ../README.md
// -----------------------------------------------------------------------------
module counter #(
    parameter int unsigned WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,     // synchronous, active-low
    input  logic             en,        // count enable
    input  logic             load,      // load has priority over en
    input  logic [WIDTH-1:0] load_val,
    output logic [WIDTH-1:0] count,
    output logic             wrap       // 1-cycle pulse when count goes MAX -> 0
);

    localparam logic [WIDTH-1:0] MaxVal = '1;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count <= '0;
            wrap  <= 1'b0;
        end else begin
            wrap <= 1'b0;
            if (load) begin
                count <= load_val;
            end else if (en) begin
                count <= count + 1'b1;
                wrap  <= (count == MaxVal);
            end
        end
    end

endmodule
