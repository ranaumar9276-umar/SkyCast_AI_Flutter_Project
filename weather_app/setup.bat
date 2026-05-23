@echo off
title SkyCast AI - Flutter Project Setup
color 0B

echo.
echo  ========================================================
echo     SkyCast AI - Weather App Setup Script
echo     Mobile Application Development Assignment
echo  ========================================================
echo.

:: Step 1 - Check Flutter
echo [1/5] Checking Flutter installation...
flutter --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo  ERROR: Flutter is not installed or not in PATH.
    echo  Download from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo  Flutter found! ✓
echo.

:: Step 2 - Create Flutter project
echo [2/5] Creating Flutter project...
flutter create weather_app --org com.skycast --platforms android 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo  Flutter project already exists or error occurred.
)
echo  Project structure created! ✓
echo.

:: Step 3 - Copy our source files into the project
echo [3/5] Copying source files...

:: Create directories
mkdir weather_app\lib\models 2>nul
mkdir weather_app\lib\services 2>nul
mkdir weather_app\lib\providers 2>nul
mkdir weather_app\lib\screens 2>nul
mkdir weather_app\lib\widgets 2>nul
mkdir weather_app\lib\utils 2>nul

:: Copy all files
xcopy /Y /S /Q "lib\*" "weather_app\lib\" >nul
copy /Y "pubspec.yaml" "weather_app\pubspec.yaml" >nul
copy /Y "README.md" "weather_app\README.md" >nul
copy /Y ".gitignore" "weather_app\.gitignore" >nul
copy /Y "android\app\src\main\AndroidManifest.xml" "weather_app\android\app\src\main\AndroidManifest.xml" >nul

echo  Files copied! ✓
echo.

:: Step 4 - Get packages
echo [4/5] Installing dependencies (flutter pub get)...
cd weather_app
flutter pub get
IF %ERRORLEVEL% NEQ 0 (
    echo  ERROR: Could not install packages. Check internet connection.
    pause
    exit /b 1
)
echo  Dependencies installed! ✓
echo.

:: Step 5 - Reminder for API keys
echo [5/5] IMPORTANT - Add your API Keys!
echo.
echo  Open this file:  lib\utils\constants.dart
echo.
echo  Replace these lines:
echo    openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY_HERE'
echo    geminiApiKey      = 'YOUR_GEMINI_API_KEY_HERE'
echo.
echo  Get free API keys from:
echo    OpenWeatherMap: https://openweathermap.org/api
echo    Google Gemini:  https://aistudio.google.com/apikey
echo.
echo  ========================================================
echo    Setup Complete! Run: flutter run
echo  ========================================================
echo.
pause
