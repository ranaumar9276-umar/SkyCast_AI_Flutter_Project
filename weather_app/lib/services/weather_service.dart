import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../utils/constants.dart';

class WeatherService {
  static const Duration _timeout = Duration(seconds: 15);

  // ── Current Weather ────────────────────────────────────────────────────────

  Future<WeatherModel> getWeatherByCity(String city) async {
    final uri = Uri.parse(
      '${AppConstants.weatherUrl}'
      '?q=${Uri.encodeQueryComponent(city)}'
      '&appid=${AppConstants.openWeatherApiKey}'
      '&units=metric',
    );
    return _parseWeather(await _get(uri));
  }

  Future<WeatherModel> getWeatherByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${AppConstants.weatherUrl}'
      '?lat=$lat&lon=$lon'
      '&appid=${AppConstants.openWeatherApiKey}'
      '&units=metric',
    );
    return _parseWeather(await _get(uri));
  }

  // ── 5-Day Forecast (3-hour intervals) ─────────────────────────────────────

  Future<List<ForecastModel>> getForecastByCity(String city) async {
    final uri = Uri.parse(
      '${AppConstants.forecastUrl}'
      '?q=${Uri.encodeQueryComponent(city)}'
      '&appid=${AppConstants.openWeatherApiKey}'
      '&units=metric&cnt=40',
    );
    return _parseForecast(await _get(uri));
  }

  Future<List<ForecastModel>> getForecastByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${AppConstants.forecastUrl}'
      '?lat=$lat&lon=$lon'
      '&appid=${AppConstants.openWeatherApiKey}'
      '&units=metric&cnt=40',
    );
    return _parseForecast(await _get(uri));
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri).timeout(_timeout);
    } catch (_) {
      throw Exception('Network error. Please check your connection.');
    }
  }

  WeatherModel _parseWeather(http.Response response) {
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      throw Exception('City not found. Please check the name and try again.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Update it in constants.dart');
    } else {
      throw Exception('Weather service error (${response.statusCode}).');
    }
  }

  List<ForecastModel> _parseForecast(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['list'] as List)
          .map((e) => ForecastModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load forecast data.');
  }
}
