module debounce #(
    // number of counter bits (2^N / 100 MHz = 40ms)
    parameter int N = 22
) (
    input logic clk,
    input logic rst_n,
    input logic sw,
    output logic db_level,
    output logic db_tick
);

/* User defined types and constants */

typedef enum logic [1:0] {
    ZERO,
    WAIT0,
    ONE,
    WAIT1
} state_t;

/* Local variables and signals */

logic [N-1:0] q, q_nxt;
state_t state, state_nxt;

/* State Sequencer Logic */

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state <= ZERO;
        q <= 0;
    end else begin
        state <= state_nxt;
        q <= q_nxt;
    end
end

/* Next State Decode Logic */

always_comb begin
    state_nxt = state;
    q_nxt = q;

    case (state)
        ZERO: begin
            if (sw) begin
                state_nxt = WAIT1;
                q_nxt = {N{1'b1}};
            end
        end
        WAIT1: begin
            if (sw) begin
                q_nxt = q - 1;
                if (q == 0) begin
                    state_nxt = ONE;
                end
            end else begin
                state_nxt = ZERO;
            end
        end
        ONE: begin
            if (~sw) begin
                state_nxt = WAIT0;
                q_nxt = {N{1'b1}};
            end
        end
        WAIT0: begin
            if (~sw) begin
                q_nxt = q - 1;
                if (q == 0) begin
                    state_nxt = ZERO;
                end
            end else begin
                state_nxt = ONE;
            end

        end
        default: state_nxt = ZERO;
    endcase
end

/* Output Decode Logic */

always_comb begin
    db_level = 1'b0;
    db_tick = 1'b0;

    case (state)
        ZERO: ;
        WAIT1: begin
            db_tick = sw && (q == 0);
        end
        ONE: begin
            db_level = 1'b1;
        end
        WAIT0: begin
            db_level = 1'b1;
        end
    endcase
end

endmodule
