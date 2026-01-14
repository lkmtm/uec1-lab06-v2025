module uart_tx #(
    parameter DBIT = 8, // # data bits
    parameter SB_TICK = 16 // # ticks for stop bits
) (
    input logic clk,
    input logic rst_n,
    input logic tx_start,
    input logic s_tick,
    input logic [7:0] din,
    output logic tx_done_tick,
    output logic tx
);

/* User defined types and constants */

typedef enum logic [1:0] {
    IDLE,
    START,
    DATA,
    STOP
} state_t;

/* Local variables and signals */

state_t state, state_nxt;
logic [3:0] s, s_nxt;
logic [2:0] n, n_nxt;
logic [7:0] b, b_nxt;

/* State Sequencer Logic */

always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
        state <= IDLE;
        s <= 0;
        n <= 0;
        b <= 0;
    end else begin
        state <= state_nxt;
        s <= s_nxt;
        n <= n_nxt;
        b <= b_nxt;
    end

/* Next State Decode Logic */
always_comb begin
    state_nxt = state;
    s_nxt = s;
    n_nxt = n;
    b_nxt = b;
    case (state)
        IDLE: begin
            if (tx_start) begin
                state_nxt = START;
                s_nxt = 0;
                b_nxt = din;
            end
        end
        START: begin
            if (s_tick) begin
                if (s == 15) begin
                    state_nxt = DATA;
                    s_nxt = 0;
                    n_nxt = 0;
                end else begin
                    s_nxt = s + 1;
                end
            end
        end
        DATA: begin
            if (s_tick) begin
                if (s == 15) begin
                    s_nxt = 0;
                    b_nxt = b >> 1;
                    if (n == (DBIT - 1)) begin
                        state_nxt = STOP;
                    end else begin
                        n_nxt = n + 1;
                    end
                end else begin
                    s_nxt = s + 1;
                end
            end
        end
        STOP: begin
            if (s_tick) begin
                if (s == (SB_TICK - 1)) begin
                    state_nxt = IDLE;
                end else begin
                    s_nxt = s + 1;
                end
            end
        end
    endcase
end

/* Output Decode Logic */

always_comb begin
    tx_done_tick = 1'b0;
    case (state)
        IDLE: begin
            tx = 1'b1;
        end
        START: begin
            tx = 1'b0;
        end
        DATA: begin
            tx = b[0];
        end
        STOP: begin
            tx = 1'b1;
            if (s_tick) begin
                if (s == (SB_TICK - 1)) begin
                    tx_done_tick = 1'b1;
                end
            end
        end
    endcase
end

endmodule