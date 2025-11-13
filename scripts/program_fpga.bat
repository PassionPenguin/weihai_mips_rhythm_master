@echo off
REM program_fpga.bat - Program Basys3 board with bitstream
REM Usage: program_fpga.bat

setlocal

echo ========================================
echo   Programming Basys3 Board
echo ========================================
echo.

set "PROJECT_ROOT=%~dp0.."
set "BITSTREAM=%PROJECT_ROOT%\vivado_impl\mips_cpu_basys3.bit"

REM Check if bitstream exists
if not exist "%BITSTREAM%" (
    echo ERROR: Bitstream not found: %BITSTREAM%
    echo.
    echo Please run synthesis first: scripts\synthesize.bat
    pause
    exit /b 1
)

REM Check if Vivado is available
where vivado >nul 2>&1
if errorlevel 1 (
    echo ERROR: Vivado not found in PATH
    echo.
    echo Please run from Vivado Command Prompt
    pause
    exit /b 1
)

echo Bitstream: %BITSTREAM%
echo.
echo Make sure:
echo   1. Basys3 board is connected via USB
echo   2. Board is powered on
echo   3. Digilent drivers are installed
echo.
pause

cd /d "%PROJECT_ROOT%"
vivado -mode batch -source scripts\vivado_program.tcl

if errorlevel 1 (
    echo.
    echo [FAILED] Programming failed
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Board programmed successfully!
echo.
echo Your CPU should now be running on the Basys3
echo.
pause
exit /b 0
