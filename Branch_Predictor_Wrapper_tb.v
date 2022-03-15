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
    i_saat = ~i_saat;
    #5;
    end
    
    // Verilen programin döngüleri açılmış hali.
    initial begin
    i_saat = 0; i_reset = 1'b1;
    
    #10;
    
    i_reset = 1'b0;
    i_buyruk_sayaci = 32'd0;
    i_buyruk = 32'b000000001010_00000_000_00101_0010011; // addi x5,x0,#10
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd4;
    i_buyruk = 32'b000000000101_00000_000_00110_0010011; // addi x6,x0,#5
    i_buyruk_atladi = 1'b0;
    
    #10; 
    
    i_buyruk_sayaci = 32'd8;                                                       //         
    i_buyruk = 32'b0000000_00110_00101_000_01100_1100011; // beq x5, x6, #12       //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd12;                                                       //  Loop 1.1
    i_buyruk = 32'b000000000001_00110_000_00110_0010011; // addi x6,x6,#1          //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd16;                                                       //
    i_buyruk = 32'b10000000100000000000_00000_1101111; // jal x0,#(-8)             //
    i_buyruk_atladi = 1'b0;                                                        //
     
    #10;
     
    i_buyruk_sayaci = 32'd8;                                                       //         
    i_buyruk = 32'b0000000_00110_00101_000_01100_1100011; // beq x5, x6, #12       //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd12;                                                       //  Loop 1.2
    i_buyruk = 32'b000000000001_00110_000_00110_0010011; // addi x6,x6,#1          //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd16;                                                       //
    i_buyruk = 32'b10000000100000000000_00000_1101111; // jal x0,#(-8)             //
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10;
     
    i_buyruk_sayaci = 32'd8;                                                       //         
    i_buyruk = 32'b0000000_00110_00101_000_01100_1100011; // beq x5, x6, #12       //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd12;                                                       //  Loop 1.3
    i_buyruk = 32'b000000000001_00110_000_00110_0010011; // addi x6,x6,#1          //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd16;                                                       //
    i_buyruk = 32'b10000000100000000000_00000_1101111; // jal x0,#(-8)             //
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10;
     
    i_buyruk_sayaci = 32'd8;                                                       //         
    i_buyruk = 32'b0000000_00110_00101_000_01100_1100011; // beq x5, x6, #12       //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd12;                                                       //  Loop 1.4
    i_buyruk = 32'b000000000001_00110_000_00110_0010011; // addi x6,x6,#1          //
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd16;                                                       //
    i_buyruk = 32'b10000000100000000000_00000_1101111; // jal x0,#(-8)             //
    i_buyruk_atladi = 1'b0;                                                        //
   
    #10;
     
    i_buyruk_sayaci = 32'd8;                                                       //         
    i_buyruk = 32'b0000000_00110_00101_000_01100_1100011; // beq x5, x6, #12       //
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.1
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.2
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.3
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.4
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.5
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.6
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.7
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.8
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      //
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          //
    i_buyruk_atladi = 1'b1;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd24;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8        //  Loop 2.9
    i_buyruk_atladi = 1'b0;                                                        //
                                                                                   //
    #10;                                                                           //
                                                                                   //
    i_buyruk_sayaci = 32'd28;                                                       //        
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // bne x7, x5, #(-8)     //  
    i_buyruk_atladi = 1'b0;                                                        //
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          
    i_buyruk_atladi = 1'b1;                                                        
                                                                                   
    #10;                                                                           
                                                                                   
    i_buyruk_sayaci = 32'd24;                                                              
    i_buyruk = 32'b0000000_00110_00111_000_01000_1100011; // beq x7, x6, #8          
    i_buyruk_atladi = 1'b0;                                                        
    
    #10; 
    
    i_buyruk_sayaci = 32'd20;                                                      
    i_buyruk = 32'b000000000001_00000_000_00111_0010011; // addi x7,x0,#1          
    i_buyruk_atladi = 1'b1; 
                                                                                   
  
                                                                                   
 
                                                           
    
   
    
    
    end
    
    
    
    
    
    
    
    
endmodule
