import 'package:flutter/material.dart';

class AppConstants {
  // ══════════════════════════════════════════════
  // ⚠️  REPLACE THESE WITH YOUR ACTUAL API KEYS  ⚠️
  // ══════════════════════════════════════════════
  static const String openWeatherApiKey = '';
   static const String geminiApiKey ='';
  

  // API Endpoints
  static const String weatherUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String forecastUrl =
      'https://api.openweathermap.org/data/2.5/forecast';
  static const String iconBaseUrl =
      'https://openweathermap.org/img/wn/';

  // Gemini Model
  static const String geminiModel = 'gemini-1.5-flash-latest';

  // ── App Colors ──────────────────────────────────
  static const Color deepNavy = Color(0xFF0A1628);
  static const Color cardColor = Color(0x14FFFFFF);
  static const Color cardBorder = Color(0x26FFFFFF);

  // ── Weather Gradients (by condition) ───────────
  static List<Color> gradientForCondition(String condition, bool isDay) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return isDay
            ? [const Color(0xFF0D47A1), const Color(0xFF1565C0), const Color(0xFF039BE5)]
            : [const Color(0xFF0D1B2A), const Color(0xFF1A237E), const Color(0xFF283593)];
      case 'clouds':
        return isDay
            ? [const Color(0xFF37474F), const Color(0xFF455A64), const Color(0xFF607D8B)]
            : [const Color(0xFF0D1B2A), const Color(0xFF263238), const Color(0xFF37474F)];
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF0D1B2A), const Color(0xFF1A237E), const Color(0xFF0277BD)];
      case 'thunderstorm':
        return [const Color(0xFF0D1B2A), const Color(0xFF1A1A2E), const Color(0xFF16213E)];
      case 'snow':
        return [const Color(0xFF1A237E), const Color(0xFF283593), const Color(0xFF3F51B5)];
      case 'mist':
      case 'fog':
      case 'haze':
        return [const Color(0xFF546E7A), const Color(0xFF607D8B), const Color(0xFF78909C)];
      default:
        return [const Color(0xFF0A1628), const Color(0xFF1565C0), const Color(0xFF029BE5)];
    }
  }
}
