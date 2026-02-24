import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const int _cacheDurationMinutes = 30;

  final String apiKey;

  WeatherService({required this.apiKey});

  String _currentKey(double lat, double lon) =>
      'weather_current_${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}';

  String _forecastKey(double lat, double lon) =>
      'weather_forecast_${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}';

  String _tsKey(String key) => '${key}_ts';

  Future<WeatherData?> getCurrentWeather(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _currentKey(lat, lon);
    final tsKey = _tsKey(key);

    final cachedTs = prefs.getInt(tsKey);
    if (cachedTs != null) {
      final age = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedTs));
      if (age.inMinutes < _cacheDurationMinutes) {
        final cached = prefs.getString(key);
        if (cached != null) {
          return WeatherData.fromJson(
              jsonDecode(cached) as Map<String, dynamic>);
        }
      }
    }

    final uri = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    await prefs.setString(key, response.body);
    await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);

    return WeatherData.fromJson(json);
  }

  Future<WeatherForecast?> getForecast(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _forecastKey(lat, lon);
    final tsKey = _tsKey(key);

    final cachedTs = prefs.getInt(tsKey);
    if (cachedTs != null) {
      final age = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedTs));
      if (age.inMinutes < _cacheDurationMinutes) {
        final cached = prefs.getString(key);
        if (cached != null) {
          return _parseForecast(
              jsonDecode(cached) as Map<String, dynamic>);
        }
      }
    }

    // cnt=16 gives ~48h of 3h-interval data
    final uri = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es&cnt=16',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    await prefs.setString(key, response.body);
    await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);

    return _parseForecast(json);
  }

  WeatherForecast _parseForecast(Map<String, dynamic> json) {
    final list = (json['list'] as List<dynamic>)
        .map((e) => ForecastEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return WeatherForecast(entries: list, fetchedAt: DateTime.now());
  }

  /// Clears cached weather data for the given location.
  Future<void> clearCache(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      _currentKey(lat, lon),
      _forecastKey(lat, lon),
    ];
    for (final k in keys) {
      await prefs.remove(k);
      await prefs.remove(_tsKey(k));
    }
  }
}
