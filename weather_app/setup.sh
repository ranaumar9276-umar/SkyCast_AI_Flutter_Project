#!/bin/bash

echo ""
echo "========================================================"
echo "  SkyCast AI - Flutter Weather App Setup"
echo "  Mobile Application Development Assignment"
echo "========================================================"
echo ""

# Step 1 - Check Flutter
echo "[1/4] Checking Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Install from https://flutter.dev"
    exit 1
fi
flutter --version | head -1
echo "Flutter found ✓"
echo ""

# Step 2 - Create Flutter project scaffold
echo "[2/4] Creating Flutter project scaffold..."
flutter create . --org com.skycast 2>/dev/null || echo "Project exists, continuing..."
echo "Done ✓"
echo ""

# Step 3 - Install packages
echo "[3/4] Installing packages..."
flutter pub get
echo "Packages installed ✓"
echo ""

# Step 4 - Reminder
echo "[4/4] IMPORTANT — Add API Keys!"
echo ""
echo "  Edit: lib/utils/constants.dart"
echo "  Fill: openWeatherApiKey = 'YOUR_KEY'"
echo "        geminiApiKey      = 'YOUR_KEY'"
echo ""
echo "  Get keys:"
echo "    OpenWeatherMap → https://openweathermap.org/api"
echo "    Gemini AI      → https://aistudio.google.com/apikey"
echo ""
echo "========================================================"
echo "  Run the app: flutter run"
echo "========================================================"
