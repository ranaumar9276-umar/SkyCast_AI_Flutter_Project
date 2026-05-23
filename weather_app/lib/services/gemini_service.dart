import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

/// Wraps the Gemini API for weather-aware AI chat.
class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chat;
  WeatherModel? _currentWeather;

  // ── Initialise model ───────────────────────────────────────────────────────
  void _init() {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.75,
        maxOutputTokens: 512,
      ),
    );
  }

  // ── Start / reset a chat session with weather context ──────────────────────
  void startChat(WeatherModel weather) {
    if (_model == null) _init();
    _currentWeather = weather;

    final systemPrompt = '''
You are SkyCast AI, a friendly and knowledgeable weather assistant.
Current real-time weather data for ${weather.cityName}, ${weather.country}:
  • Temperature   : ${weather.temp.round()}°C  (feels like ${weather.feelsLike.round()}°C)
  • Condition     : ${weather.condition}  — "${weather.description}"
  • Humidity      : ${weather.humidity}%
  • Wind          : ${weather.windSpeed} m/s
  • Visibility    : ${(weather.visibility / 1000).toStringAsFixed(1)} km
  • Cloudiness    : ${weather.cloudiness}%

Use ONLY this data to give specific, practical advice.
Keep replies concise (2–4 sentences), friendly, and emoji-friendly.
If the user asks about going outside, umbrella, clothing, activities —
answer based on the weather above.
Never guess — always refer to the actual data provided.
''';

    _chat = _model!.startChat(history: [
      Content.text(systemPrompt),
      Content.model([
        TextPart(
          'Hello! I\'m SkyCast AI 🌤️  '
          'I\'ve loaded the latest weather for **${weather.cityName}** '
          '(${weather.temp.round()}°C, ${weather.condition}). '
          'Ask me anything about today\'s weather!',
        ),
      ]),
    ]);
  }

  // ── Send a user message and get a reply ────────────────────────────────────
  Future<String> sendMessage(String text) async {
    if (_chat == null) {
      return '⚠️  AI assistant is not ready yet. Please wait a moment.';
    }
    try {
      final response = await _chat!.sendMessage(Content.text(text));
      return response.text ??
          'Sorry, I didn\'t get a response. Please try again.';
    } on GenerativeAIException catch (e) {
      return '❌ AI error: ${e.message}';
    } catch (_) {
      return '❌ Something went wrong. Please try again.';
    }
  }

  // ── One-shot greeting / summary (no chat history needed) ──────────────────
  Future<String> getWeatherSummary(WeatherModel weather) async {
    if (_model == null) _init();
    try {
      final prompt =
          'Give a friendly, upbeat 2-3 sentence weather summary and '
          '2 practical tips for today in ${weather.cityName}. '
          'Weather: ${weather.temp.round()}°C, ${weather.condition}, '
          'humidity ${weather.humidity}%, wind ${weather.windSpeed} m/s. '
          'Keep it under 60 words. Use 1-2 emojis.';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? '☀️ Have a wonderful day!';
    } catch (e) {
      return '⚠️  AI summary unavailable. Error: $e';
    }
  }

  WeatherModel? get currentWeather => _currentWeather;

  void reset() {
    _chat = null;
    _currentWeather = null;
  }
}