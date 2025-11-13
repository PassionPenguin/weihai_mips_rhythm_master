@echo off
REM synthesize.bat - Run Vivado synthesis for Basys3
REM Usage: synthesize.bat

setlocal

echo ========================================
echo   Vivado Synthesis for Basys3
echo ========================================
echo.

set "PROJECT_ROOT=%~dp0.."

REM Check if Vivado is available
where vivado >nul 2>&1
if errorlevel 1 (
    echo ERROR: Vivado not found in PATH
    echo.
    echo Please run from Vivado Command Prompt or add Vivado to PATH
    pause
    exit /b 1
)

echo Running synthesis and implementation...
echo This may take several minutes...
echo.

cd /d "%PROJECT_ROOT%"
vivado -mode batch -source scripts\vivado_synth.tcl

if errorlevel 1 (
    echo.
    echo [FAILED] Synthesis failed
    echo Check vivado_impl directory for error logs
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Synthesis completed!
echo.
echo Bitstream generated: vivado_impl\mips_cpu_basys3.bit
echo.
echo Next steps:
echo   1. Connect Basys3 board via USB
echo   2. Run: scripts\program_fpga.bat
echo.
pause
exit /b 0
