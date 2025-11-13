@echo off
REM assemble_all.bat - Assemble all test programs (Windows)
REM Usage: assemble_all.bat

setlocal enabledelayedexpansion

echo ========================================
echo   Assembling All Test Programs
echo ========================================
echo.

set "PROGRAMS_DIR=%~dp0..\programs"
set "SUCCESS_COUNT=0"
set "FAIL_COUNT=0"
set "TOTAL_COUNT=0"

for %%F in ("%PROGRAMS_DIR%\*.asm") do (
    set /a TOTAL_COUNT+=1
    echo [!TOTAL_COUNT!] Assembling: %%~nxF
    
    call "%~dp0assemble.bat" "%%F" "%%~dpnF.hex" >nul 2>&1
    
    if errorlevel 1 (
        echo   [FAILED]
        set /a FAIL_COUNT+=1
    ) else (
        echo   [SUCCESS]
        set /a SUCCESS_COUNT+=1
    )
    echo.
)

echo ========================================
echo Summary: !SUCCESS_COUNT! passed, !FAIL_COUNT! failed (out of !TOTAL_COUNT!)
echo ========================================

if !FAIL_COUNT! gtr 0 (
    exit /b 1
)

exit /b 0
