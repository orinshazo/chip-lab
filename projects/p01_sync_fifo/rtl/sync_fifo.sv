// -----------------------------------------------------------------------------
// sync_fifo -- parameterized single-clock FIFO.
// Spec: ../README.md   Test plan: ../TESTPLAN.md
// -----------------------------------------------------------------------------
module sync_fifo #(
    parameter int unsigned DATA_W = 8,
    parameter int unsigned DEPTH  = 16,
    localparam int unsigned CNT_W = $clog2(DEPTH) + 1
) (
    input  logic              clk,
    input  logic              rst_n,

    input  logic              wr_en,
    input  logic [DATA_W-1:0] wr_data,
    input  logic              rd_en,
    output logic [DATA_W-1:0] rd_data,

    output logic              full,
    output logic              empty,
    output logic [CNT_W-1:0]  count,
    output logic              overflow,
    output logic              underflow
);

    // TODO: storage, pointers, accept logic, status flags.
    // Write the TESTPLAN first.

endmodule
