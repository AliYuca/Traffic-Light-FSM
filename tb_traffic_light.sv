`timescale 1ns/1ps

module tb_traffic_light();
    logic clk;
    logic reset;
    logic TAORB;
    logic [1:0] LA, LB;

    // Test edilecek modülü (DUT) çağır
    traffic_light dut (
        .clk(clk),
        .reset(reset),
        .TAORB(TAORB),
        .LA(LA),
        .LB(LB)
    );

    // Saat sinyali üret (Her 10ns'de bir tersle)
    always #5 clk = ~clk;

    initial begin
        // Başlangıç değerleri
        clk = 0;
        reset = 1;
        TAORB = 1; // A sokağında trafik var

        // Reset uygula
        #20 reset = 0;

        // Senaryo 1: A sokağında trafik varken bekle (S0'da kalmalı)
        #50;

        // Senaryo 2: A sokağı boşaldı (TAORB = 0) -> S1'e geçmeli
        TAORB = 0;
        
        // S1'de 5 clock cycle beklemesini izle (Sarı ışık süresi)
        #100;

        // Senaryo 3: B sokağı yeşilken (S2), A'ya trafik geldi (TAORB = 1) -> S3'e geçmeli
        TAORB = 1;
        
        // S3'te 5 clock cycle beklemesini izle
        #100;

        $display("Simülasyon tamamlandı.");
        $stop;
    end
endmodule