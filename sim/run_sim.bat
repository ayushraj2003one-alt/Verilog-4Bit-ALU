@echo off
REM ==============================================================================
REM Simulation Runner Script for Windows using Icarus Verilog and GTKWave
REM ==============================================================================

echo [1/3] Compiling Verilog RTL and Testbench using Icarus Verilog...
iverilog -o alu_sim.vvp ..\rtl\alu.v ..\tb\alu_tb.v
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed. Ensure iverilog is installed and added to PATH.
    pause
    exit /b %ERRORLEVEL%
)

echo [2/3] Running simulation with vvp...
vvp alu_sim.vvp
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Simulation execution failed.
    pause
    exit /b %ERRORLEVEL%
)

echo [3/3] Opening waveform in GTKWave...
where gtkwave >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    gtkwave dump.vcd
) else (
    echo [NOTE] GTKWave not found in PATH. You can view 'dump.vcd' in ModelSim or EDA Playground.
)

echo Simulation complete.
pause
