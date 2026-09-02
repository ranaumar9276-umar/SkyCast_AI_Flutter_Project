# ☁️ SkyCast AI — Flutter Weather App

> **Mobile Application Development — Final Assignment**  
> A professional, AI-powered weather application built with Flutter & Dart

---

## 📱 App Screenshots

| Splash Screen | Home Screen | AI Chat |
|:---:|:---:|:---:|
| Animated intro | Real-time weather | Gemini AI advice |

---

## 🌟 Features

### Weather Features
- 📍 **Auto-detect location** via GPS (Geolocator)
- 🔍 **City search** with recent search history
- 🌡️ **Current weather** — temperature, feels like, min/max
- 💧 Humidity, 💨 Wind speed & direction, 👁️ Visibility, 🔵 Pressure
- ⏰ **Hourly forecast** — next 24 hours (8 slots × 3h)
- 📅 **7-day forecast** — daily high/low + rain probability
- 🌅 Sunrise & Sunset times
- 🔄 Pull-to-refresh live updates
- °C / °F unit toggle (saved in preferences)

### AI Assistant (Gemini)
- 🤖 **Gemini 1.5 Flash** AI integration
- 💬 Full chat conversation with weather context
- ⚡ Quick-action buttons (umbrella? outdoor exercise? what to wear?)
- 📊 AI generates advice based on **real-time** weather data

### UI / UX
- 🎨 **Dynamic gradient backgrounds** — changes with weather & time of day
- 🌧️ **Weather particle animations** — rain, snow, stars, sun rays, fog
- 💎 **Glassmorphism** cards with blur effect
- ✨ **Flutter Animate** micro-animations throughout
- 🩼 **Shimmer** loading skeleton
- 📱 Full edge-to-edge immersive layout
- 🔤 **Google Fonts** (Poppins) for clean typography

---

## 🗂️ Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   ├── weather_model.dart           # Current weather data model
│   └── forecast_model.dart         # Forecast data model
├── services/
│   ├── weather_service.dart        # OpenWeatherMap API calls
│   └── gemini_service.dart         # Google Gemini AI integration
├── providers/
│   └── weather_provider.dart       # State management (Provider)
├── screens/
│   ├── splash_screen.dart          # Animated splash / loading
│   ├── home_screen.dart            # Main weather dashboard
│   ├── search_screen.dart          # City search screen
│   └── ai_chat_screen.dart        # AI assistant chat
├── widgets/
│   ├── animated_background.dart   # Dynamic weather background
│   ├── glass_card.dart            # Glassmorphism card
│   ├── hourly_forecast_widget.dart # Horizontal hourly scroll
│   └── daily_forecast_widget.dart # 7-day forecast list
└── utils/
    ├── constants.dart              # API keys & app constants
    └── weather_utils.dart         # Helper functions
```

---

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK `>=3.2.0`
- Dart SDK `>=3.2.0`
- Android Studio / VS Code with Flutter extension

### Step 1 — Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/weather_app.git
cd weather_app
```

### Step 2 — Install Dependencies
```bash
flutter pub get
```

### Step 3 — Add API Keys

Open `lib/utils/constants.dart` and replace the placeholder values:

```dart
static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY_HERE';
static const String geminiApiKey      = 'YOUR_GEMINI_API_KEY_HERE';
```

**Get API Keys:**
| API | Link |
|-----|------|
| OpenWeatherMap | https://openweathermap.org/api → Sign up → Free plan |
| Google Gemini | https://aistudio.google.com/apikey → Get API Key |

### Step 4 — Run the App
```bash
flutter run
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `http` | ^1.1.0 | REST API calls |
| `geolocator` | ^10.1.0 | GPS location |
| `geocoding` | ^2.1.1 | Reverse geocoding |
| `google_generative_ai` | ^0.4.3 | Gemini AI |
| `flutter_animate` | ^4.5.0 | Micro-animations |
| `shimmer` | ^3.0.0 | Loading skeleton |
| `google_fonts` | ^6.1.0 | Poppins typography |
| `shared_preferences` | ^2.2.2 | Local storage |
| `intl` | ^0.18.1 | Date formatting |

---

## 🏗️ Architecture

```
UI Layer  →  Provider (State)  →  Services  →  APIs
Screens       WeatherProvider     WeatherService   OpenWeatherMap
Widgets       (ChangeNotifier)    GeminiService    Google Gemini
```

**Pattern:** MVVM-like with Provider for reactive state management.

---

## 🔒 Permissions Required

| Permission | Reason |
|------------|--------|
| `INTERNET` | Fetch weather & AI data |
| `ACCESS_FINE_LOCATION` | Precise GPS location |
| `ACCESS_COARSE_LOCATION` | Fallback location |

---

## 👨‍💻 Developer

- **Course:** Mobile Application Development
- **Framework:** Flutter (Dart)
- **APIs:** OpenWeatherMap REST API · Google Gemini AI
- **IDE:** Visual Studio Code

---

## 📄 License

This project is submitted as an academic assignment.  
© 2025 — All rights reserved.
