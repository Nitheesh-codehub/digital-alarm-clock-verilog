`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2026 07:43:23 AM
// Design Name: 
// Module Name: lcd_driver
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


module lcd_driver(
    input [3:0]key,
    input [3:0]alarm_time,
    input [3:0]current_time,
    input show_a,
    input show_new_time,
    output reg sound_alarm,
    output reg [7:0]display_time
    );
    
    reg [3:0]display_value;
    
    //parameter constants to represent LCD Numbers
    parameter ZERO=8'h30;
    parameter ONE=8'h31;
    parameter TWO=8'h32;
    parameter THREE=8'h33;
    parameter FOUR=8'h34;
    parameter FIVE=8'h35;
    parameter SIX=8'h36;
    parameter SEVEN=8'h37;
    parameter EIGHT=8'h38;
    parameter NINE=8'h39;
    parameter ERROR=8'h3A;
    
    always@(alarm_time or current_time or show_a or show_new_time or key) begin
    if(show_new_time)
        display_value=key;
    else if(show_a)
        display_value=alarm_time;
    else
        display_value=current_time;
        
    //sound_alarm logic
    if(current_time == alarm_time)
        sound_alarm=1'b1;
    else
        sound_alarm=1'b0;
    end
    
    always@(display_value) begin
    case(display_value)
        4'd0:display_time=ZERO;
        4'd1:display_time=ONE;
        4'd2:display_time=TWO;
        4'd3:display_time=THREE;
        4'd4:display_time=FOUR;
        4'd5:display_time=FIVE;
        4'd6:display_time=SIX;
        4'd7:display_time=SEVEN;
        4'd8:display_time=EIGHT;
        4'd9:display_time=NINE;
        default:display_time=ERROR;
    endcase
    end
endmodule