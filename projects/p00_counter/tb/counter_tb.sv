// -----------------------------------------------------------------------------
// counter_tb -- directed, self-checking SystemVerilog testbench.
// Style reference for every *_tb.sv in this repo:
//   * a cycle-accurate model (exp_*) updated on the same clock edge as the DUT
//   * a check() task compares DUT vs model; any mismatch -> $fatal
//   * prints "TEST PASSED" at the end (project.mk greps for it)
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module counter_tb;

    localparam int WIDTH = 4;   // small width so the wrap is reached quickly

    logic             clk = 0;
    logic             rst_n, en, load;
    logic [WIDTH-1:0] load_val;
    logic [WIDTH-1:0] count;
    logic             wrap;

    int unsigned      exp_count;
    logic             exp_wrap;
    int               errors = 0;
    int               wraps_seen = 0;

    counter #(.WIDTH(WIDTH)) dut (.*);

    always #5 clk = ~clk;

    // Reference model: mirrors the spec, updated on the same edge as the DUT.
    always @(posedge clk) begin
        if (!rst_n) begin
            exp_count <= 0;
            exp_wrap  <= 0;
        end else begin
            exp_wrap <= 0;
            if (load)    exp_count <= load_val;
            else if (en) begin
                exp_count <= (exp_count + 1) % (1 << WIDTH);
                exp_wrap  <= (exp_count == (1 << WIDTH) - 1);
            end
        end
    end

    // Checker: sample after the edge has settled.
    always @(negedge clk) begin
        if (rst_n !== 1'b0) begin
            if (count !== exp_count[WIDTH-1:0] || wrap !== exp_wrap) begin
                $error("t=%0t count=%0d exp=%0d wrap=%0b exp=%0b",
                       $time, count, exp_count, wrap, exp_wrap);
                errors++;
            end
            if (wrap) wraps_seen++;
        end
    end

    task automatic step(input logic e, input logic l, input logic [WIDTH-1:0] v);
        en = e; load = l; load_val = v;
        @(posedge clk);
    endtask

    initial begin
        rst_n = 0; en = 0; load = 0; load_val = '0;
        repeat (2) @(posedge clk);
        rst_n = 1;

        // 1. Count through a full wrap.
        repeat ((1 << WIDTH) + 2) step(1, 0, '0);
        // 2. Hold when disabled.
        repeat (3) step(0, 0, '0);
        // 3. Load, and load has priority over enable.
        step(0, 1, 4'd9);
        step(1, 1, 4'd14);
        // 4. Wrap again right after a load.
        repeat (3) step(1, 0, '0);
        // 5. Reset in the middle of counting.
        rst_n = 0; step(1, 0, '0); rst_n = 1;
        repeat (2) step(1, 0, '0);

        @(negedge clk);
        if (wraps_seen < 2) begin
            $error("expected >= 2 wraps, saw %0d", wraps_seen);
            errors++;
        end
        if (errors != 0) $fatal(1, "TEST FAILED with %0d error(s)", errors);
        $display("TEST PASSED");
        $finish;
    end

endmodule
