@echo off
REM assemble.bat - Windows batch script to assemble MIPS programs
REM Usage: assemble.bat <input.asm> [output.hex]

setlocal enabledelayedexpansion

REM Colors are limited in cmd, but we can use echo for formatting
set "INPUT_FILE=%~1"
set "OUTPUT_FILE=%~2"

if "%INPUT_FILE%"=="" (
    echo Usage: %~nx0 ^<input.asm^> [output.hex]
    echo.
    echo Examples:
    echo   %~nx0 programs\test_memory.asm
    echo   %~nx0 programs\test_marquee.asm programs\custom_output.hex
    exit /b 1
)

REM Set output file if not provided
if "%OUTPUT_FILE%"=="" (
    set "OUTPUT_FILE=%INPUT_FILE:.asm=.hex%"
)

REM Check if input file exists
if not exist "%INPUT_FILE%" (
    echo Error: Input file '%INPUT_FILE%' not found
    exit /b 1
)

echo Assembling: %INPUT_FILE%
echo Output: %OUTPUT_FILE%
echo.

REM Check if assembler exists
set "ASSEMBLER_DIR=%~dp0..\assembler"
set "ASSEMBLER_EXE=%ASSEMBLER_DIR%\target\release\weihai_mips_assembler.exe"

if not exist "%ASSEMBLER_EXE%" (
    set "ASSEMBLER_EXE=%ASSEMBLER_DIR%\target\debug\weihai_mips_assembler.exe"
)

if not exist "%ASSEMBLER_EXE%" (
    echo Building assembler...
    pushd "%ASSEMBLER_DIR%"
    cargo build --release
    popd
    set "ASSEMBLER_EXE=%ASSEMBLER_DIR%\target\release\weihai_mips_assembler.exe"
)

REM Run assembler
"%ASSEMBLER_EXE%" "%INPUT_FILE%" -o "%OUTPUT_FILE%"

if errorlevel 1 (
    echo [FAILED] Assembly failed!
    exit /b 1
)

echo [SUCCESS] Assembly successful!
echo.

REM Show first few instructions
echo First 5 instructions:
powershell -Command "Get-Content '%OUTPUT_FILE%' -TotalCount 5 | ForEach-Object -Begin { $i=0 } -Process { '{0:D4}: {1}' -f $i++,$_ }"

exit /b 0
