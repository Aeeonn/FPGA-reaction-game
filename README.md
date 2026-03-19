# FPGA-reaction-game
A reaction game I created on my DE10-lite FPGA featuring LFSR, button debouncing, RAM as memory, and more. 

## Simulation tests (Questa)

This project includes self-checking testbenches and a one-command regression runner.

### Run all tests (recommended)

From the project root:

```powershell
powershell -ExecutionPolicy Bypass -File tb/run_all_tests.ps1
```

Expected final line:

```text
ALL REGRESSION TESTS PASSED
```

### Run individual tests

```powershell
vsim -c tb_btn_pulse_selfcheck -do "run -all; quit -f"
vsim -c tb_update_highscore_selfcheck -do "run -all; quit -f"
vsim -c tb_timer_selfcheck -do "run -all; quit -f"
vsim -c tb_reaction_game_smoke -do "run -all; quit -f"
```

Expected pass markers:

```text
ALL BTN_PULSE TESTS PASSED
ALL UPDATE_HIGHSCORE TESTS PASSED
ALL TIMER TESTS PASSED
TOP-LEVEL SMOKE TEST PASSED
```

### Testbench files

- tb/tb_btn_pulse_selfcheck.v
- tb/tb_update_highscore_selfcheck.v
- tb/tb_timer_selfcheck.v
- tb/tb_reaction_game_smoke.v
- tb/highscore_model.v

