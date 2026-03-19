$ErrorActionPreference = 'Stop'

Write-Host "=== Compile shared RTL and testbenches ==="
if (Test-Path work) {
    Remove-Item -Recurse -Force work
}
& vlog -sv `
    RTL/btn_pulse.v `
    RTL/hex_to_7seg.v `
    RTL/lfsr_delay.v `
    RTL/timer.v `
    RTL/update_highscore.v `
    RTL/pb_led_animation.v `
    reaction_game.v `
    tb/ram_highscore_model.v `
    tb/tb_btn_pulse_selfcheck.v `
    tb/tb_update_highscore_selfcheck.v `
    tb/tb_timer_selfcheck.v `
    tb/tb_reaction_game_smoke.v
if ($LASTEXITCODE -ne 0) {
    throw "Compile failed"
}

$tests = @(
    'tb_btn_pulse_selfcheck',
    'tb_update_highscore_selfcheck',
    'tb_timer_selfcheck',
    'tb_reaction_game_smoke'
)

foreach ($t in $tests) {
    Write-Host "=== Run $t ==="
    & vsim -c $t -do "run -all; quit -f"
    if ($LASTEXITCODE -ne 0) {
        throw "Test failed: $t"
    }
}

Write-Host "ALL REGRESSION TESTS PASSED"
exit 0
