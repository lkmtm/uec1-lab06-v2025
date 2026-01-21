module debounce_test;

/* Local variables and signals */

localparam int N = 10;

logic clk, rst_n;
logic sw, db_level, db_tick;

/* Submodules placement */

debounce #(
    .N(N)
) dut (
    .clk,
    .rst_n,
    .sw,
    .db_level,
    .db_tick
);

/* Tasks and functions definitions */

task reset();
    for (int i = 0; i < 2; ++i) begin
        @(negedge clk);
        rst_n = i[0];
    end
endtask

task bounce_sw();
    repeat (50) begin
        sw = 1'($urandom_range(0, 1));
        #($urandom_range(50, 250) * 1ns);
    end
endtask

task test_debounce_operation();
    #(10us + $urandom_range(1, 10) * 1ns);
    bounce_sw();
    sw = 1'b1;
    #(40us + $urandom_range(1, 10) * 1ns);
    bounce_sw();
    sw = 1'b0;
    #(40us + $urandom_range(1, 10) * 1ns);
endtask

/* Clock generation */

initial begin
    clk = 1'b0;

    forever begin
        clk = #5ns ~clk;
    end
end

/* Test */

initial begin
    sw = 1'b0;
    reset();
    repeat (2) begin
        test_debounce_operation();
    end
    $finish();
end

endmodule
