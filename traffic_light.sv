module traffic_light (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,    // TAORB=1: Traffic on A / B empty, TAORB=0: reverse
    output logic [1:0] LA, // Street A (00: Red, 01: Yellow, 10: Green)
    output logic [1:0] LB  // Street B
);

    // State definitions (4-state FSM) 
    typedef enum logic [1:0] {
        S0, // LA: Green,  LB: Red
        S1, // LA: Yellow, LB: Red
        S2, // LA: Red,    LB: Green
        S3  // LA: Red,    LB: Yellow
    } state_t;

    state_t state, next_state;
    logic [2:0] timer; // 3 bits are enough to count up to 5

    // Block 1: State Register and Timer
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 0;
        end else begin
            state <= next_state;
            
            // Timer Logic: Increments during S1 and S3, resets on transition
            if ((state == S1 && next_state == S1) || (state == S3 && next_state == S3)) begin
                timer <= timer + 1;
            end else begin
                timer <= 0; // Reset counter when the state changes
            end
        end
    end

    // Block 2: Next-State Logic
    always_comb begin
        next_state = state;
        case (state)
            // S0: Stay here while TAORB is true, otherwise move to S1 
            S0: if (~TAORB) next_state = S1;
            
            // S1: Wait for 5 units, then move to S2
            S1: if (timer == 3'd5) next_state = S2;
            
            // S2: Wait until TAORB becomes true, then move to S3
            S2: if (TAORB) next_state = S3;
            
            // S3: Wait for 5 units, then return to S0
            S3: if (timer == 3'd5) next_state = S0;
            
            default: next_state = S0;
        endcase
    end

    // Block 3: Output Logic
    always_comb begin
        case (state)
            S0: {LA, LB} = 4'b10_00; // LA: Green,  LB: Red
            S1: {LA, LB} = 4'b01_00; // LA: Yellow, LB: Red
            S2: {LA, LB} = 4'b00_10; // LA: Red,    LB: Green
            S3: {LA, LB} = 4'b00_01; // LA: Red,    LB: Yellow
            default: {LA, LB} = 4'b00_00;
        endcase
    end

endmodule