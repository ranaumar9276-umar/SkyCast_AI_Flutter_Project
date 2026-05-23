class WeatherModel {
  final String cityName;
  final String country;
  final double lat;
  final double lon;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final int visibility; // metres
  final String condition; // e.g. "Clear", "Clouds", "Rain"
  final String description; // e.g. "clear sky"
  final String icon; // OpenWeatherMap icon code
  final double windSpeed; // m/s
  final int windDeg;
  final int cloudiness; // %
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime lastUpdated;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.condition,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.windDeg,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] as String? ?? 'Unknown',
      country: (json['sys'] as Map)['country'] as String? ?? '',
      lat: ((json['coord'] as Map)['lat'] as num).toDouble(),
      lon: ((json['coord'] as Map)['lon'] as num).toDouble(),
      temp: ((json['main'] as Map)['temp'] as num).toDouble(),
      feelsLike: ((json['main'] as Map)['feels_like'] as num).toDouble(),
      tempMin: ((json['main'] as Map)['temp_min'] as num).toDouble(),
      tempMax: ((json['main'] as Map)['temp_max'] as num).toDouble(),
      humidity: (json['main'] as Map)['humidity'] as int,
      pressure: (json['main'] as Map)['pressure'] as int,
      visibility: json['visibility'] as int? ?? 10000,
      condition: ((json['weather'] as List).first as Map)['main'] as String,
      description: ((json['weather'] as List).first as Map)['description'] as String,
      icon: ((json['weather'] as List).first as Map)['icon'] as String,
      windSpeed: ((json['wind'] as Map)['speed'] as num).toDouble(),
      windDeg: (json['wind'] as Map)['deg'] as int? ?? 0,
      cloudiness: (json['clouds'] as Map)['all'] as int,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((json['sys'] as Map)['sunrise'] as int) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((json['sys'] as Map)['sunset'] as int) * 1000,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  bool get isDay {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
