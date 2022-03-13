`timescale 1ns / 1ps


module Branch_Predictor(
input i_reset,                  // Tabloları ve tutulan geçmişi sıfırlayan sinyal. 
input i_saat,                   //  
input [31:0] i_buyruk_sayaci,   // Program Counter
input [31:0] i_buyruk,          // Buyruk 
output o_buyruk_ongoru,         // Şuanda işlenen dallanma buyruğunun öngörüsü.

input i_buyruk_atladi, // 1'b1 -> bir onceki dallanma atladi, 1'b0 -> bir onceki dallanma atlamadi. 
output o_ongoru_yanlis
    );
    
    /////////////////////////////////////////////////////////////
    //  32 girişli öngörü tablosu: 2'b00 -> G.T, 2'b11 -> G.A  //
    /////////////////////////////////////////////////////////////                                                         
    reg [1:0] gshare_table       [31:0];
    reg [1:0] gshare_table_next  [31:0];
    
    reg [4:0] branch_history_table, branch_history_table_next; // Bir oncek, buyrugun aldigi degere gore guncellenmeli, 
                                                               // Yani bir onceki cevrimdeki degerine de ihtiyac olabilir.
                                                               // Yukaridaki gibi yapmak yerine bir onceki cevrimde erisilen tablo adresini tutuyorum.  
    // Cikis registerlari degerleri.
    reg r_buyruk_ongoru, r_buyruk_ongoru_next   ;
    assign o_buyruk_ongoru = r_buyruk_ongoru    ; 
    
    reg r_ongoru_yanlis, r_ongoru_yanlis_next   ;
    assign o_ongoru_yanlis = r_ongoru_yanlis    ;
    
    // Bir onceki buyruk sayacinin degeri tutulmali, 
    // Veya onceki dallanma buyrugunun tabloda nereye eriştigi  ve oncekinin dallanma buyrugu olup olmadigi tutulmali  
    // farkli sekillerde yapilabilir. 
    reg [4:0] onceki_buyruk_erisim, onceki_buyruk_erisim_next;
    reg onceki_buyruk_dallanma, onceki_buyruk_dallanma_next;
    
    // Gelen buyrugun dallanma olup olmadigina karar veren wire. 
    wire  yeni_dallanma_buyrugu; 
    assign yeni_dallanma_buyrugu = i_buyruk[1] && i_buyruk[2]; // hangi buyruklarin gelebileceğine gore karar ver. 
    
    // Bir onceki buyrugun tabloda eristigi yeri tutan wire. 
    wire [4:0] yeni_ongoru_adresi; 
    assign yeni_ongoru_adresi = branch_history_table_next[4:0] ^ i_buyruk_sayaci[6:2];
    
    reg [5:0] loop_counter; 
    always@* begin
        for(loop_counter=0 ; loop_counter < 32 ; loop_counter = loop_counter + 5'b1) begin  //
            gshare_table_next[loop_counter] = gshare_table[loop_counter] ;                  //  Lacth olusturmamak icin bir if bloguna girilmedigi durumda tabloya eski degeri ataniyor
        end                                                                                 //
         
        r_buyruk_ongoru_next = r_buyruk_ongoru  ;
        r_ongoru_yanlis_next = r_ongoru_yanlis  ;      
        branch_history_table_next = branch_history_table;
        
        onceki_buyruk_dallanma_next = onceki_buyruk_dallanma;
        onceki_buyruk_erisim_next = onceki_buyruk_erisim;
        
        if(onceki_buyruk_dallanma) begin                                                //
            branch_history_table_next = {branch_history_table[4:0], i_buyruk_atladi};   // Genel geçmiş tablosunun güncellenmesi 
                                                                                        //
            gshare_table_next[onceki_buyruk_erisim] = gshare_table_next[onceki_buyruk_erisim]  + 
                                                                i_buyruk_atladi ? (2'b1) : (- 2'b1); //Not: 2 bit counter saturated mi?                                                                           
        end                                                                             
        
        if(yeni_dallanma_buyrugu) begin
            r_buyruk_ongoru_next = gshare_table[yeni_ongoru_adresi][0];
            
            onceki_buyruk_erisim_next = yeni_ongoru_adresi; 
            onceki_buyruk_dallanma_next = 1'b1; 
        end
    end
    
    always@(posedge i_saat) begin
        if(i_reset) begin
            for(loop_counter=0 ; loop_counter < 32 ; loop_counter = loop_counter + 5'b1) begin  //
                gshare_table[loop_counter] <= 2'b00 ;
            end  
            
            r_buyruk_ongoru <= 1'b0;
            r_ongoru_yanlis <= 1'b0;      
            branch_history_table <= 5'b0;
            
            onceki_buyruk_dallanma <= 1'b0;
            onceki_buyruk_erisim <= 5'b0;
        end
        else begin
             for(loop_counter=0 ; loop_counter < 32 ; loop_counter = loop_counter + 5'b1) begin  
                gshare_table[loop_counter] <= gshare_table_next[loop_counter] ; // Sayaclarin ilk tahmini ne?
            end
        
            r_buyruk_ongoru <= r_buyruk_ongoru_next;
            r_ongoru_yanlis <= r_ongoru_yanlis_next;      
            branch_history_table <= branch_history_table_next;
            
            onceki_buyruk_dallanma <= onceki_buyruk_dallanma_next;
            onceki_buyruk_erisim <= onceki_buyruk_erisim_next;
        end
    end 
    
endmodule
