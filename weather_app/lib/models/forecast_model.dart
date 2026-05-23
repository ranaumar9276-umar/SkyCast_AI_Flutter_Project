class ForecastModel {
  final DateTime dateTime;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String condition;
  final String description;
  final String icon;
  final double windSpeed;
  final double pop; // probability of precipitation 0.0 – 1.0

  ForecastModel({
    required this.dateTime,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.condition,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.pop,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      temp: ((json['main'] as Map)['temp'] as num).toDouble(),
      feelsLike: ((json['main'] as Map)['feels_like'] as num).toDouble(),
      tempMin: ((json['main'] as Map)['temp_min'] as num).toDouble(),
      tempMax: ((json['main'] as Map)['temp_max'] as num).toDouble(),
      humidity: (json['main'] as Map)['humidity'] as int,
      condition: ((json['weather'] as List).first as Map)['main'] as String,
      description: ((json['weather'] as List).first as Map)['description'] as String,
      icon: ((json['weather'] as List).first as Map)['icon'] as String,
      windSpeed: ((json['wind'] as Map)['speed'] as num).toDouble(),
      pop: (json['pop'] as num? ?? 0).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get dayAbbr {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dateTime.weekday % 7];
  }
}
