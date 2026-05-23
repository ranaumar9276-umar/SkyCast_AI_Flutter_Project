import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';

enum AppStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  // ── Private state ──────────────────────────────────────────────────────────
  final _weather = WeatherService();
  final _gemini = GeminiService();

  AppStatus _status = AppStatus.initial;
  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  String _error = '';
  String _lastCity = '';
  bool _isCelsius = true;
  List<String> _recentSearches = [];

  // ── Public getters ─────────────────────────────────────────────────────────

  AppStatus get status => _status;
  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecast => _forecast;
  String get error => _error;
  bool get isCelsius => _isCelsius;
  List<String> get recentSearches => _recentSearches;
  GeminiService get gemini => _gemini;

  /// Next 24 hours (8 × 3-hour slots)
  List<ForecastModel> get hourly => _forecast.take(8).toList();

  /// One entry per calendar day (noon preferred) – up to 7 days
  List<ForecastModel> get daily {
    if (_forecast.isEmpty) return [];
    final map = <String, ForecastModel>{};
    for (final f in _forecast) {
      final key = '${f.dateTime.year}-${f.dateTime.month}-${f.dateTime.day}';
      if (!map.containsKey(key) || f.dateTime.hour == 12) map[key] = f;
    }
    return map.values.take(7).toList();
  }

  double displayTemp(double celsius) =>
      _isCelsius ? celsius : celsius * 9 / 5 + 32;

  String get tempUnit => _isCelsius ? '°C' : '°F';

  // ── Constructor ────────────────────────────────────────────────────────────

  WeatherProvider() {
    _loadPrefs();
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> fetchByLocation() async {
    _setStatus(AppStatus.loading);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        // Graceful fallback
        await fetchByCity('Karachi');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final w = await _weather.getWeatherByCoords(pos.latitude, pos.longitude);
      final f = await _weather.getForecastByCoords(pos.latitude, pos.longitude);

      _currentWeather = w;
      _forecast = f;
      _lastCity = w.cityName;
      _gemini.startChat(w);
      _setStatus(AppStatus.loaded);
    } catch (e) {
      _error = _clean(e.toString());
      _setStatus(AppStatus.error);
    }
  }

  Future<void> fetchByCity(String city) async {
    if (city.trim().isEmpty) return;
    _setStatus(AppStatus.loading);
    try {
      final w = await _weather.getWeatherByCity(city);
      final f = await _weather.getForecastByCity(city);

      _currentWeather = w;
      _forecast = f;
      _lastCity = city;
      _addRecent(city);
      _gemini.startChat(w);
      _setStatus(AppStatus.loaded);
    } catch (e) {
      _error = _clean(e.toString());
      _setStatus(AppStatus.error);
    }
  }

  Future<void> refresh() async {
    if (_lastCity.isEmpty) {
      await fetchByLocation();
    } else {
      await fetchByCity(_lastCity);
    }
  }

  Future<void> toggleUnit() async {
    _isCelsius = !_isCelsius;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius', _isCelsius);
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setStatus(AppStatus s) {
    _status = s;
    notifyListeners();
  }

  String _clean(String e) => e.replaceAll('Exception: ', '');

  void _addRecent(String city) async {
    final c = city.trim();
    _recentSearches.removeWhere((s) => s.toLowerCase() == c.toLowerCase());
    _recentSearches.insert(0, c);
    if (_recentSearches.length > 6) _recentSearches = _recentSearches.take(6).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', _recentSearches);
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isCelsius = prefs.getBool('isCelsius') ?? true;
    _recentSearches = prefs.getStringList('recentSearches') ?? [];
    notifyListeners();
  }
}
