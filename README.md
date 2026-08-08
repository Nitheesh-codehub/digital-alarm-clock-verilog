# BCD Digital Alarm Clock — Verilog RTL + Self-Checking Testbench

A keypad-driven digital alarm clock built in plain Verilog, verified with a self-checking,
real-interface-driven testbench (no backdoor `force`, no SV/UVM). Written as part of a 30-day
verification challenge — full write-up series linked below.

## What this is

A BCD-based alarm clock with a real Moore FSM controlling keypad entry, time/alarm setting, and
display preview:

```
timegen → alarm_controller_fsm → keyreg → counter / alarm_reg → lcd_driver_4
```

- **timegen** — generates `one_second` / `one_minute` ticks, with a `fast_watch` mode for fast
  simulation instead of waiting real seconds
- **alarm_controller_fsm** — 7-state Moore FSM: `SHOW_TIME`, `SHOW_ALARM`, `KEY_STORED`,
  `KEY_WAITED`, `KEY_ENTRY`, `SET_ALARM_TIME`, `SET_CURRENT_TIME`
- **keyreg** — 4-digit shift register that buffers keypad entries (hour-tens, hour-units,
  minute-tens, minute-units)
- **counter** — current time, stored as 4 BCD digits with explicit carry/rollover logic
- **alarm_reg** — alarm time, stored the same way
- **lcd_driver_4** — drives the display (ASCII digit output) and compares current time vs. alarm
  time to assert `sound_a`

## Repo structure

```
alarm_clock_top.v          top-level module, wires everything together
alarm_controller_fsm.v     the 7-state Moore FSM
timegen.v                  tick generation (one_second / one_minute)
keyreg.v                   4-digit keypad entry shift register
counter.v                  current-time BCD register with rollover logic
alarm_reg.v                alarm-time BCD register
lcd_driver.v               single-digit display + compare
lcd_driver_4.v             4-digit display driver, instantiates lcd_driver x4
tb_alarm_clock_top.v       self-checking testbench
```

## How to simulate

**Icarus Verilog (free, cross-platform):**
```bash
iverilog -o sim alarm_clock_top.v alarm_controller_fsm.v timegen.v keyreg.v counter.v alarm_reg.v lcd_driver.v lcd_driver_4.v tb_alarm_clock_top.v
vvp sim
```

**EDA Playground:** put `tb_alarm_clock_top.v` in `testbench.v` and the rest of the `.v` files as
additional design files, select Icarus Verilog as the simulator, and run.

**Vivado:** add all `.v` files as Design Sources, add `tb_alarm_clock_top.v` as a Simulation
Source, and run Behavioral Simulation.

## Verification approach

The testbench drives the DUT only through its real interface — `key[3:0]`, `time_button`,
`alarm_button` — the same signals a physical keypad would toggle. No internal register is ever
written directly with `force`.

```verilog
task press_key(input [3:0] d);
begin
    @(negedge clk); key = d;
    repeat (2) @(negedge clk);
    key = NOKEY;
    repeat (2) @(negedge clk);
end
endtask
```

Every check runs through a self-checking task that prints PASS/FAIL and accumulates an error
count — no manual waveform review required:

```verilog
task check(input cond, input [8*100-1:0] msg);
begin
    if (cond) $display("  PASS: %0s", msg);
    else begin
        $display("  FAIL: %0s", msg);
        errors = errors + 1;
    end
end
endtask
```

Checks cover two independent views of the same state — the raw BCD registers **and** the
display's ASCII output — since the two are driven by separate logic and a register-only check
can miss a display wiring bug.

### What's covered

| Feature | Check |
|---|---|
| Reset | All BCD registers = 0 |
| Keypad entry | Digits shift into correct HH:MM positions |
| Time/alarm set | FSM loads registers on button press |
| BCD rollover | Minute, hour-units, hour-tens, midnight wrap |
| Alarm match | `sound_a` asserts when current time == alarm time |
| Live preview | Display shows the key buffer while typing, not stale data |

Current status: **8/8 directed checks passing**, `errors[31:0] = 00000000` across the full
regression.

## Things found during verification

- **Display wiring bug (fixed):** `lcd_driver_4`'s preview port wasn't connected to the FSM's
  `show_new_time` signal, so the live preview never updated while typing. Caught by the display
  check, not the register check — traced and fixed.
- **Dead code:** `alarm_controller_fsm`'s `count1` register is never incremented anywhere in the
  code. Only `count2` actually drives the 10-second keypad timeout. Found via code review, not
  simulation — doesn't currently break anything, but it's unused logic.
- **Spec gap, not a bug:** there's no `alarm_en` / disable input anywhere in `lcd_driver`. Once
  `current_time == alarm_time`, `sound_a` asserts, and it will re-trigger every day at that exact
  time with no way to silence it long-term. The RTL does what it was told — the requirement to
  disable it was just never specified.

## Series write-up

This project was built and verified as a 30-day daily series on LinkedIn — day-by-day breakdown
of the FSM, the real-interface testbench, the self-checking approach, the bug found, BCD
rollover corner cases, and the full regression: **[link to your LinkedIn series]**

## What's next

Carrying this same DUT into SystemVerilog/UVM — a proper reference-model scoreboard and
functional coverage on top of what's already here, to compare directed-Verilog vs.
constrained-random UVM approaches on the identical design.

## License

MIT — see [LICENSE](LICENSE).
# digital-alarm-clock-verilog
