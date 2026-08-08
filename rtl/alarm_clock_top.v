`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: alarm_clock_top
// Description: Top-level integration of the BCD digital alarm clock.
//
// Sub-blocks instantiated:
//   timegen              - generates one_second / one_minute tick pulses
//   alarm_controller_fsm - Moore FSM: keypad entry / display-mode / alarm sequencing
//   keyreg               - 4-digit shift buffer that captures keypad entry
//   counter              - BCD current-time register (HH:MM)
//   alarm_reg            - BCD alarm-time register (HH:MM)
//   lcd_driver_4         - converts BCD digits to display codes, drives sound_a
//
// Digit naming used throughout: ms_hr = tens-of-hour, ls_hr = units-of-hour,
//                                ms_min = tens-of-minute, ls_min = units-of-minute
//////////////////////////////////////////////////////////////////////////////////

module alarm_clock_top(
    input  clk,
    input  rst,
    input  time_button,      // hold to preview current time / confirm time-set
    input  alarm_button,     // hold to preview alarm time / confirm alarm-set
    input  [3:0] key,        // keypad input: 0-9 = digit, 10 = NOKEY (idle)
    input  fast_watch,       // 1 = accelerated tick rate (bring-up/test mode)

    output [7:0] display_ms_hr,
    output [7:0] display_ms_min,
    output [7:0] display_ls_hr,
    output [7:0] display_ls_min,
    output sound_a
    );

    // ---------------------------------------------------------------
    // Internal interconnect
    // ---------------------------------------------------------------
    wire one_second, one_minute;
    wire load_new_c, load_new_a, show_a, show_new_time, shift, rst_count;

    wire [3:0] current_time_ms_hr, current_time_ms_min, current_time_ls_hr, current_time_ls_min;
    wire [3:0] alarm_time_ms_hr,   alarm_time_ms_min,   alarm_time_ls_hr,   alarm_time_ls_min;
    wire [3:0] key_buffer_ms_hr,   key_buffer_ms_min,   key_buffer_ls_hr,   key_buffer_ls_min;

    // ---------------------------------------------------------------
    // Tick generator
    // ---------------------------------------------------------------
    timegen u_timegen (
        .clk        (clk),
        .rst        (rst),
        .rst_count  (rst_count),
        .fast_watch (fast_watch),
        .one_second (one_second),
        .one_minute (one_minute)
    );

    // ---------------------------------------------------------------
    // Control FSM (keypad / mode sequencing)
    // ---------------------------------------------------------------
    alarm_controller_fsm u_fsm (
        .clk          (clk),
        .rst          (rst),
        .one_second   (one_second),
        .time_button  (time_button),
        .alarm_button (alarm_button),
        .key          (key),
        .load_new_c   (load_new_c),
        .load_new_a   (load_new_a),
        .show_a       (show_a),
        .show_new_time(show_new_time),
        .shift        (shift),
        .rst_count    (rst_count)
    );

    // ---------------------------------------------------------------
    // Keypad entry buffer
    // ---------------------------------------------------------------
    keyreg u_keyreg (
        .clk  (clk),
        .rst  (rst),
        .shift(shift),
        .key  (key),
        .key_buffer_ms_hr (key_buffer_ms_hr),
        .key_buffer_ms_min(key_buffer_ms_min),
        .key_buffer_ls_hr (key_buffer_ls_hr),
        .key_buffer_ls_min(key_buffer_ls_min)
    );

    // ---------------------------------------------------------------
    // Current time (BCD HH:MM), loaded from the key buffer on load_new_c
    // ---------------------------------------------------------------
    counter u_counter (
        .clk  (clk),
        .rst  (rst),
        .one_minute (one_minute),
        .load_new_c (load_new_c),
        .new_current_time_ms_hr (key_buffer_ms_hr),
        .new_current_time_ms_min(key_buffer_ms_min),
        .new_current_time_ls_hr (key_buffer_ls_hr),
        .new_current_time_ls_min(key_buffer_ls_min),
        .current_time_ms_hr (current_time_ms_hr),
        .current_time_ms_min(current_time_ms_min),
        .current_time_ls_hr (current_time_ls_hr),
        .current_time_ls_min(current_time_ls_min)
    );

    // ---------------------------------------------------------------
    // Alarm time (BCD HH:MM), loaded from the key buffer on load_new_a
    // ---------------------------------------------------------------
    alarm_reg u_alarm_reg (
        .clk  (clk),
        .rst  (rst),
        .load_new_a (load_new_a),
        .new_alarm_time_ms_hr (key_buffer_ms_hr),
        .new_alarm_time_ms_min(key_buffer_ms_min),
        .new_alarm_time_ls_hr (key_buffer_ls_hr),
        .new_alarm_time_ls_min(key_buffer_ls_min),
        .alarm_time_ms_hr (alarm_time_ms_hr),
        .alarm_time_ms_min(alarm_time_ms_min),
        .alarm_time_ls_hr (alarm_time_ls_hr),
        .alarm_time_ls_min(alarm_time_ls_min)
    );

    // ---------------------------------------------------------------
    // Display + alarm-match compare
    // NOTE: lcd_driver_4's port is named "show_current_time" but it is
    // wired here to the FSM's "show_new_time". Despite the name, that
    // port actually selects "show the key-entry buffer" inside
    // lcd_driver (show_new_time=1 => display_value=key). This is the
    // correct connection for the display to preview digits as they're
    // typed - see the accompanying write-up for the full explanation.
    // ---------------------------------------------------------------
    lcd_driver_4 u_lcd_driver_4 (
        .alarm_time_ms_hr  (alarm_time_ms_hr),
        .alarm_time_ms_min (alarm_time_ms_min),
        .alarm_time_ls_hr  (alarm_time_ls_hr),
        .alarm_time_ls_min (alarm_time_ls_min),
        .current_time_ms_hr (current_time_ms_hr),
        .current_time_ms_min(current_time_ms_min),
        .current_time_ls_hr (current_time_ls_hr),
        .current_time_ls_min(current_time_ls_min),
        .key_time_ms_hr  (key_buffer_ms_hr),
        .key_time_ms_min (key_buffer_ms_min),
        .key_time_ls_hr  (key_buffer_ls_hr),
        .key_time_ls_min (key_buffer_ls_min),
        .show_a            (show_a),
        .show_current_time (show_new_time),
        .display_ms_hr  (display_ms_hr),
        .display_ms_min (display_ms_min),
        .display_ls_hr  (display_ls_hr),
        .display_ls_min (display_ls_min),
        .sound_a (sound_a)
    );

endmodule