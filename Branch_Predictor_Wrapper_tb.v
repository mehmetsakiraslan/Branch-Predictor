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


module predictor_tb(

    );
    
    
    reg rst_g;                                           
    reg clk_g;                                            
    reg [31:0] i_buyruk_adresi;                            
    reg [31:0] i_buyruk;          //degisicek              
    wire  [31:0] o_atlanan_adres;                           
    wire  o_buyruk_ongoru;             
    
    reg is_jr;                                                   
    reg is_branch;                                               
    reg is_jalr;                                                 
    reg is_j;                                                    
    reg is_jal;                                                  
    reg is_comp; 
                         
    reg guncelle_gecerli_g;
                                                                                                            
    reg [31:0] i_eski_buyruk;     //degisicek              
    reg [31:0] i_eski_buyruk_adresi;                       
    reg i_buyruk_atladi;                                   
    reg [31:0] i_atlanan_adres;                            
    reg i_ongoru_yanlis;                                    
    
    dallanmaOngorucu uut(
        .rst_g(rst_g),                                                   
        .clk_g(clk_g),                                                   
        .i_buyruk_adresi(i_buyruk_adresi),                       
        .i_buyruk(i_buyruk),                              
                                               
        .is_jr(is_jr),                                                   
        .is_branch(is_branch),                                               
        .is_jalr(is_jalr),                                                 
        .is_j(is_j),                                                    
        .is_jal(is_jal),                                                  
        .is_comp(is_comp),                                                 
                                                                                         
        .o_atlanan_adres(o_atlanan_adres),                      
        .o_buyruk_ongoru(o_buyruk_ongoru),                                        
                                                                                         
        .guncelle_gecerli_g(guncelle_gecerli_g),                                      
        .i_eski_buyruk(i_eski_buyruk),                         
        .i_eski_buyruk_adresi(i_eski_buyruk_adresi),                  
        .i_buyruk_atladi(i_buyruk_atladi),                                         
        .i_atlanan_adres(i_atlanan_adres),                       
        .i_ongoru_yanlis(i_ongoru_yanlis)                                                                      
    );
    
    
    always begin
    #5;
    i_saat = ~i_saat;
    
    end
    
    // Verilen programin döngüleri açılmış hali.
    initial begin
    
    i_saat = 1; i_reset = 1'b1;
    i_buyruk_adresi = 0;
    i_buyruk = 0;
    i_buyruk_atladi = 0;
    
    i_eski_buyruk_adresi = 32'b000000001010_00000_000_00000_01100_00;                            // tabloda 12. indis
    i_eski_buyruk = 32'b0000000_00110_00101_000_01100_1100000; 
     
    i_atlanan_adres = 32'b000000001010_00000_000_00000_01100_00;
    i_ongoru_yanlis = 1'b0;
    
    is_jr = 0;                                                   
    is_branch = 0;                                               
    is_jalr = 0;                                                 
    is_j = 0;                                                    
    is_jal = 0;                                                  
    is_comp = 0;   
    
    guncelle_gecerli_g = 0;
    
    #18;
    
    i_reset = 1'b0;
    i_buyruk_adresi = 32'b0;                            
    i_buyruk = 32'b0000000_00110_00101_000_01100_1100011;   // branch 
    i_buyruk_atladi = 1'b0;
     
    i_eski_buyruk_adresi = 32'b0;                           
    i_eski_buyruk = 32'b0000000_00110_00101_000_01100_1100000; 
     
    i_atlanan_adres = 32'b0;
    i_ongoru_yanlis = 1'b0;
    
    is_jr = 0;                                                   
    is_branch = 0;                                               
    is_jalr = 0;                                                 
    is_j = 0;                                                    
    is_jal = 0;                                                  
    is_comp = 0;   
    
    guncelle_gecerli_g = 0;
    
    #18;
    
                                                 
    
   
    
    
    end
    
    
    
    
    
    
    
    
endmodule
