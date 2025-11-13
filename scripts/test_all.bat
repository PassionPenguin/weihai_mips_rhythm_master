@echo off
REM test_all.bat - Master test script for Windows
REM Usage: test_all.bat

setlocal

echo ╔════════════════════════════════════════╗
echo ║  MIPS CPU Test Suite                  ║
echo ╚════════════════════════════════════════╝
echo.

REM Step 1: Assemble all programs
echo [1/3] Assembling all programs...
call "%~dp0assemble_all.bat"

if errorlevel 1 (
    echo Assembly failed. Stopping tests.
    pause
    exit /b 1
)

echo.

REM Step 2: Validate all hex files
echo [2/3] Validating assembled programs...
for %%F in ("%~dp0..\programs\*.hex") do (
    echo Validating: %%~nxF
    call "%~dp0validate_hex.bat" "%%F"
    echo.
)

echo.

REM Step 3: Prepare for Vivado simulation
echo [3/3] Preparing Vivado simulation files...
echo.

where vivado >nul 2>&1
if errorlevel 1 (
    echo Vivado not found in PATH
    echo To run simulations:
    echo   1. Open Vivado Command Prompt
    echo   2. Run this script again, or
    echo   3. Use run_simulation.bat ^<test_name^>
) else (
    echo Vivado found - ready for simulation
    echo Run individual tests with: scripts\run_simulation.bat ^<test_name^>
    echo.
    echo Available tests:
    for %%F in ("%~dp0..\programs\test_*.hex") do (
        echo   - %%~nF
    )
)

echo.
echo ╔════════════════════════════════════════╗
echo ║  Test Suite Complete                   ║
echo ╚════════════════════════════════════════╝
pause
