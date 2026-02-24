/// Weather data models returned by OpenWeather API.
class WeatherData {
  final double tempActual;
  final double tempMax;
  final double tempMin;
  final double humedad; // %
  final double velocidadViento; // m/s
  final String descripcion;
  final String iconCode;
  final double lat;
  final double lon;
  final DateTime timestamp;

  const WeatherData({
    required this.tempActual,
    required this.tempMax,
    required this.tempMin,
    required this.humedad,
    required this.velocidadViento,
    required this.descripcion,
    required this.iconCode,
    required this.lat,
    required this.lon,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather =
        (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final coord = json['coord'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      tempActual: (main['temp'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      humedad: (main['humidity'] as num).toDouble(),
      velocidadViento: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      descripcion: weather['description'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '',
      lat: (coord['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (coord['lon'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.now(),
    );
  }
}

class ForecastEntry {
  final DateTime dateTime;
  final double temp;
  final double tempMax;
  final double tempMin;
  final double humedad;
  final double probabilidadLluvia; // 0-1
  final double lluviaMm;
  final String descripcion;
  final String iconCode;

  const ForecastEntry({
    required this.dateTime,
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.humedad,
    required this.probabilidadLluvia,
    required this.lluviaMm,
    required this.descripcion,
    required this.iconCode,
  });

  factory ForecastEntry.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather =
        (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final rain = json['rain'] as Map<String, dynamic>? ?? {};

    return ForecastEntry(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as int) * 1000),
      temp: (main['temp'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      humedad: (main['humidity'] as num).toDouble(),
      probabilidadLluvia: (json['pop'] as num?)?.toDouble() ?? 0.0,
      lluviaMm: (rain['3h'] as num?)?.toDouble() ?? 0.0,
      descripcion: weather['description'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '',
    );
  }
}

class WeatherForecast {
  final List<ForecastEntry> entries;
  final DateTime fetchedAt;

  const WeatherForecast({required this.entries, required this.fetchedAt});

  /// Returns forecast entries within the next [hours] hours.
  List<ForecastEntry> next(int hours) {
    final limit = DateTime.now().add(Duration(hours: hours));
    return entries.where((e) => e.dateTime.isBefore(limit)).toList();
  }

  /// Returns true if there is any rain expected in the next [hours] hours.
  bool hasRainIn(int hours) {
    return next(hours).any((e) => e.probabilidadLluvia > 0.3);
  }

  /// Returns the max temperature in the next [hours] hours.
  double maxTempIn(int hours) {
    final upcoming = next(hours);
    if (upcoming.isEmpty) return 0;
    return upcoming.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b);
  }
}
