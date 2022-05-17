`timescale 1ns / 1ps

`define JAL     7'b1101111 
`define JALR    7'b1100111
`define BRANCH  7'b1100011

module BPU(
input i_reset,                   
input i_saat,                    
input [31:0] i_buyruk_adresi,                                                                 
input [31:0] i_buyruk,          //degisicek                                                                              
output [31:0] o_atlanan_adres,
output o_buyruk_ongoru,         

///
input [31:0] i_eski_buyruk,     //degisicek    
input [31:0] i_eski_buyruk_adresi,
input i_buyruk_atladi,  
input [31:0] i_atlanan_adres, 
input i_ongoru_yanlis
//output o_ongoru_yanlis
    );
  
     
    reg [31:0] r_atlanan_adres, r_atlanan_adres_next;
    
    assign o_atlanan_adres = r_atlanan_adres;
    
    reg r_buyruk_ongoru, r_buyruk_ongoru_next;
    
    assign o_buyruk_ongoru = r_buyruk_ongoru;
    
    // /////////////////////////////////////////////////////////////
    // //  32 giriþli öngörü tablosu: 2'b00 -> G.T, 2'b11 -> G.A  //
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
    
    reg [1:0] bht_pointer, bht_pointer_next;
    
    
    // BTB kontrol sinyalleri
    wire yeni_dallanma_buyrugu;
    assign yeni_dallanma_buyrugu = i_buyruk[6:0] == `BRANCH;
    
    wire [4:0] yeni_ongoru_adresi;
    assign yeni_ongoru_adresi = {bht[4:1], i_buyruk_atladi}  ^ i_buyruk_adresi[6:2]; // once tahmin iceren bht elemanini guncelle 
    
    wire eski_dallanma_buyrugu;
    assign eski_dallanma_buyrugu = i_eski_buyruk[6:0] == `BRANCH;
    
    wire [4:0] eski_ongoru_adresi;
    assign eski_ongoru_adresi = bht_next[(bht_pointer-1)+:4] ^ i_eski_buyruk_adresi; // kontrol et 
    
    
    // ras kontrol sinyalleri
    wire rd_link;
    assign rd_link = (i_buyruk[11:7] == 5'd1) || (i_buyruk[11:7] == 5'd5);
    
    wire rs1_link; 
    assign rs1_link = (i_buyruk[19:15] == 5'd1) || (i_buyruk[19:15] == 5'd5);
    
    wire ras_push;
    assign ras_push = ((i_buyruk[6:0] == `JAL) || (i_buyruk[6:0] == `JALR)) && (rd_link);
    
    wire ras_pop;
    assign ras_pop = i_buyruk[6:0] == `JALR && (rs1_link && !(i_buyruk[11:7] == i_buyruk[19:15]));  
    
    
    //  reg [5:0] btb_erisim_listesi [2:0]; 
    //  reg [5:0] btb_erisim_listesi_next [2:0];
    
    integer loop_counter; 
    always@* begin
        for(loop_counter=0; loop_counter<32; loop_counter=loop_counter+1) begin  
            btb_next[loop_counter] = btb[loop_counter] ;                  
        end
        for(loop_counter=0; loop_counter<4; loop_counter=loop_counter+1) begin  //
            ras_next[loop_counter] = ras[loop_counter] ;                  
        end
        // for(loop_counter=0; loop_counter<3; loop_counter=loop_counter+1) begin  //
        //     btb_erisim_listesi_next[loop_counter] = btb_erisim_listesi[loop_counter] ;                  
        // end
        //ras_pointer_next = ras_pointer;;
        bht_next = bht;
        bht_pointer_next = bht_pointer;
        r_atlanan_adres_next = r_atlanan_adres;
        r_buyruk_ongoru_next = r_buyruk_ongoru; 
        
        
        if(yeni_dallanma_buyrugu) begin
            r_buyruk_ongoru_next = btb[yeni_ongoru_adresi][33];
            bht_next = {bht[6:0], btb[yeni_ongoru_adresi][33]}; // spekulatif guncelleme
            bht_pointer_next = bht_pointer + 3'd1; 
            
            r_atlanan_adres_next = btb[yeni_ongoru_adresi][31:0];
            // for(loop_counter=1; loop_counter<3; loop_counter=loop_counter+1) begin  //
            //     btb_erisim_listesi_next[loop_counter] = btb_erisim_listesi[loop_counter-1] ;                  
            // end 
            // btb_erisim_listesi[0] = {1'b1, r_buyruk_ongoru_next, yeni_ongoru_adresi}; // kontrol et 
        end
        
        if(eski_dallanma_buyrugu) begin
            bht_pointer_next = (bht_pointer != 3'd0) ?  bht_pointer - 3'd1 : 3'd0;
            
            btb_next[eski_ongoru_adresi][31:0] = i_eski_buyruk_adresi;
            if(i_ongoru_yanlis) begin
                btb_next[eski_ongoru_adresi][32:31] = btb[eski_ongoru_adresi][32:31] + 
                                                        i_buyruk_atladi ? ((2'b11 == btb[eski_ongoru_adresi][32:31]) ? 2'b0 : (2'b1)) // lookup table kullanmak daha mantikli olabilir
                                                                : ((2'b00 == btb[eski_ongoru_adresi][32:31]) ? 2'b0 : (-2'b1)) ;  
                    
                for(loop_counter=0 ;loop_counter<5; loop_counter=loop_counter+1) begin
                    bht_next[loop_counter] = bht[loop_counter+bht_pointer]; // iki yonlu shift register, araya yanlis branchler aldiysak geri sarilmali
                end
                
                for(loop_counter=0 ;loop_counter<3; loop_counter=loop_counter+1) begin 
                    ras_next[loop_counter] = 32'd0; 
                end
                
                // for(loop_counter=0 ;loop_counter<3; loop_counter=loop_counter+1) begin 
                //     if(loop_counter<bht_pointer) begin
                //         btb_next[ btb_erisim_listesi[loop_counter][4:0]][32:31] = btb[ btb_erisim_listesi[loop_counter][4:0]][32:31] + (btb_erisim_listesi[loop_counter][5] ? (2'b1) : (-2'b1)) ; // rezalet oldu
                //     end
                // end
            end
        end
        
        if(ras_push) begin
            ras_next[3] = ras[2];
            ras_next[2] = ras[1];
            ras_next[1] = ras[0];
            ras_next[0] = i_buyruk_adresi; 
            
            //ras_pointer_next = ras_pointer + 2'b1;
        end
        
        if(ras_pop) begin
            ras_next[2] = ras[3];
            ras_next[1] = ras[2];
            ras_next[0] = ras[1]; 
            
            //ras_pointer_next = ras_pointer - 2'b1;
        end
    end 
    
    always@(posedge i_saat) begin
        if(i_reset) begin
            for(loop_counter=0; loop_counter<32; loop_counter=loop_counter+1) begin  
                btb[loop_counter] = 34'd0;                  
            end
            for(loop_counter=0; loop_counter<4; loop_counter=loop_counter+1) begin  //
                ras[loop_counter] = 32'd0;                  
            end
            // for(loop_counter=0; loop_counter<3; loop_counter=loop_counter+1) begin  //
            //     btb_erisim_listesi[loop_counter] = 6'd0;                  
            // end
            //ras_pointer = 0;
            bht = 9'd0;
            bht_pointer = 3'd0;
            r_atlanan_adres = 32'd0 ;
            r_buyruk_ongoru = 1'd0;
        end
        else begin
            for(loop_counter=0; loop_counter<32; loop_counter=loop_counter+1) begin  
                btb[loop_counter] = btb_next[loop_counter] ;                  
            end
            for(loop_counter=0; loop_counter<4; loop_counter=loop_counter+1) begin  //
                ras[loop_counter] = ras_next[loop_counter] ;                  
            end
            // for(loop_counter=0; loop_counter<3; loop_counter=loop_counter+1) begin  //
            //     btb_erisim_listesi[loop_counter] = btb_erisim_listesi_next[loop_counter] ;                  
            // end
            //ras_pointer = 0;
            bht = bht_next;
            bht_pointer = bht_pointer_next;
            r_atlanan_adres = r_atlanan_adres_next;
            r_buyruk_ongoru = r_buyruk_ongoru_next;
        end
    end
    
endmodule
