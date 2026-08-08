`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2026 02:04:20 PM
// Design Name: 
// Module Name: counter
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


module counter(
    input clk,
    input rst,
    input one_minute,
    input load_new_c,
    input [3:0]new_current_time_ms_hr,
    input [3:0]new_current_time_ms_min,
    input [3:0]new_current_time_ls_hr,
    input [3:0]new_current_time_ls_min,
    output reg [3:0]current_time_ms_hr,
    output reg [3:0]current_time_ms_min,
    output reg [3:0]current_time_ls_hr,
    output reg [3:0]current_time_ls_min  
    );
    
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    current_time_ms_hr<=4'd0;
    current_time_ms_min<=4'd0;
    current_time_ls_hr<=4'd0;
    current_time_ls_min<=4'd0;
    end
    
    else if(load_new_c) begin
    current_time_ms_hr<=new_current_time_ms_hr;
    current_time_ms_min<=new_current_time_ms_min;
    current_time_ls_hr<=new_current_time_ls_hr;
    current_time_ls_min<=new_current_time_ls_min;    
    end
    
    else if(one_minute==1) 
    begin
    if(current_time_ms_hr==4'd2 && current_time_ms_min==4'd5 && current_time_ls_hr==4'd3 && current_time_ls_min==4'd9)
    begin
        current_time_ms_hr<=4'd0;
        current_time_ms_min<=4'd0;
        current_time_ls_hr<=4'd0;
        current_time_ls_min<=4'd0;
    end
    else if(current_time_ms_min==4'd5 && current_time_ls_hr==4'd9 && current_time_ls_min==4'd9)
    begin
        current_time_ms_hr<=current_time_ms_hr+1'd1;
        current_time_ms_min<=4'd0;
        current_time_ls_hr<=4'd0;
        current_time_ls_min<=4'd0;
    end
    else if(current_time_ms_min==4'd5 && current_time_ls_min==4'd9)
    begin
        current_time_ls_hr<=current_time_ls_hr+1'd1;
        current_time_ls_min<=4'd0;
        current_time_ms_min<=4'd0;
    end
    else if(current_time_ls_min==4'd9)
    begin
        current_time_ms_min<=current_time_ms_min+1'd1;
        current_time_ls_min<=4'd0;
    end
    else begin
        current_time_ls_min<=current_time_ls_min+1'd1;
    end
    end
    end
endmodule