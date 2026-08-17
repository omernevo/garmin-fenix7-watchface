@echo off
setlocal

set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "PATH=C:\Program Files\Java\jdk-26.0.2\bin;%PATH%"
set "SDK_BIN=%APPDATA%\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin"

echo ===================================================
echo [1/3] Building Garmin Fenix 7 WatchFace...
echo ===================================================
call "%SDK_BIN%\monkeyc.bat" -o bin\Fenix7WatchFace.prg -f monkey.jungle -y developer_key.der -d fenix7 -w
if %ERRORLEVEL% NEQ 0 (
    echo Build failed with error code %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ===================================================
echo [2/3] Starting Garmin Connect IQ Simulator...
echo ===================================================
start "" "%SDK_BIN%\simulator.exe"
timeout /t 3 /nobreak >nul

echo.
echo ===================================================
echo [3/3] Loading WatchFace onto Fenix 7...
echo ===================================================
call "%SDK_BIN%\monkeydo.bat" bin\Fenix7WatchFace.prg fenix7

echo.
echo WatchFace is running in Garmin Simulator!
