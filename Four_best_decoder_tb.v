`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 19:19:26
// Design Name: 
// Module Name: test5_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/18 23:00:56
// Design Name: 
// Module Name: uuu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Four_best_decoder_tb;
    parameter W_l = 15;
    parameter W_0 = 15;
    wire  [(4*2*W_0)-1:0] OutData;
    wire [(W_l -1) : 0] sortdata;
    reg clk;
    reg rst;
    reg flagChannelorData;
    reg [(W_l * 4 * 2)-1 : 0] InData;

    // 實例化主程式
    Four_best_decoder uut (
        .clk(clk),
        .rst(rst),
        .flagChannelorData(flagChannelorData),
        .InData(InData),
        .sortdata(sortdata),
        .OutData(OutData)
      );
always
begin
#1   clk=~clk;
end
     initial begin
        // 初始化
        clk = 1;
        flagChannelorData=1;
        rst=1;
        InData<=0;
        
        
        
        
        #100 rst=0;
        
        #2

            InData[W_l - 1 : 0]           = 15'b111110000010100;//00
            InData[2 * W_l - 1 : W_l]     = 15'b111110100100001;
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111101011111110;
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000001100000110;
            
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000000000000000;
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111100100101010;//11
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000001111011000;
            InData[8 * W_l - 1 : 7 * W_l] = 15'b111111111010010;

        #2   

            InData[W_l - 1 : 0] = 15'b000000000000000;
            InData[2 * W_l - 1 : 1 * W_l] = 15'b000000000000000;
            InData[3 * W_l - 1 : 2 * W_l] = 15'b000101101101000;//22
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000001101100110;
        
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000000000000000;
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000000000000000;
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000000000000000;
            InData[8 * W_l - 1 : 7 * W_l] = 15'b111110001101101;//33

        #2 

            InData[ W_l - 1 : 0] = 15'b000000000000000;//00
            InData[2 * W_l - 1 : W_l] = 15'b000000101000011;
            InData[3 * W_l - 1 : 2 * W_l] = 15'b000001101010010;
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000000111011100;
        
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000000000000000;
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000000000000000;//11
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000000101100100;
            InData[8 * W_l - 1 : 7 * W_l] = 15'b111110101010100;

        #2

            InData[ W_l - 1 : 0] = 15'b000000000000000;
            InData[2 * W_l - 1 : 1 * W_l] = 15'b000000000000000;
            InData[3 * W_l - 1 : 2 * W_l] = 15'b000000000000000;//22
            InData[4 * W_l - 1 : 3 * W_l] = 15'b111111011011110;
        
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000000000000000;
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000000000000000;
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000000000000000;
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000000000000000;//33

        #200 flagChannelorData=0;
        

            InData[W_l - 1 : 0]           = 15'b111011011110000;//real //1
            InData[2 * W_l - 1 : W_l]     = 15'b111101111110111;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111101001100000;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000001110011100;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000000111011000;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000111100111100;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000000000010010;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b111101111001011;//imag
            $display("%b",sortdata);
        #2
        #34

            InData[W_l - 1 : 0]           = 15'b000001000110001;//real //2
            InData[2 * W_l - 1 : W_l]     = 15'b000010111110100;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111101100110010;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b111100010010000;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111111110110001;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111000010011101;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000000001111100;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000001101001101;//imag
            $display("%b",sortdata);
        #4
        
        #34

            InData[W_l - 1 : 0]           = 15'b000001101100110;//real //3
            InData[2 * W_l - 1 : W_l]     = 15'b111101000111101;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111001111010000;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000000100101010;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111000111000110;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111111011000110;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000001000011111;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000001110101011;//imag
            $display("%b",sortdata);
        #4
        #34

            InData[W_l - 1 : 0]           = 15'b000101100011011;//real //4*
            InData[2 * W_l - 1 : W_l]     = 15'b000010110101101;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111011010110001;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b111111011010100;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111101010111110;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111010110011011;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b111101100111001;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000000111000110;//imag
            $display("%b",sortdata);
        #4
        #34

            InData[W_l - 1 : 0]           = 15'b111010100001100;//real //5
            InData[2 * W_l - 1 : W_l]     = 15'b000010010100011;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b000001011011010;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000100111101101;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000100001100001;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000000011111110;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000010011111000;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000000000011000;//imag
            $display("%b",sortdata);
        #4
        #34
            InData[W_l - 1 : 0]           = 15'b111110100001011;//real //6
            InData[2 * W_l - 1 : W_l]     = 15'b111111000011001;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111111010000100;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000110101100011;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111101010111101;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000110101110011;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000010000001011;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000000011110010;//imag
            $display("%b",sortdata);
        #4
        #34
            InData[W_l - 1 : 0]           = 15'b111111011111001;//real //7
            InData[2 * W_l - 1 : W_l]     = 15'b000101001111101;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b000100011010100;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000001110111001;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111111000101011;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111100001010011;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000001100111010;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b111110111010000;//imag
            $display("%b",sortdata);
        #4
        #34
            InData[W_l - 1 : 0]           = 15'b000100011000111;//real //8
            InData[2 * W_l - 1 : W_l]     = 15'b111111100101110;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111010110011100;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000000111110111;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111011100011001;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111001101110100;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b111110000001101;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000010110011110;//imag
            $display("%b",sortdata);
        #4
        #34
            InData[W_l - 1 : 0]           = 15'b000000000010111;//real //9
            InData[2 * W_l - 1 : W_l]     = 15'b111101000100010;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111001101100101;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b111111001110111;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111001011100110;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111101010111011;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b111111110111101;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000001000011011;//imag
            $display("%b",sortdata);
        #4
        #34
            InData[W_l - 1 : 0]           = 15'b000011010000011;//real //10 3
            InData[2 * W_l - 1 : W_l]     = 15'b111110101010011;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b111110110010101;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000010010011100;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b111001101101100;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b111011101110000;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b000001100010001;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000000111110110;//imag
            $display("%b",sortdata);
        #4
        #34
            InData[W_l - 1 : 0]           = 15'b111101011001010;//real //11
            InData[2 * W_l - 1 : W_l]     = 15'b000011101010001;//imag
            InData[3 * W_l - 1 : 2 * W_l] = 15'b000000100100000;//real
            InData[4 * W_l - 1 : 3 * W_l] = 15'b000011100001101;//imag
            InData[5 * W_l - 1 : 4 * W_l] = 15'b000110001000000;//real
            InData[6 * W_l - 1 : 5 * W_l] = 15'b000100010001010;//imag
            InData[7 * W_l - 1 : 6 * W_l] = 15'b111110010011000;//real
            InData[8 * W_l - 1 : 7 * W_l] = 15'b000000000001000;//imag
            $display("%b",sortdata);
        #10    
            $display("%b",sortdata);
          // 範例的80位元訊號
        
    end
    

    

endmodule

