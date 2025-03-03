`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/18 22:59:14
// Design Name: 
// Module Name: tt
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


module Four_best_decoder(clk,rst,flagChannelorData,OutData,InData,sortdata);
    parameter W_l = 15;
    parameter W_0 = 15;
    input  wire [(W_l * 4 * 2)-1 : 0] InData;
    input  wire clk;
    input  wire rst; 
    input  wire flagChannelorData;

    output reg  [(4*2*W_0)-1:0] OutData;
    output reg  [(W_l -1) : 0] sortdata;
    integer i;
    integer j;
    reg [(4*4*2*W_l)-1:0] R_reg;
    reg [(4*2*W_l)-1:0] R_reg3;
    reg [(4*2*W_l)-1:0] R_reg2;
    reg [(4*2*W_l)-1:0] R_reg1;
    reg [(4*2*W_l)-1:0] R_reg4;
    
    wire  [(4*2*W_0)-1:0] detected;
    reg [(W_l * 4 * 2)-1:0] y_reg;
    reg [(W_l * 4 * 2)-1:0] y_reg2;
    reg [(W_l * 4 * 2)-1:0] y_setting_reg;
    reg [2:0]  current_state;
    reg [2:0] next_state;
    wire a;
    reg t;
    wire done;
    wire [(W_l -1) : 0] sort;
    localparam IDLE    = 3'd0;
    localparam LOAD_R  = 3'd1;
    localparam WAIT_Y  = 3'd2;
    localparam CALC    = 3'd3;
    localparam OUTPUT  = 3'd4;
    reg [2:0]counter_R;
    reg  [(4*2*W_0)-1:0] detect_out;
    reg  [(4*2*W_0)-1:0] output_reg;
    always@(negedge clk)
        begin
            if(rst) t<=0;
            else t<=a;
        end
    //state
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (flagChannelorData == 1'b1) next_state = LOAD_R;
                else next_state = IDLE;
            end
            LOAD_R: begin
                if(counter_R==5&&flagChannelorData == 1'b0)next_state = WAIT_Y;
                else next_state = LOAD_R;
                
            end  
            WAIT_Y: begin
                if (flagChannelorData == 1'b0&&y_reg2!=y_reg) 
                begin 
                    next_state = CALC;
                end
                else next_state = WAIT_Y;
            end 
            CALC: begin
                // 當內部4-best計算完成後，進入OUTPUT
                 if (t==1) next_state = OUTPUT;
                 else next_state = CALC;
                //next_state = OUTPUT;
            end         
            OUTPUT: begin
                next_state = WAIT_Y;
            end
            default: next_state = IDLE;
        endcase
    end

     always @(posedge clk ) begin
        if (rst) current_state <= IDLE;
        else current_state <= next_state;
    end
    
    always @(negedge clk)////////////////revise
    begin
        if (rst) 
        begin
            detect_out<=0;
        end 
        
        else
        begin
            if(current_state==OUTPUT) 
                begin
                   detect_out<=detected;
                end
            else  
                begin
                    output_reg <= detect_out ;
                    detect_out <= output_reg;
                end
        end
        
    end
    
    always @(* ) begin///////// revise

            case (current_state)
                LOAD_R: begin
                    OutData=0; 
                end
                WAIT_Y: begin
                                     
                end
                OUTPUT: begin                   

                    OutData=detect_out;
                    sortdata=sort;
                end
            endcase
    end
    /*
    always @(posedge clk ) begin
        if (rst) begin
            
            OutData<=0;
            
        end else begin
            case (current_state)
                LOAD_R: begin
                         
                end
                WAIT_Y: begin
                                     
                end
                OUTPUT: begin                   

                    OutData<=detected;
                end
            endcase
        end
    end
    */
    always @(posedge clk ) begin
        if (rst) 
        begin 
            R_reg <= 0;
            R_reg1<=0;
            R_reg2<=0;
            R_reg3<=0;
            R_reg4<=0;
        end
        else  begin 
                    if (current_state == LOAD_R && flagChannelorData == 1'b1) begin 
                        if (counter_R==1)
                        begin 
                            R_reg1 <= InData;
                        end
                        if (counter_R==2)
                        begin 
                            R_reg2 <= InData;
                        end
                        if (counter_R==3)
                        begin 
                            R_reg3 <= InData;
                        end
                        if (counter_R==4)
                        begin 
                            R_reg4 <= InData;
                            
                        end
                        if (counter_R==5)
                        begin 
                            R_reg <= {R_reg4,R_reg3,R_reg2,R_reg1};
                        end
                      end
                        
        end
    end
    
    reg [2:0] reg_R;
    always@(negedge clk)
    begin
    if (rst) 
        begin 
            counter_R<= 0;
        end
     else  begin
            if(current_state == LOAD_R && flagChannelorData == 1'b1&&counter_R<5)
             begin
                counter_R=counter_R+1'b1;
             end
        end
            
        
    end
    // 輸入ỹ
    always @(posedge clk ) begin
        if (rst) y_reg <= 0;
        else begin
        if (current_state == WAIT_Y && flagChannelorData == 1'b0) y_reg <= InData;
            
        end
    end
    
    always @(posedge clk ) begin
        if (rst) y_reg2 <= 1;
        else begin
            if (current_state == CALC && flagChannelorData == 1'b0) y_reg2 <= y_reg;
            
        end
    end


    
    decoder t0(
        .clk(clk),
        .R_in(R_reg),
        .y_in(y_reg),
        .rst(rst),
        .start(current_state == CALC),
        .decodedone(a),
        .sort_final(sort),
        .DetectedSymbol(detected)
        );

endmodule


module  decoder
(
    clk,
    y_in,
    R_in,
    start,
    rst,
    decodedone,
    sort_final,
    DetectedSymbol
);

    parameter W_l = 15;
    parameter W_0 = 15;
    input  wire [(W_l * 4 * 2)-1 : 0] y_in;
    input  wire clk;
    input  wire start;
    input  wire rst;
    input  wire [(4 * 4 * 2 * W_l) - 1 : 0] R_in;
    output reg signed [(4 * 2 * W_0) - 1 : 0] DetectedSymbol;
    output reg decodedone;
    output reg [W_l - 1 : 0]sort_final;
    reg signed [W_l - 1 : 0] R_in_real [0 : 3][0 : 3];   // 實部矩陣
    reg signed [W_l - 1 : 0] R_in_imag [0 : 3][0 : 3];   // 虛部矩陣
    integer i;
    integer j;
    
    
  
    
    reg signed [W_l - 1 : 0]  antenna_real[3 : 0];   // 天線 1 實部
    reg signed [W_l - 1 : 0]  antenna_imag[3 : 0];   // 天線 1 虛部
    
    
    
    reg [2 : 0] state, next_state;
    reg [2 : 0] done;
    localparam S_IDLE = 3'd0;
    localparam S_T4    = 3'd1;
    localparam S_T3    = 3'd2;
    localparam S_T2    = 3'd3;
    localparam S_T1    = 3'd4;
    localparam S_DONE  = 3'd5;
    always @(*) 
    begin
        next_state = state;
        case (state)
            S_IDLE: 
            begin 
                    if (start) 
                        next_state = S_T4;
                    else 
                        next_state =  S_IDLE;
            end
            S_T4:    
            begin 
                if (done == 3'b001) 
                   next_state = S_T3;
                else 
                   next_state = S_T4;
            end
            S_T3:
            begin 
                if (done == 3'b010) 
                    next_state = S_T2;
                else 
                    next_state = S_T3;
            end
            S_T2:
            begin
                if (done == 3'b011)
                    next_state = S_T1;
                else
                    next_state = S_T2;
            end
            S_T1:
            begin
                if (done == 3'b100)
                    next_state = S_DONE;
                else
                    next_state = S_T1;
            end
            S_DONE:   
                if(decodedone==1) next_state = S_IDLE;             
                else    next_state = S_DONE;                            
        endcase
    end
    
    //load y_hat
    always @(posedge clk) begin
        // 每次時鐘上升沿更新天線的實部和虛部
       if (rst) begin           
            antenna_real[0] <= 0;         // 天線 1 實部
            antenna_imag[0] <= 0;       // 天線 1 虛部
            antenna_real[1] <= 0;       // 天線 2 實部
            antenna_imag[1] <= 0;       // 天線 2 虛部
            antenna_real[2] <= 0;       // 天線 3 實部
            antenna_imag[2] <= 0;       // 天線 3 虛部
            antenna_real[3] <= 0;       // 天線 4 實部
            antenna_imag[3] <= 0;
        end else begin
            if (state!=S_IDLE&&start==1)
            begin
                antenna_real[0] <=   y_in[W_l - 1 : 0];         // 天線 1 實部
                antenna_imag[0] <=   y_in[2 * W_l - 1 : W_l];       // 天線 1 虛部
                antenna_real[1] <=   y_in[3 * W_l - 1 : 2 * W_l];       // 天線 2 實部
                antenna_imag[1] <=   y_in[4 * W_l - 1 : 3 * W_l];       // 天線 2 虛部
                antenna_real[2] <=   y_in[5 * W_l - 1 : 4 * W_l];       // 天線 3 實部
                antenna_imag[2] <=   y_in[6 * W_l - 1 : 5 * W_l];       // 天線 3 虛部
                antenna_real[3] <=   y_in[7 * W_l - 1 : 6 * W_l];       // 天線 4 實部
                antenna_imag[3] <=   y_in[8 * W_l - 1 : 7 * W_l];       // 天線 4 虛部
            end
            else begin
                antenna_real[0] <=   0;         // 天線 1 實部
                antenna_imag[0] <=   0;       // 天線 1 虛部
                antenna_real[1] <=   0;       // 天線 2 實部
                antenna_imag[1] <=   0;       // 天線 2 虛部
                antenna_real[2] <=   0;       // 天線 3 實部
                antenna_imag[2] <=   0;       // 天線 3 虛部
                antenna_real[3] <=   0;       // 天線 4 實部
                antenna_imag[3] <=   0;       // 天線 4 虛部
            end
            
        end
        
    end
    
    

    
    
    //Load R
     always @(posedge clk ) begin///////revise done
        if (rst) begin           
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    R_in_real[i][j] <= 0;
                    R_in_imag[i][j] <= 0;
                end
            end
        end else begin
            if (state!=S_IDLE&&start==1)
                begin
                    R_in_real[0][0] <= R_in[W_l - 1 : 0];//00
                    R_in_real[0][1] <= R_in[2 * W_l - 1 : W_l];
                    R_in_real[0][2] <= R_in[3 * W_l - 1 : 2 * W_l];
                    R_in_real[0][3] <= R_in[4 * W_l - 1 : 3 * W_l];
                    R_in_real[1][0] <= R_in[5 * W_l - 1 : 4 * W_l];
                    R_in_real[1][1] <= R_in[6 * W_l - 1 : 5 * W_l];//11
                    R_in_real[1][2] <= R_in[7 * W_l - 1 : 6 * W_l];
                    R_in_real[1][3] <= R_in[8 * W_l - 1 : 7 * W_l];
                    R_in_real[2][0] <= R_in[9 * W_l - 1 : 8 * W_l];
                    R_in_real[2][1] <= R_in[10 * W_l - 1 : 9 * W_l];
                    R_in_real[2][2] <= R_in[11 * W_l - 1 : 10 * W_l];//22
                    R_in_real[2][3] <= R_in[12 * W_l - 1 : 11 * W_l];
                    R_in_real[3][0] <= R_in[13 * W_l - 1 : 12 * W_l];
                    R_in_real[3][1] <= R_in[14 * W_l - 1 : 13 * W_l];
                    R_in_real[3][2] <= R_in[15 * W_l - 1 : 14 * W_l];
                    R_in_real[3][3] <= R_in[16 * W_l - 1 : 15 * W_l];//33
                    
                    R_in_imag[0][0] <= R_in[17 * W_l - 1 : 16 * W_l];//00
                    R_in_imag[0][1] <= R_in[18 * W_l - 1 : 17 * W_l];
                    R_in_imag[0][2] <= R_in[19 * W_l - 1 : 18 * W_l];
                    R_in_imag[0][3] <= R_in[20 * W_l - 1 : 19 * W_l];
                    R_in_imag[1][0] <= R_in[21 * W_l - 1 : 20 * W_l];
                    R_in_imag[1][1] <= R_in[22 * W_l - 1 : 21 * W_l];//11
                    R_in_imag[1][2] <= R_in[23 * W_l - 1 : 22 * W_l];
                    R_in_imag[1][3] <= R_in[24 * W_l - 1 : 23 * W_l];
                    R_in_imag[2][0] <= R_in[25 * W_l - 1 : 24 * W_l];
                    R_in_imag[2][1] <= R_in[26 * W_l - 1 : 25 * W_l];
                    R_in_imag[2][2] <= R_in[27 * W_l - 1 : 26 * W_l];//22
                    R_in_imag[2][3] <= R_in[28 * W_l - 1 : 27 * W_l];
                    R_in_imag[3][0] <= R_in[29 * W_l - 1 : 28 * W_l];
                    R_in_imag[3][1] <= R_in[30 * W_l - 1 : 29 * W_l];
                    R_in_imag[3][2] <= R_in[31 * W_l - 1 : 30 * W_l];
                    R_in_imag[3][3] <= R_in[32 * W_l - 1 : 31 * W_l];//33
                end
            else
                begin
                    for (i = 0; i < 4; i = i + 1) 
                    begin
                            for (j = 0; j < 4; j = j + 1) 
                            begin
                                R_in_real[i][j] <= 0;
                                R_in_imag[i][j] <= 0;
                            end
                    end
                end
        end
    end
    
    
     // initial constellation point
     
    reg signed [W_l - 1 : 0] PSK_8_lut_real [0:7];  // 實部 LUT
    reg signed [W_l - 1 : 0] PSK_8_lut_imag [0:7];  // 虛部 LUT
    reg  [2:0] PSK_code_lut [0:7];            // 3-bit 碼 LUT
    
    always@(posedge clk)////////revise done
    if (rst)
        begin
                for (i = 0; i < 8; i = i + 1) 
                    begin
                           PSK_8_lut_real[i]<=0;
                           PSK_8_lut_imag[i]<=0;
                    end
                
        end
   else begin
        // 8-PSK 星座圖的實部 (cos(θ))
        PSK_8_lut_real[0] <= 15'b000010000000000;  // cos(0) = 1
        PSK_8_lut_real[1] <= 15'b000001011010100;  // cos(π/4)=0.707
        PSK_8_lut_real[2] <= 15'b000000000000000;  // cos(π/2) = 0
        PSK_8_lut_real[3] <= 15'b111110100101100;  // cos(3π/4)=-0.707
        PSK_8_lut_real[4] <= 15'b111110000000000;  // cos(π) = -1
        PSK_8_lut_real[5] <= 15'b111110100101100;  // cos(5π/4)=-0.707
        PSK_8_lut_real[6] <= 15'b000000000000000;  // cos(3π/2) = 0
        PSK_8_lut_real[7] <= 15'b000001011010100;  // cos(7π/4)=0.707

        // 8-PSK 星座圖的虛部 (sin(θ))
        PSK_8_lut_imag[0] <= 15'b000000000000000;  // sin(0) = 0
        PSK_8_lut_imag[1] <= 15'b000001011010100;  // sin(π/4)=0.707
        PSK_8_lut_imag[2] <= 15'b000010000000000;  // sin(π/2) = 1
        PSK_8_lut_imag[3] <= 15'b000001011010100;  // sin(3π/4)=0.707
        PSK_8_lut_imag[4] <= 15'b000000000000000;  // sin(π) = 0
        PSK_8_lut_imag[5] <= 15'b111110100101100;  // sin(5π/4)=-0.707
        PSK_8_lut_imag[6] <= 15'b111110000000000;  // sin(3π/2) = -1
        PSK_8_lut_imag[7] <= 15'b111110100101100;  // sin(7π/4)=-0.707

        /*
        // 8-PSK 星座圖的碼映射
        PSK_code_lut[0] = 3'b111;  // 0度: 111
        PSK_code_lut[1] = 3'b110;  // 45度: 110
        PSK_code_lut[2] = 3'b010;  // 90度: 010
        PSK_code_lut[3] = 3'b011;  // 135度: 011
        PSK_code_lut[4] = 3'b001;  // 180度: 001
        PSK_code_lut[5] = 3'b000;  // 225度: 000
        PSK_code_lut[6] = 3'b100;  // 270度: 100
        PSK_code_lut[7] = 3'b101;  // 315度: 101
        */
    end
    
      //state machine
    

    //decoding state
    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
            state <= S_IDLE;
        else 
            state <= next_state;
    end
    reg signed [W_l - 1 : 0] t4register_real [7 : 0];
    reg signed [W_l - 1 : 0] t4register_imag [7 : 0];
    //reg signed [9:0] t4register_real_final [7:0];
    //reg signed [9:0] t4register_imag_final [7:0];
    reg [W_l - 1 : 0] t4reg_real [7 : 0];
    reg [W_l - 1 : 0] t4reg_imag [7 : 0];
    reg [W_l - 1 : 0] t4register_total [7 : 0];
    reg [W_l - 1 : 0] sorted_data_T4 [7 : 0]; // sorted data T4
    reg [2:0] sorted_index_T4 [7 : 0]; // sorted index T4
    reg [W_l - 1 : 0] temp_data_T4;
    reg [2 : 0] temp_index_T4;
    reg signed [2 * W_l - 1 : 0] regg_real_T4;
    reg signed [2 * W_l - 1 : 0] regg_imag_T4;
    reg signed [W_l - 1 : 0] T4_constall_real_10;
    reg signed [W_l - 1 : 0] T4_constall_imag_10;
    reg [1:0] counter_T4;
    reg [W_l - 1 : 0] reg_T4;
    reg [W_l - 1 : 0] reg_j_T4;
    reg [2 : 0]  reg_index_T4;
    reg [2 : 0]  reg_index_j_T4; 
    reg        [W_l - 1 : 0] new_sorted_data_T4 [3:0];
    reg        [2 : 0]  new_sorted_index_T4 [3:0];                                               
    //////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////            S_T3            /////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    reg signed [W_l - 1 : 0]  t3register_real [31:0];
    reg signed [W_l - 1 : 0]  t3register_imag [31:0];
    //reg signed [9:0] t3register_real_final [31:0];
    //reg signed [9:0] t3register_imag_final [31:0];
    reg        [W_l - 1 : 0]  t3reg_real [31:0];
    reg        [W_l - 1 : 0]  t3reg_imag [31:0];
    reg        [W_l - 1 : 0] t3register_total [31:0];
    reg        [W_l - 1 : 0] sorted_data_T3 [31:0]; // sorted data T3
    reg        [5 : 0]  sorted_index_T3 [31:0]; // sorted index T3
    reg        [W_l - 1 : 0] temp_data_T3;
    reg        [5 : 0]  temp_index_T3; 
    reg signed [2 * W_l - 1 : 0] regg_real_T3;
    reg signed [2 * W_l - 1 : 0] regg_imag_T3;
    reg signed [W_l - 1 : 0] T3_constall_real_10;
    reg signed [W_l - 1 : 0] T3_constall_imag_10;
    reg        [1:0] counter_T3;
    reg [W_l - 1 : 0] reg_T3;
    reg [W_l - 1 : 0] reg_j_T3;
    reg [5 : 0]  reg_index_T3;
    reg [5 : 0]  reg_index_j_T3;
    reg        [W_l - 1 : 0] new_sorted_data_T3 [3:0];
    reg        [5 : 0]  new_sorted_index_T3 [3:0];  
    //////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////            S_T2            /////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    reg signed [2 * W_l - 1 : 0] regg_real_T2;
    reg signed [2 * W_l - 1 : 0] regg_imag_T2;
    reg signed [W_l - 1 : 0]  t2register_real [31:0];
    reg signed [W_l - 1 : 0]  t2register_imag [31:0];
    reg        [W_l - 1 : 0]  t2reg_real [31 : 0];
    reg        [W_l - 1 : 0]  t2reg_imag [31 : 0];
    reg        [W_l - 1 : 0]  t2register_total [31 : 0];
    reg        [W_l - 1 : 0] sorted_data_T2 [31:0];
    reg        [8 : 0]  sorted_index_T2 [31:0];
    reg        [W_l - 1 : 0] temp_data_T2;
    reg        [8 : 0]  temp_index_T2; 
    reg        [1:0] counter_T2;
    reg [W_l - 1 : 0] reg_T2;
    reg [W_l - 1 : 0] reg_j_T2;
    reg [8 : 0]  reg_index_T2;
    reg [8 : 0]  reg_index_j_T2;
    reg        [W_l - 1 : 0] new_sorted_data_T2 [3:0];
    reg        [8 : 0]  new_sorted_index_T2 [3:0]; 
    //////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////            S_T1           /////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    reg signed [2 * W_l - 1 : 0] regg_real_T1;
    reg signed [2 * W_l - 1 : 0] regg_imag_T1;
    reg signed [W_l - 1 : 0]  t1register_real [31:0];
    reg signed [W_l - 1 : 0]  t1register_imag [31:0];
    reg        [W_l - 1 : 0]  t1reg_real [31 : 0];
    reg        [W_l - 1 : 0]  t1reg_imag [31 : 0];
    reg        [W_l - 1 : 0]  t1register_total [31 : 0];
    reg        [W_l - 1 : 0] sorted_data_T1 [31:0];
    reg        [11 : 0]  sorted_index_T1 [31:0];
    reg        [W_l - 1 : 0] temp_data_T1;
    reg        [11 : 0]  temp_index_T1; 
    reg        [1:0] counter_T1;
    reg        [W_l - 1 : 0] reg_T1;
    reg        [W_l - 1 : 0] reg_j_T1;
    reg        [11 : 0]  reg_index_T1;
    reg        [11 : 0]  reg_index_j_T1;
    reg        [W_l - 1 : 0] new_sorted_data_T1 [3:0];
    reg        [11 : 0]  new_sorted_index_T1 [3:0];
    // bfs
     always @(posedge clk) begin
        if (~start) 
        begin
            DetectedSymbol <= 0;
            done <= 3'b000;
            decodedone<=0;
        end 
        else 

        begin
            case (state)
                S_IDLE: 
                begin
                    decodedone<=0;
                    counter_T1<=0;
                    counter_T2<=0;
                    counter_T3<=0;
                    counter_T4<=0;
                end
                S_T4: begin
                    // 計算x4層所有8個候選距離並排序
                        for (i=0; i<8 ;i=i+1)
                             begin
                                regg_real_T4 = R_in_real[3][3] * PSK_8_lut_real[i] - R_in_imag[3][3] * PSK_8_lut_imag[i];
                                regg_imag_T4 = R_in_real[3][3] * PSK_8_lut_imag[i] + R_in_imag[3][3] * PSK_8_lut_real[i];


                                t4register_real[i] = antenna_real[3] - regg_real_T4[24 : 10];
                                t4register_imag[i] = antenna_imag[3] - regg_imag_T4[24 : 10];                                                              
                                t4reg_real[i] = (t4register_real[i][14] ==1) ? -t4register_real[i] : t4register_real[i];
                                t4reg_imag[i] = (t4register_imag[i][14] ==1) ? -t4register_imag[i] : t4register_imag[i];
                                
                             end
                             
                             for (i=0; i<8 ;i=i+1)
                             begin
                                t4register_total[i] = t4reg_real[i] + t4reg_imag[i];
                             end
                             for (i = 0; i < 8; i = i + 1) 
                             begin
                                    sorted_data_T4[i] = t4register_total[i];
                                    sorted_index_T4[i] = i;
                             end
                             for (i = 0; i < 4; i = i + 1)
                                 begin
                                    for (j = i + 1; j < 8; j = j + 1) 
                                         begin
                                            if (sorted_data_T4[i] > sorted_data_T4[j]) 
                                                begin
                                             
                                                                temp_data_T4 = sorted_data_T4[i];
                                                                sorted_data_T4[i] = sorted_data_T4[j];
                                                                sorted_data_T4[j] = temp_data_T4;
                                                                //reg_T4=new_sorted_data_T4[i];
                                                                //temp_data_T4=reg_T4;
                                                                //reg_j_T4=new_sorted_data_T4[j];
                                                                //new_sorted_data_T4[i]=reg_j_T4;
                                                                //new_sorted_data_T4[j]=temp_data_T4;
                                                            
                                                                temp_index_T4 = sorted_index_T4[i];
                                                                sorted_index_T4[i] = sorted_index_T4[j];
                                                                sorted_index_T4[j] = temp_index_T4;
                                                                //reg_index_T4=new_sorted_index_T4[i];
                                                                //temp_index_T4=reg_index_T4;
                                                                //reg_index_j_T4=new_sorted_index_T4[j];
                                                                //new_sorted_index_T4[i]=reg_index_j_T4;
                                                                //new_sorted_index_T4[j]=temp_index_T4;
                                                end
                                                
                                             else
                                                begin
                                                                    reg_T4=new_sorted_data_T4[i];
                                                                    new_sorted_data_T4[i]=reg_T4;
                                                                    temp_data_T4=reg_T4;
                                                                    reg_j_T4=new_sorted_data_T4[j];
                                                                    new_sorted_data_T4[j]=reg_j_T4; 
                                                          
                                                                    reg_index_T4=new_sorted_index_T4[i];
                                                                    new_sorted_index_T4[i]=reg_index_T4;
                                                                    temp_index_T4=reg_index_T4;
                                                                    reg_index_j_T4=new_sorted_index_T4[j];
                                                                    new_sorted_index_T4[j]=reg_index_j_T4;
                                                end
                                                
                                         end 
                                      counter_T4<=i;         
                                  end
                        
                    // 保存Top-4結果 (包含其索引與累計距離)
                    if (counter_T4==2'd3)
                            begin
                                done <= 3'b001;// after detection                              
                            end 
                    else 
                        begin
                            done <= 3'b000;// after detection                              
                        end 
                    
                     
                end
                S_T3: begin
                    // 針對T4 Top-4，每個再搭8個x3, 共32組計算
                            for (i = 0; i < 4 ; i = i + 1)
                                 begin
                                        for (j = 0; j < 8; j = j + 1)
                                        begin
                                            regg_real_T4 = R_in_real[2][3] * PSK_8_lut_real[sorted_index_T4[i]] - R_in_imag[2][3] * PSK_8_lut_imag[sorted_index_T4[i]];
                                            regg_imag_T4 = R_in_real[2][3] * PSK_8_lut_imag[sorted_index_T4[i]] + R_in_imag[2][3] * PSK_8_lut_real[sorted_index_T4[i]];
                                            regg_real_T3 = R_in_real[2][2] * PSK_8_lut_real[j] - R_in_imag[2][2] * PSK_8_lut_imag[j];
                                            regg_imag_T3 = R_in_real[2][2] * PSK_8_lut_imag[j] + R_in_imag[2][2] * PSK_8_lut_real[j];



                                            t3register_real[8 * i + j] <= antenna_real[2] - regg_real_T4[24 : 10] - regg_real_T3[24 : 10];
                                            t3register_imag[8 * i + j] <= antenna_imag[2] - regg_imag_T4[24 : 10] - regg_imag_T3[24 : 10];
                                            t3reg_real[8 * i + j] <= (t3register_real[8 * i + j][14] ==1) ? -t3register_real[8 * i + j] : t3register_real[8 * i + j];
                                            t3reg_imag[8 * i + j] <= (t3register_imag[8 * i + j][14] ==1) ? -t3register_imag[8 * i + j] : t3register_imag[8 * i + j];
                                        end
                                 end 
                                 
                            for (i = 0; i < 32 ; i = i + 1)
                                begin
                                    t3register_total[i] = t3reg_real[i] + t3reg_imag[i];
                                end
                            for (i = 0; i < 4 ; i = i + 1)
                                 begin
                                        for (j = 0; j < 8; j = j + 1)
                                        begin
                                            sorted_data_T3[8 * i + j] = t3register_total[8 * i + j] + sorted_data_T4[i];
                                            sorted_index_T3[8 * i + j][2 : 0] = j;
                                            sorted_index_T3[8 * i + j][5 : 3] = sorted_index_T4[i];
                                        end
                                 end 
                            for (i = 0; i < 4; i = i + 1)
                                     begin
                                        for (j = i + 1; j < 32; j = j + 1) 
                                             begin
                                                if (sorted_data_T3[i] > sorted_data_T3[j]) 
                                                    begin
                                                 
                                                        temp_data_T3 = sorted_data_T3[i];
                                                        sorted_data_T3[i] = sorted_data_T3[j];
                                                        sorted_data_T3[j] = temp_data_T3;
                                                        //reg_T3=new_sorted_data_T3[i];
                                                        //temp_data_T3=reg_T3;
                                                        //reg_j_T3=new_sorted_data_T3[j];
                                                        //new_sorted_data_T3[i]=reg_j_T3;
                                                        //new_sorted_data_T3[j]=temp_data_T3;
                                                    
                                                    
                                                        temp_index_T3 = sorted_index_T3[i];
                                                        sorted_index_T3[i] = sorted_index_T3[j];
                                                        sorted_index_T3[j] = temp_index_T3;
                                                        //reg_index_T3=new_sorted_index_T3[i];
                                                        //temp_index_T3=reg_index_T3;
                                                        //reg_index_j_T3=new_sorted_index_T3[j];
                                                        //new_sorted_index_T3[i]=reg_index_j_T3;
                                                        //new_sorted_index_T3[j]=temp_index_T3;
                                                    end
                                                    
                                                else
                                                    begin
                                                            reg_T3=new_sorted_data_T3[i];
                                                            new_sorted_data_T3[i]=reg_T3;
                                                            temp_data_T3=reg_T3;
                                                            reg_j_T3=new_sorted_data_T3[j];
                                                            new_sorted_data_T3[j]=reg_j_T3; 
                                                  
                                                            reg_index_T3=new_sorted_index_T3[i];
                                                            new_sorted_index_T3[i]=reg_index_T3;
                                                            temp_index_T3=reg_index_T3;
                                                            reg_index_j_T3=new_sorted_index_T3[j];
                                                            new_sorted_index_T3[j]=reg_index_j_T3;
                                                    end
                                                    
                                             end  
                                         counter_T3<=i;       
                                     end
                            
                    // 取Top-4
                        if (counter_T3==2'd3)
                            begin
                                done <= 3'b010;// after detection                              
                            end 
                        else 
                            begin
                                done <= 3'b001;// after detection                              
                            end 
                end
                
                S_T2: 
                begin
                    // 針對T4 Top-4，每個再搭8個x3, 共32組計算
                            for (i = 0; i < 4 ; i = i + 1)
                                 begin
                                        for (j = 0; j < 8; j = j + 1)
                                        begin
                                            regg_real_T4 = R_in_real[1][3] * PSK_8_lut_real[ sorted_index_T3[ i ][5 : 3] ] - R_in_imag[1][3] * PSK_8_lut_imag[ sorted_index_T3[ i ][5 : 3] ];
                                            regg_imag_T4 = R_in_real[1][3] * PSK_8_lut_imag[ sorted_index_T3[ i ][5 : 3] ] + R_in_imag[1][3] * PSK_8_lut_real[ sorted_index_T3[ i ][5 : 3] ];
                                            regg_real_T3 = R_in_real[1][2] * PSK_8_lut_real[ sorted_index_T3[ i ][2 : 0] ] - R_in_imag[1][2] * PSK_8_lut_imag[ sorted_index_T3[ i ][2 : 0] ];
                                            regg_imag_T3 = R_in_real[1][2] * PSK_8_lut_imag[ sorted_index_T3[ i ][2 : 0] ] + R_in_imag[1][2] * PSK_8_lut_real[ sorted_index_T3[ i ][2 : 0] ];
                                            
                                            regg_real_T2 = R_in_real[1][1] * PSK_8_lut_real[j] - R_in_imag[1][1] * PSK_8_lut_imag[j];
                                            regg_imag_T2 = R_in_real[1][1] * PSK_8_lut_imag[j] + R_in_imag[1][1] * PSK_8_lut_real[j];

                                            t2register_real[8 * i + j] <= antenna_real[1] - regg_real_T4[24 : 10] - regg_real_T3[24 : 10] - regg_real_T2[24 : 10];
                                            t2register_imag[8 * i + j] <= antenna_imag[1] - regg_imag_T4[24 : 10] - regg_imag_T3[24 : 10] - regg_imag_T2[24 : 10];
                                            t2reg_real[8 * i + j] <= (t2register_real[8 * i + j][14] ==1) ? -t2register_real[8 * i + j] : t2register_real[8 * i + j];
                                            t2reg_imag[8 * i + j] <= (t2register_imag[8 * i + j][14] ==1) ? -t2register_imag[8 * i + j] : t2register_imag[8 * i + j];
                                        end
                                 end 
                                 
                            for (i = 0; i < 32 ; i = i + 1)
                                begin
                                    t2register_total[i] = t2reg_real[i] + t2reg_imag[i];
                                end
                            for (i = 0; i < 4 ; i = i + 1)
                                 begin
                                        for (j = 0; j < 8; j = j + 1)
                                        begin
                                            sorted_data_T2[8 * i + j] = t2register_total[8 * i + j] + sorted_data_T3[ i ];
                                            sorted_index_T2[8 * i + j][2 : 0] = j;
                                            sorted_index_T2[8 * i + j][8 : 3] = sorted_index_T3[ i ];
                                        end
                                 end 
                            for (i = 0; i < 4; i = i + 1)
                              begin
                                    for (j = i + 1; j < 32; j = j + 1) 
                                    begin
                                        if (sorted_data_T2[i] > sorted_data_T2[j]) 
                                            begin
                                                        temp_data_T2 = sorted_data_T2[i];
                                                        sorted_data_T2[i] = sorted_data_T2[j];
                                                        sorted_data_T2[j] = temp_data_T2;
                                                        //reg_T2=new_sorted_data_T2[i];
                                                        //temp_data_T2=reg_T2;
                                                        //reg_j_T2=new_sorted_data_T2[j];
                                                        //new_sorted_data_T2[i]=reg_j_T2;
                                                        //new_sorted_data_T2[j]=temp_data_T2;
                                                    
                                                    
                                                        temp_index_T2 = sorted_index_T2[i];
                                                        sorted_index_T2[i] = sorted_index_T2[j];
                                                        sorted_index_T2[j] = temp_index_T2;
                                                        //reg_index_T2=new_sorted_index_T2[i];
                                                        //temp_index_T2=reg_index_T2;
                                                        //reg_index_j_T2=new_sorted_index_T2[j];
                                                        //new_sorted_index_T2[i]=reg_index_j_T2;
                                                        //new_sorted_index_T2[j]=temp_index_T2;
                                            end
                                            
                                         else
                                            begin
                                                        reg_T2=new_sorted_data_T2[i];
                                                        new_sorted_data_T2[i]=reg_T2;
                                                        temp_data_T2=reg_T2;
                                                        reg_j_T2=new_sorted_data_T2[j];
                                                        new_sorted_data_T2[j]=reg_j_T2; 
                                                      
                                                        reg_index_T2=new_sorted_index_T2[i];
                                                        new_sorted_index_T2[i]=reg_index_T2;
                                                        temp_index_T2=reg_index_T2;
                                                        reg_index_j_T2=new_sorted_index_T2[j];
                                                        new_sorted_index_T2[j]=reg_index_j_T2; 
                                            end
                                            
                                     end  
                                     counter_T2<=i;        
                              end
                            

                    // 取Top-4
                        if (counter_T2==2'd3)
                            begin
                                done <= 3'b011;// after detection
                            end
                        else 
                            begin
                                done <= 3'b010;// after detection                              
                            end  
                end
                
                S_T1: 
                begin
                    // 針對T4 Top-4，每個再搭8個x3, 共32組計算
                            for (i = 0; i < 4 ; i = i + 1)
                                 begin
                                        for (j = 0; j < 8; j = j + 1)
                                        begin
                                            regg_real_T4 = R_in_real[0][3] * PSK_8_lut_real[ sorted_index_T2[ i ][8 : 6] ] - R_in_imag[0][3] * PSK_8_lut_imag[ sorted_index_T2[ i ][8 : 6] ];
                                            regg_imag_T4 = R_in_real[0][3] * PSK_8_lut_imag[ sorted_index_T2[ i ][8 : 6] ] + R_in_imag[0][3] * PSK_8_lut_real[ sorted_index_T2[ i ][8 : 6] ];
                                            regg_real_T3 = R_in_real[0][2] * PSK_8_lut_real[ sorted_index_T2[ i ][5 : 3] ] - R_in_imag[0][2] * PSK_8_lut_imag[ sorted_index_T2[ i ][5 : 3] ];
                                            regg_imag_T3 = R_in_real[0][2] * PSK_8_lut_imag[ sorted_index_T2[ i ][5 : 3] ] + R_in_imag[0][2] * PSK_8_lut_real[ sorted_index_T2[ i ][5 : 3] ];
                                            regg_real_T2 = R_in_real[0][1] * PSK_8_lut_real[ sorted_index_T2[ i ][2 : 0] ] - R_in_imag[0][1] * PSK_8_lut_imag[ sorted_index_T2[ i ][2 : 0] ];
                                            regg_imag_T2 = R_in_real[0][1] * PSK_8_lut_imag[ sorted_index_T2[ i ][2 : 0] ] + R_in_imag[0][1] * PSK_8_lut_real[ sorted_index_T2[ i ][2 : 0] ];
                                            
                                            regg_real_T1 = R_in_real[0][0] * PSK_8_lut_real[ j ] - R_in_imag[0][0] * PSK_8_lut_imag[ j ];
                                            regg_imag_T1 = R_in_real[0][0] * PSK_8_lut_imag[ j ] + R_in_imag[0][0] * PSK_8_lut_real[ j ];

                                            t1register_real[8 * i + j] <= antenna_real[ 0 ] - regg_real_T4[24 : 10] - regg_real_T3[24 : 10] - regg_real_T2[24 : 10] - regg_real_T1[24 : 10];
                                            t1register_imag[8 * i + j] <= antenna_imag[0] - regg_imag_T4[24 : 10] - regg_imag_T3[24 : 10] - regg_imag_T2[24 : 10] - regg_imag_T1[24 : 10];
                                            t1reg_real[8 * i + j] <= (t1register_real[8 * i + j][14] ==1) ? -t1register_real[8 * i + j] : t1register_real[8 * i + j];
                                            t1reg_imag[8 * i + j] <= (t1register_imag[8 * i + j][14] ==1) ? -t1register_imag[8 * i + j] : t1register_imag[8 * i + j];
                                        end
                                 end 
                                 
                            for (i = 0; i < 32 ; i = i + 1)
                                begin
                                    t1register_total[ i ] = t1reg_real[ i ] + t1reg_imag[ i ];
                                end
                            for (i = 0; i < 4 ; i = i + 1)
                                 begin
                                        for (j = 0; j < 8; j = j + 1)
                                        begin
                                            sorted_data_T1[8 * i + j] = t1register_total[8 * i + j] + sorted_data_T2[ i ];
                                            sorted_index_T1[8 * i + j][2 : 0] = j;
                                            sorted_index_T1[8 * i + j][11 : 3] = sorted_index_T2[ i ];
                                        end
                                 end 
                            for (i = 0; i < 4; i = i + 1)
                             begin
                                    for (j = i + 1; j < 32; j = j + 1) 
                                    begin
                                        if (sorted_data_T1[i] > sorted_data_T1[j]) 
                                            begin
                                                        temp_data_T1 = sorted_data_T1[i];
                                                        sorted_data_T1[i] = sorted_data_T1[j];
                                                        sorted_data_T1[j] = temp_data_T1;
                                                        //reg_T1=new_sorted_data_T1[i];
                                                        //temp_data_T1=reg_T1;
                                                        //reg_j_T1=new_sorted_data_T1[j];
                                                        //new_sorted_data_T1[i]=reg_j_T1;
                                                        //new_sorted_data_T1[j]=temp_data_T1;
                                                    
                                                    
                                                        temp_index_T1 = sorted_index_T1[i];
                                                        sorted_index_T1[i] = sorted_index_T1[j];
                                                        sorted_index_T1[j] = temp_index_T1;
                                                        //reg_index_T1=new_sorted_index_T1[i];
                                                        //temp_index_T1=reg_index_T1;
                                                        //reg_index_j_T1=new_sorted_index_T1[j];
                                                        //new_sorted_index_T1[i]=reg_index_j_T1;
                                                        //new_sorted_index_T1[j]=temp_index_T1;
                                            end
                                            
                                         else
                                            begin
                                                      reg_T1=new_sorted_data_T1[i];
                                                      new_sorted_data_T1[i]=reg_T1;
                                                      temp_data_T1=reg_T1;
                                                      reg_j_T1=new_sorted_data_T1[j];
                                                      new_sorted_data_T1[j]=reg_j_T1; 
                                                      
                                                      reg_index_T1=new_sorted_index_T1[i];
                                                      new_sorted_index_T1[i]=reg_index_T1;
                                                      temp_index_T1=reg_index_T1;
                                                      reg_index_j_T1=new_sorted_index_T1[j];
                                                      new_sorted_index_T1[j]=reg_index_j_T1; 
                                            end
                                            
                                     end 
                                     counter_T1<=i;         
                              end
                            
                    // 取Top-4
                    if (counter_T1==2'd3)
                            begin
                                done <= 3'b100;// after detection
                                                   
                            end 
                    else 
                            begin
                                done <= 3'b011;// after detection                              
                            end 
                    
                end
                
                S_DONE: begin
                    // 計算結束
                    DetectedSymbol[W_l - 1 : 0]           <= PSK_8_lut_real[ sorted_index_T1[0][2:0] ];
                    DetectedSymbol[2 * W_l - 1 : W_l]     <= PSK_8_lut_imag[ sorted_index_T1[0][2:0] ];
                    DetectedSymbol[3 * W_l - 1 : 2 * W_l] <= PSK_8_lut_real[ sorted_index_T1[0][5:3] ];
                    DetectedSymbol[4 * W_l - 1 : 3 * W_l] <= PSK_8_lut_imag[ sorted_index_T1[0][5:3] ];
                    DetectedSymbol[5 * W_l - 1 : 4 * W_l] <= PSK_8_lut_real[ sorted_index_T1[0][8:6] ];
                    DetectedSymbol[6 * W_l - 1 : 5 * W_l] <= PSK_8_lut_imag[ sorted_index_T1[0][8:6] ];
                    DetectedSymbol[7 * W_l - 1 : 6 * W_l] <= PSK_8_lut_real[ sorted_index_T1[0][11:9] ];
                    DetectedSymbol[8 * W_l - 1 : 7 * W_l] <= PSK_8_lut_imag[ sorted_index_T1[0][11:9] ];
                    decodedone<=1; 
                    sort_final<=sorted_data_T1[0];
                    //done <= 3'b101;
                end
            endcase
        end
    end


    
endmodule