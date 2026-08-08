`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2026 02:32:18 PM
// Design Name: 
// Module Name: alarm_reg
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


module alarm_reg(
    input clk,
    input rst,
    input load_new_a,
    input [3:0]new_alarm_time_ms_hr,
    input [3:0]new_alarm_time_ms_min,
    input [3:0]new_alarm_time_ls_hr,
    input [3:0]new_alarm_time_ls_min,
    output reg [3:0]alarm_time_ms_hr,
    output reg [3:0]alarm_time_ms_min,
    output reg [3:0]alarm_time_ls_hr,
    output reg [3:0]alarm_time_ls_min
    );
    
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    alarm_time_ms_hr<=4'd0;
    alarm_time_ms_min<=4'd0;
    alarm_time_ls_hr<=4'd0;
    alarm_time_ls_min<=4'd0;
    end
    
    else if(load_new_a) begin
    alarm_time_ms_hr<=new_alarm_time_ms_hr;
    alarm_time_ms_min<=new_alarm_time_ms_min;
    alarm_time_ls_hr<=new_alarm_time_ls_hr;
    alarm_time_ls_min<=new_alarm_time_ls_min;
    end
    
    end
endmodule