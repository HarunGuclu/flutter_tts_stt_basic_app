@echo off
REM Text Speech App - Automatic Starter
REM This script automatically starts the Flutter Text Speech App on Edge

echo.
echo ==========================================
echo   Text Speech App - Edge Browser Launch
echo ==========================================
echo.

REM Navigate to project directory
cd /D "%~dp0"

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Clean previous builds (optional)
echo Cleaning previous builds...
flutter clean >nul 2>&1

REM Get dependencies
echo Getting dependencies...
flutter pub get >nul 2>&1

REM Generate localization files
echo Generating localization files...
flutter gen-l10n >nul 2>&1

REM Run the app on Edge
echo.
echo Starting Flutter app on Edge...
echo.
flutter run -d edge

REM If flutter run exits, pause to show any error messages
pause
