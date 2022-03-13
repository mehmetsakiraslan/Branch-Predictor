`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//
// 
// 
// 
// 
// TODO: Hangi buyruklarin gelecegine karar ver. 
// 
// 
// 
//
// 
//
// 
//  
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module Branch_Predictor_Wrapper_tb(

    );
    reg i_reset;
    reg i_saat;
    reg [31:0] i_buyruk_sayaci;
    reg [31:0] i_buyruk; 
    wire o_buyruk_ongoru;
    
    reg i_buyruk_atladi; // 1'b1 -> bir onceki dallanma atladi, 1'b0 -> bir onceki dallanma atlamadi. 
    wire o_ongoru_yanlis;
    
    Branch_Predictor uut(
    i_reset,
    i_saat,
    i_buyruk_sayaci,
    i_buyruk,
    o_buyruk_ongoru,
    i_buyruk_atladi, 
    o_ongoru_yanlis
    );
    
    always begin
    #5;
    i_saat = ~i_saat;
    end
    
    initial begin
    i_saat = 1; i_reset = 1'b1;
    
    #20;
    
    i_reset = 1'b0;
    i_buyruk_sayaci = 32'd0;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // dallanma buyrugu.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd4;
    i_buyruk = 32'b00000000_00000000_00000000_00000100; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd8;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    #10; 
    
    i_buyruk_sayaci = 32'd12;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    #10; 
    
    i_buyruk_sayaci = 32'd27;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd28;
    i_buyruk = 32'b00000000_00000000_00000000_00000110; // normal buyruk.
    i_buyruk_atladi = 1'b1;
    
    
    
    end
    
    
    
    
    
    
endmodule
