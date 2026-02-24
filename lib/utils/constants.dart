class AppConstants {
  AppConstants._();

  // Replace with your OpenWeather API key or set via --dart-define
  static const String openWeatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: 'YOUR_KEY');

  // Default location: Los Mochis, Sinaloa
  static const double defaultLat = 25.7964;
  static const double defaultLon = -109.0214;
  static const String defaultRegion = 'Los Mochis';
}
