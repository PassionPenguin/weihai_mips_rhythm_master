@echo off
REM validate_hex.bat - Validate assembled hex files (Windows)
REM Usage: validate_hex.bat <hex_file>

setlocal enabledelayedexpansion

set "HEX_FILE=%~1"

if "%HEX_FILE%"=="" (
    echo Usage: %~nx0 ^<hex_file^>
    exit /b 1
)

if not exist "%HEX_FILE%" (
    echo Error: File '%HEX_FILE%' not found
    exit /b 1
)

echo Validating: %HEX_FILE%
echo.

REM Check 1: File is not empty
for /f %%A in ('type "%HEX_FILE%" ^| find /c /v ""') do set LINE_COUNT=%%A
if %LINE_COUNT%==0 (
    echo [FAILED] File is empty
    exit /b 1
)
echo [OK] File contains %LINE_COUNT% instructions

REM Check 2: Count instruction types using findstr
for /f %%A in ('findstr /r "^2[0-9A-Fa-f]" "%HEX_FILE%" ^| find /c /v ""') do set ADDI_COUNT=%%A
for /f %%A in ('findstr /r "^8[CcDdEeFf]" "%HEX_FILE%" ^| find /c /v ""') do set LW_COUNT=%%A
for /f %%A in ('findstr /r "^A[CcDdEeFf]" "%HEX_FILE%" ^| find /c /v ""') do set SW_COUNT=%%A
for /f %%A in ('findstr /r "^1[0-5]" "%HEX_FILE%" ^| find /c /v ""') do set BRANCH_COUNT=%%A

echo.
echo Instruction statistics:
echo   ADDI-type:   %ADDI_COUNT%
echo   LW:          %LW_COUNT%
echo   SW:          %SW_COUNT%
echo   Branches:    %BRANCH_COUNT%

REM Calculate memory usage
set /a BYTES=%LINE_COUNT%*4
set /a KB=%BYTES%/1024
echo.
echo Memory usage: %BYTES% bytes (~%KB% KB)
echo.
echo [OK] Validation passed!

exit /b 0
