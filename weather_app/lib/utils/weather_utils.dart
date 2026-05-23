class WeatherUtils {
  /// Returns an emoji for the given OpenWeatherMap condition string
  static String emojiForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      case 'dust':
      case 'sand':
        return '🌪️';
      case 'smoke':
        return '💨';
      default:
        return '🌤️';
    }
  }

  /// Compass direction from degrees
  static String windDirection(int degrees) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((degrees + 22.5) / 45).floor() % 8];
  }

  /// UV index label
  static String uviLabel(double uvi) {
    if (uvi < 3) return 'Low';
    if (uvi < 6) return 'Moderate';
    if (uvi < 8) return 'High';
    if (uvi < 11) return 'Very High';
    return 'Extreme';
  }

  /// Format visibility in km
  static String formatVisibility(int meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(0)} km';
    return '${meters} m';
  }

  /// Short hour string e.g. "3 PM"
  static String shortHour(DateTime dt) {
    final h = dt.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$display $period';
  }

  /// Weekday abbreviation
  static String dayName(DateTime dt) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[dt.weekday % 7];
  }

  /// Check if current time is daytime
  static bool isDay(DateTime sunrise, DateTime sunset) {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  /// Celsius to Fahrenheit
  static double toFahrenheit(double c) => c * 9 / 5 + 32;

  /// Basic weather advice string (used as fallback when Gemini is unavailable)
  static String basicAdvice(String condition, double temp, double windSpeed) {
    final buf = StringBuffer();
    if (temp > 35) {
      buf.write('🌡️ Very hot today — stay hydrated and wear sunscreen. ');
    } else if (temp > 28) {
      buf.write('☀️ Warm day — light clothing recommended. ');
    } else if (temp < 10) {
      buf.write('🧥 Cold outside — bundle up with warm layers. ');
    } else {
      buf.write('🌤️ Comfortable temperature today. ');
    }

    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        buf.write('☂️ Carry an umbrella — rain expected.');
        break;
      case 'thunderstorm':
        buf.write('⚡ Thunderstorm alert — stay indoors if possible!');
        break;
      case 'snow':
        buf.write('❄️ Snow is falling — dress warmly and drive carefully.');
        break;
      case 'clear':
        buf.write(temp > 30 ? '😎 Apply SPF 30+ sunscreen.' : '😊 Great day to go outside!');
        break;
      default:
        if (windSpeed > 10) buf.write('💨 Strong winds today — secure loose items.');
    }
    return buf.toString();
  }
}
