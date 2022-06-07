`timescale 1ns / 1ps

`define JAL     7'b1101111 
`define JALR    7'b1100111
`define BRANCH  7'b1100011
`define C_JALR  4'b1001
`define BUYRUK_BIT 32'd32

//`include "sabitler.vh"

module dallanmaOngorucu(
input rst_g,                   
input clk_g,                    
input [`BUYRUK_BIT-1:0] i_buyruk_adresi,                                                                 
input [`BUYRUK_BIT-1:0] i_buyruk,             
// getir 2 asamasindan gelen oncoz sinyalleri
input is_jr,
input is_branch,
input is_jalr,
input is_j,
input is_jal,
input is_comp, 
                                                                       
output [`BUYRUK_BIT-1:0] o_atlanan_adres,
output o_buyruk_ongoru,         

// dallanma ongorucuyu guncellemek icin kullanilan bitler
input guncelle_gecerli_g,
input [`BUYRUK_BIT-1:0] i_eski_buyruk,     
input [`BUYRUK_BIT-1:0] i_eski_buyruk_adresi,
input i_buyruk_atladi,  
input [`BUYRUK_BIT-1:0] i_atlanan_adres, 
input i_ongoru_yanlis
    );
   
    reg [31:0] r_atlanan_adres, r_atlanan_adres_next;
    assign o_atlanan_adres = r_atlanan_adres;
    
    reg r_buyruk_ongoru, r_buyruk_ongoru_next;
    assign o_buyruk_ongoru = r_buyruk_ongoru;
    
    // /////////////////////////////////////////////////////////////
    // //  32 giri?li öngörü tablosu: 2'b00 -> G.T, 2'b11 -> G.A  //
    // /////////////////////////////////////////////////////////////                                                         
    // reg [1:0] cift_kutuplu_sayac_tablosu       [31:0];
    // reg [1:0] cift_kutuplu_sayac_tablosu_next  [31:0];
    
    //////////////////////////////////////////////////////////////////////////////////////
    // Branch Target Buffer: 33:32 ghsare table, rest is addr                           //
    //////////////////////////////////////////////////////////////////////////////////////                                                         
    reg [33:0] btb       [31:0];
    reg [33:0] btb_next  [31:0];
    
    //////////////////////////////////////////////////////////////////
    //                              RAS                             //
    ////////////////////////////////////////////////////////////////// 
    reg [31:0] ras       [3:0];
    reg [31:0] ras_next  [3:0];
    
    //reg [1:0] ras_pointer, ras_pointer_next;
    
    //////////////////////////////////////////////////////////////////
    //                              BHT                             //
    ////////////////////////////////////////////////////////////////// 
    reg [7:0] bht, bht_next; 
    
    reg [2:0] bht_pointer, bht_pointer_next;
    
    // BTB kontrol sinyalleri
    wire yeni_dallanma_buyrugu;
    assign yeni_dallanma_buyrugu = is_branch;
    
    wire eski_dallanma_buyrugu;
    assign eski_dallanma_buyrugu = i_eski_buyruk[6:0] == `BRANCH;
    
    wire [4:0] yeni_ongoru_adresi;
    assign yeni_ongoru_adresi = ((yeni_dallanma_buyrugu && guncelle_gecerli_g) ? ({bht[4:1], i_buyruk_atladi}) : (bht[4:0])) ^ i_buyruk_adresi[6:2]; // once tahmin iceren bht elemanini guncelle 
    
    wire [4:0] eski_ongoru_adresi;
    assign eski_ongoru_adresi = bht_next[(bht_pointer)+:4] ^ i_eski_buyruk_adresi; // kontrol et************* 
    
    wire eski_uncond_buyruk;
    assign eski_uncond_buyruk = (i_eski_buyruk[6:0] == `JALR) || (is_comp &&  (i_eski_buyruk[15:12] == `C_JALR ));  // BTB'ye erisecek jump buyruklari
    
    // ras kontrol sinyalleri
    wire rd_link;
    assign rd_link = (!is_comp && ((i_buyruk[11:7] == 5'd1) || (i_buyruk[11:7] == 5'd5))) || (is_comp && !is_jal); // Compressed jal buyrugu yoksa " && !is_jal" silinebilir. 
    
    wire rs1_link; 
    assign rs1_link = (!is_comp && is_jalr && ((i_buyruk[19:15] == 5'd1) || (i_buyruk[19:15] == 5'd5))) 
                        || (is_comp && ((i_buyruk[11:7] == 5'd1) || (i_buyruk[11:7] == 5'd5))); 
    
    wire rd_esitdegil_rs1;
    assign rd_esitdegil_rs1 = (!is_comp && is_jalr && (i_buyruk[19:15] != i_buyruk[19:15]));
    
    wire ras_push;
    assign ras_push = ((is_jal) || (is_jalr)) && (rd_link); 
    
    wire ras_pop;
    assign ras_pop = (is_jalr || is_jr) && (rs1_link &&(!rd_link && (rd_link && rd_esitdegil_rs1))); // compressed jal durumunu goz ardi etme
    
    integer loop_counter; 
    always@* begin
        for(loop_counter=0; loop_counter<32; loop_counter=loop_counter+1) begin  
            btb_next[loop_counter] = btb[loop_counter] ;                  
        end
        for(loop_counter=0; loop_counter<4; loop_counter=loop_counter+1) begin  //
            ras_next[loop_counter] = ras[loop_counter] ;                  
        end
        bht_next = bht;
        bht_pointer_next = bht_pointer;
        r_atlanan_adres_next = r_atlanan_adres;
        r_buyruk_ongoru_next = r_buyruk_ongoru; 
        
        if(is_branch) begin
            r_buyruk_ongoru_next = btb[yeni_ongoru_adresi][33];
            bht_next = {bht[6:0], btb[yeni_ongoru_adresi][33]}; // spekulatif guncelleme
            bht_pointer_next = bht_pointer + 2'd1; 
            
            r_atlanan_adres_next = btb[yeni_ongoru_adresi][31:0];
        end
        
        if(eski_dallanma_buyrugu && guncelle_gecerli_g) begin
            bht_pointer_next = (bht_pointer != 3'd0) ?  (bht_pointer - 3'd1) : (3'd0);
            
            btb_next[eski_ongoru_adresi][31:0] = i_eski_buyruk_adresi;
            if(i_ongoru_yanlis) begin
               
                case({i_buyruk_atladi, btb[eski_ongoru_adresi][33:32]})
                3'b111:  btb_next[eski_ongoru_adresi][33:32] = 2'b11;
                
                3'b110:  btb_next[eski_ongoru_adresi][33:32] = 2'b11;
                
                3'b101:  btb_next[eski_ongoru_adresi][33:32] = 2'b10;
                
                3'b100:  btb_next[eski_ongoru_adresi][33:32] = 2'b01;
                
                3'b011:  btb_next[eski_ongoru_adresi][33:32] = 2'b10;
                
                3'b010:  btb_next[eski_ongoru_adresi][33:32] = 2'b01;
                
                3'b001:  btb_next[eski_ongoru_adresi][33:32] = 2'b00;
                
                3'b000:  btb_next[eski_ongoru_adresi][33:32] = 2'b00;
                endcase
                
                btb_next[eski_ongoru_adresi][31:0] = i_eski_buyruk_adresi;    
                for(loop_counter=1 ;loop_counter<5; loop_counter=loop_counter+1) begin
                    bht_next[loop_counter] = bht[loop_counter+bht_pointer]; // iki yonlu shift register, araya yanlis branchler aldiysak geri sarilmali
                end
                
                bht_next[0] = i_buyruk_atladi;
                
                for(loop_counter=0 ;loop_counter<3; loop_counter=loop_counter+1) begin 
                    ras_next[loop_counter] = 32'd0; 
                end
            end
        end
        
        if (is_jr || is_jalr) begin
            r_atlanan_adres_next = btb[yeni_ongoru_adresi][31:0];
        end
        
        if (is_jal) begin // compressed jal varsa degismeli
            r_atlanan_adres_next = i_buyruk_adresi + {{13{i_buyruk[31]}}, i_buyruk[19:12], i_buyruk[20], i_buyruk[30:21]};
        end
        
        if (is_j) begin 
            r_atlanan_adres_next = i_buyruk_adresi + {{21{i_buyruk[11]}}, i_buyruk[4], i_buyruk[9:8], i_buyruk[10],i_buyruk[6], i_buyruk[7], i_buyruk[3:1], i_buyruk[5]};
        end
        
        if(eski_uncond_buyruk && i_ongoru_yanlis) begin
            
        end
        
        if(ras_push) begin
            ras_next[3] = ras[2];
            ras_next[2] = ras[1];
            ras_next[1] = ras[0];
            ras_next[0] = i_buyruk_adresi;  
        end
        
        if(ras_pop) begin
            ras_next[3] = 32'd0;
            ras_next[2] = ras[3];
            ras_next[1] = ras[2];
            ras_next[0] = ras[1];
            r_atlanan_adres_next = ras[0]; 
        end
    end 
    
    always@(posedge clk_g) begin
        if(rst_g) begin
            for(loop_counter=0; loop_counter<32; loop_counter=loop_counter+1) begin  
                btb[loop_counter] <= 34'b11_00000000000000000000000000000000;                  
            end
            for(loop_counter=0; loop_counter<4; loop_counter=loop_counter+1) begin  //
                ras[loop_counter] <= 32'd0;                  
            end
            bht <= 8'd0;
            bht_pointer <= 3'd0;
            r_atlanan_adres <= 32'd0 ;
            r_buyruk_ongoru <= 1'd0;
        end
        else begin
            for(loop_counter=0; loop_counter<32; loop_counter=loop_counter+1) begin  
                btb[loop_counter] <= btb_next[loop_counter] ;                  
            end
            for(loop_counter=0; loop_counter<4; loop_counter=loop_counter+1) begin  //
                ras[loop_counter] <= ras_next[loop_counter] ;                  
            end
            bht <= bht_next;
            bht_pointer <= bht_pointer_next;
            r_atlanan_adres <= r_atlanan_adres_next;
            r_buyruk_ongoru <= r_buyruk_ongoru_next;
        end
    end
    
endmodule
