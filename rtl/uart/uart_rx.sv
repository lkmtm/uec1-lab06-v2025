module uart_rx #(
    parameter DBIT = 8, // # data bits
    parameter SB_TICK = 16 // # ticks for stop bits
) (
    input logic clk,
    input logic rst_n,
    input logic rx,
    input logic s_tick,
    output logic rx_done_tick,
    output logic [7:0] dout
);

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

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        s <= 4'b0;
        n <= 3'b0;
        b <= 8'b0;
    end else begin
        state <= state_nxt;
        s <= s_nxt;
        n <= n_nxt;
        b <= b_nxt;
    end
end

/* Next State Decode Logic */

always_comb begin
    state_nxt = state;
    s_nxt = s;
    n_nxt = n;
    b_nxt = b;

    case (state)
        IDLE: begin
            if (~rx) begin
                state_nxt = START;
                s_nxt = 0;
            end
        end
        START: begin
            if (s_tick) begin
                if (s == 7) begin
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
                    b_nxt = {rx, b[7:1]};
                    if (n == (DBIT - 1))
                        state_nxt = STOP;
                    else
                        n_nxt = n + 1;
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
    rx_done_tick = 1'b0;
    dout = b;

    case (state)
        IDLE: ;
        START: ;
        DATA: ;
        STOP: begin
            rx_done_tick = (s_tick && (s == (SB_TICK - 1)));
        end
    endcase
end

endmodule
