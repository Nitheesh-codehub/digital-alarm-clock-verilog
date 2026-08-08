`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 11:15:23 AM
// Design Name: 
// Module Name: keyreg
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


module keyreg(
    input clk,rst,shift,
    input [3:0]key,
    output reg [3:0] key_buffer_ms_hr,
    output reg [3:0] key_buffer_ms_min,
    output reg [3:0] key_buffer_ls_hr,
    output reg [3:0] key_buffer_ls_min
    );
    
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            key_buffer_ms_hr <= 4'd0;
            key_buffer_ms_min <= 4'd0;
            key_buffer_ls_hr <= 4'd0;
            key_buffer_ls_min <= 4'd0;
        end
        
    else if(shift==1) 
        begin
            key_buffer_ms_hr <= key_buffer_ls_hr;
            key_buffer_ms_min <= key_buffer_ls_min;
            key_buffer_ls_hr <= key_buffer_ms_min;
            key_buffer_ls_min <= key;
        end
    end
endmodule