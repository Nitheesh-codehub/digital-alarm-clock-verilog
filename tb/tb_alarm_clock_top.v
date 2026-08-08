`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_alarm_clock_top
// Drives the DUT purely through its primary inputs (key/time_button/alarm_button)
// to exercise the real keypad-entry FSM path, then checks results against the
// internal BCD registers and the display output codes.
//////////////////////////////////////////////////////////////////////////////////
module tb_alarm_clock_top;

    reg clk, rst;
    reg time_button, alarm_button;
    reg [3:0] key;
    reg fast_watch;

    wire [7:0] display_ms_hr, display_ms_min, display_ls_hr, display_ls_min;
    wire sound_a;

    integer errors = 0;

    localparam NOKEY = 4'd10;

    alarm_clock_top dut (
        .clk(clk), .rst(rst),
        .time_button(time_button), .alarm_button(alarm_button),
        .key(key), .fast_watch(fast_watch),
        .display_ms_hr(display_ms_hr), .display_ms_min(display_ms_min),
        .display_ls_hr(display_ls_hr), .display_ls_min(display_ls_min),
        .sound_a(sound_a)
    );

    // 10ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    // Press one BCD digit (0-9) on the keypad and let the FSM shift it in.
    // Held for 2 cycles so it is stable at both the KEY_STORED-entry edge
    // and the edge where keyreg actually captures it; released for 2 cycles
    // so KEY_WAITED sees NOKEY and returns to KEY_ENTRY.
    task press_key(input [3:0] d);
    begin
        @(negedge clk); key = d;
        repeat (2) @(negedge clk);
        key = NOKEY;
        repeat (2) @(negedge clk);
    end
    endtask

    // Enter 4 digits (hour tens, hour units, minute tens, minute units)
    task enter_digits(input [3:0] d1, input [3:0] d2, input [3:0] d3, input [3:0] d4);
    begin
        press_key(d1);
        press_key(d2);
        press_key(d3);
        press_key(d4);
    end
    endtask

    task check(input cond, input [8*100-1:0] msg);
    begin
        if (cond) $display("  PASS: %0s", msg);
        else begin
            $display("  FAIL: %0s", msg);
            errors = errors + 1;
        end
    end
    endtask

    task show_digits(input [8*24-1:0] label);
    begin
        $display("  %0s -> %c%c:%c%c  (sound_a=%b show_a=%b)",
                  label, display_ms_hr[7:0], display_ls_hr[7:0],
                  display_ms_min[7:0], display_ls_min[7:0], sound_a,
                  dut.show_a);
    end
    endtask

    initial begin
        $display("=========================================================");
        $display(" alarm_clock_top functional smoke test");
        $display("=========================================================");

        // ---- Reset ----
        rst = 1; time_button = 0; alarm_button = 0; key = NOKEY; fast_watch = 1;
        repeat (3) @(negedge clk);
        rst = 0;
        repeat (2) @(negedge clk);

        check(dut.current_time_ms_hr==0 && dut.current_time_ls_hr==0 &&
              dut.current_time_ms_min==0 && dut.current_time_ls_min==0,
              "current time is 00:00 after reset");
        show_digits("after reset       ");

        // ---- Set current time to 11:58 ----
        $display("");
        $display("-- Setting current time to 11:58 via keypad --");
        press_key(4'd1);
        press_key(4'd1);
        // keyreg is a right-justified shift register (like a calculator/PIN
        // pad): each new digit enters at ls_min and existing digits shift
        // left. After 2 of 4 digits, they sit in the minutes field.
        show_digits("mid-entry (typed 11)");
        check(display_ms_hr==8'h30 && display_ls_hr==8'h30 &&
              display_ms_min==8'h31 && display_ls_min==8'h31,
              "live preview shows '11' in rightmost digits (validates lcd_driver_4 key_time_* fix)");
        press_key(4'd5);
        press_key(4'd8);
        time_button = 1;
        repeat (2) @(negedge clk);
        time_button = 0;
        repeat (2) @(negedge clk);

        check(dut.current_time_ms_hr==1 && dut.current_time_ls_hr==1 &&
              dut.current_time_ms_min==5 && dut.current_time_ls_min==8,
              "current_time registers hold 11:58");
        show_digits("current time now  ");
        check(display_ms_hr==8'h31 && display_ls_hr==8'h31 &&
              display_ms_min==8'h35 && display_ls_min==8'h38,
              "display shows ASCII '11:58' (validates lcd_driver display_value fix)");

        // ---- Set alarm time to 11:59 ----
        $display("");
        $display("-- Setting alarm time to 11:59 via keypad --");
        enter_digits(4'd1, 4'd1, 4'd5, 4'd9);
        alarm_button = 1;
        repeat (2) @(negedge clk);
        alarm_button = 0;
        repeat (2) @(negedge clk);

        check(dut.alarm_time_ms_hr==1 && dut.alarm_time_ls_hr==1 &&
              dut.alarm_time_ms_min==5 && dut.alarm_time_ls_min==9,
              "alarm_time registers hold 11:59");

        // ---- Preview the stored alarm on the display (hold alarm_button) ----
        alarm_button = 1;
        repeat (2) @(negedge clk);
        show_digits("alarm preview     ");
        check(display_ms_hr==8'h31 && display_ls_hr==8'h31 &&
              display_ms_min==8'h35 && display_ls_min==8'h39,
              "alarm preview shows ASCII '11:59'");
        alarm_button = 0;
        repeat (2) @(negedge clk);

        check(sound_a==0, "sound_a is still low before the times match");

        // ---- Let the clock run (fast_watch=1) until 11:58 rolls to 11:59 ----
        $display("");
        $display("-- Running clock forward one minute (fast_watch=1) --");
        @(posedge dut.one_minute);
        repeat (2) @(negedge clk);

        check(dut.current_time_ms_hr==1 && dut.current_time_ls_hr==1 &&
              dut.current_time_ms_min==5 && dut.current_time_ls_min==9,
              "current_time advanced to 11:59");
        show_digits("current time now  ");
        check(sound_a==1, "sound_a asserts once current_time == alarm_time");

        $display("");
        $display("=========================================================");
        if (errors==0)
            $display(" RESULT: ALL CHECKS PASSED");
        else
            $display(" RESULT: %0d CHECK(S) FAILED", errors);
        $display("=========================================================");
        $finish;
    end

    // Safety timeout
    initial begin
        #2_000_000;
        $display("FAIL: testbench timed out");
        $finish;
    end

endmodule