@echo off
REM run_simulation.bat - Run Vivado simulation on Windows
REM Usage: run_simulation.bat <test_name>

setlocal

set "TEST_NAME=%~1"
if "%TEST_NAME%"=="" set "TEST_NAME=test_memory"

echo ========================================
echo   Running Simulation: %TEST_NAME%
echo   Target: Basys3 (Vivado)
echo ========================================
echo.

set "PROJECT_ROOT=%~dp0.."
set "HEX_FILE=%PROJECT_ROOT%\programs\%TEST_NAME%.hex"

REM Check if hex file exists
if not exist "%HEX_FILE%" (
    echo Hex file not found, attempting to assemble...
    set "ASM_FILE=%PROJECT_ROOT%\programs\%TEST_NAME%.asm"
    
    if not exist "!ASM_FILE!" (
        echo Error: Neither .hex nor .asm file found for '%TEST_NAME%'
        exit /b 1
    )
    
    call "%~dp0assemble.bat" "!ASM_FILE!"
)

REM Copy hex file to expected location
copy /Y "%HEX_FILE%" "%PROJECT_ROOT%\programs\simple_program.hex" >nul
echo Using program: %HEX_FILE%
echo.

REM Check if Vivado is in PATH
where vivado >nul 2>&1
if errorlevel 1 (
    echo Vivado not found in PATH
    echo.
    echo Please ensure Vivado is installed and:
    echo   1. Run from Vivado Command Prompt, or
    echo   2. Add Vivado to PATH, or
    echo   3. Open Vivado GUI and run scripts\vivado_sim.tcl
    echo.
    echo The program file is ready at: programs\simple_program.hex
    pause
    exit /b 1
)

echo Running Vivado simulation...
cd /d "%PROJECT_ROOT%"
vivado -mode batch -source scripts\vivado_sim.tcl -tclargs "%TEST_NAME%"

if errorlevel 1 (
    echo [FAILED] Simulation failed
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Simulation completed
echo Check vivado_sim\ directory for results
pause
exit /b 0
