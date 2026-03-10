module traffic_light (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,    // TAORB=1: A'da trafik var/B boş, TAORB=0: Tam tersi
    output logic [1:0] LA, // Street A (00: Red, 01: Yellow, 10: Green)
    output logic [1:0] LB  // Street B
);

    // Durum tanımlamaları (4-state FSM) 
    typedef enum logic [1:0] {
        S0, // LA: Green,  LB: Red [cite: 21]
        S1, // LA: Yellow, LB: Red [cite: 23]
        S2, // LA: Red,    LB: Green [cite: 25]
        S3  // LA: Red,    LB: Yellow [cite: 27]
    } state_t;

    state_t state, next_state;
    logic [2:0] timer; // 5'e kadar sayması için 3 bit yeterli [cite: 23, 24]

    // Blok 1: State Register & Timer (Durum Kaydedici ve Zamanlayıcı) 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 0;
        end else begin
            state <= next_state;
            
            // Zamanlayıcı Mantığı: S1 ve S3 durumlarında artar, geçişte sıfırlanır [cite: 33, 34]
            if ((state == S1 && next_state == S1) || (state == S3 && next_state == S3)) begin
                timer <= timer + 1;
            end else begin
                timer <= 0; // Durum değiştiğinde sayacı sıfırla 
            end
        end
    end

    // Blok 2: Next-State Logic (Gelecek Durum Mantığı) 
    always_comb begin
        next_state = state;
        case (state)
            // S0: TAORB doğruyken burada kal, değilse S1'e geç 
            S0: if (~TAORB) next_state = S1;
            
            // S1: 5 birim boyunca bekle, sonra S2'ye geç [cite: 23, 24]
            S1: if (timer == 3'd5) next_state = S2;
            
            // S2: TAORB doğru olana kadar bekle, olunca S3'e geç [cite: 25, 26]
            S2: if (TAORB) next_state = S3;
            
            // S3: 5 birim boyunca bekle, sonra S0'a dön [cite: 28, 29]
            S3: if (timer == 3'd5) next_state = S0;
            
            default: next_state = S0;
        endcase
    end

    // Blok 3: Output Logic (Çıkış Mantığı) 
    always_comb begin
        case (state)
            S0: {LA, LB} = 4'b10_00; // LA: Green, LB: Red
            S1: {LA, LB} = 4'b01_00; // LA: Yellow, LB: Red
            S2: {LA, LB} = 4'b00_10; // LA: Red, LB: Green
            S3: {LA, LB} = 4'b00_01; // LA: Red, LB: Yellow
            default: {LA, LB} = 4'b00_00;
        endcase
    end

endmodule