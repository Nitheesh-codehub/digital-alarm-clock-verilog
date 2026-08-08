`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2026 07:58:53 AM
// Design Name: 
// Module Name: lcd_driver_4
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


module lcd_driver_4(
    input [3:0]alarm_time_ms_hr,
    input [3:0]alarm_time_ms_min,
    input [3:0]alarm_time_ls_hr,
    input [3:0]alarm_time_ls_min,
    input [3:0]current_time_ms_hr,
    input [3:0]current_time_ms_min,
    input [3:0]current_time_ls_hr,
    input [3:0]current_time_ls_min,
    input [3:0]key_time_ms_hr,
    input [3:0]key_time_ms_min,
    input [3:0]key_time_ls_hr,
    input [3:0]key_time_ls_min,
    input show_a,
    input show_current_time,
    output [7:0]display_ms_hr,
    output [7:0]display_ms_min,
    output [7:0]display_ls_hr,
    output [7:0]display_ls_min,
    output sound_a
    );
    
    wire sound_alarm1,sound_alarm2,sound_alarm3,sound_alarm4;
    
    assign sound_a=sound_alarm1&sound_alarm2&sound_alarm3&sound_alarm4;
    
    //instantiate lcd_driver as MS_HR_DISPLAY
    lcd_driver MS_HR(.alarm_time(alarm_time_ms_hr),
                     .current_time(current_time_ms_hr),
                     .key(key_time_ms_hr),
                     .show_a(show_a),
                     .show_new_time(show_current_time),
                     .display_time(display_ms_hr),
                     .sound_alarm(sound_alarm1));
                     
    //instantiate lcd_driver as LS_HR_DISPLAY
    lcd_driver LS_HR(.alarm_time(alarm_time_ls_hr),
                     .current_time(current_time_ls_hr),
                     .key(key_time_ls_hr),
                     .show_a(show_a),
                     .show_new_time(show_current_time),
                     .display_time(display_ls_hr),
                     .sound_alarm(sound_alarm2));
                     
    //instantiate lcd_driver as MS_MIN_DISPLAY
    lcd_driver MS_MIN(.alarm_time(alarm_time_ms_min),
                     .current_time(current_time_ms_min),
                     .key(key_time_ms_min),
                     .show_a(show_a),
                     .show_new_time(show_current_time),
                     .display_time(display_ms_min),
                     .sound_alarm(sound_alarm3));
                     
    //instantiate lcd_driver as LS_MIN_DISPLAY
    lcd_driver LS_MIN(.alarm_time(alarm_time_ls_min),
                     .current_time(current_time_ls_min),
                     .key(key_time_ls_min),
                     .show_a(show_a),
                     .show_new_time(show_current_time),
                     .display_time(display_ls_min),
                     .sound_alarm(sound_alarm4));
endmodule