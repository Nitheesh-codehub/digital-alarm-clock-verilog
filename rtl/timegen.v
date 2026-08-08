`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 12:15:26 PM
// Design Name: 
// Module Name: timegen
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


module timegen(
    input clk,
    input rst,
    input rst_count,
    input fast_watch,
    output reg one_second,
    output reg one_minute
    );
    
    reg [13:0]count;
    reg one_minute_reg;
    
    //one minute pulse generation
    always@(posedge clk or posedge rst) begin
    if(rst)
    begin
    count<=14'b0;
    one_minute_reg<=0;
    end
    
    else if(rst_count)
    begin
    count<=14'b0;
    one_minute_reg<=1'b0;
    end
    
    else if(count[13:0] == 14'd15359)
    begin
    count<=14'b0;
    one_minute_reg<=1'b1;
    end
    
    else begin
    count<=count+1'b1;
    one_minute_reg<=1'b0;
    end
    end
    
    //one second pulse generation
    always@(posedge clk or posedge rst) begin
    if(rst)
    begin
        one_second<=1'b0;
    end
    else if(rst_count)
    begin
        one_second<=1'b0;
    end
    else if(count[7:0]==8'd255)
    begin
        one_second<=1'b1;
    end
    else 
    begin
        one_second<=1'b0;
    end
    end
    
    //fastwatch mode logic that makes the counting faster
    always@(*)
    begin
    if(fast_watch)
        one_minute=one_second;
    else 
        one_minute=one_minute_reg;
    end
    
    
endmodule