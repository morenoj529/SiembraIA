import 'package:flutter_test/flutter_test.dart';
import 'package:siembra_ia/models/weather_model.dart';
import 'package:siembra_ia/services/ia_engine.dart';
import 'package:siembra_ia/models/visit_model.dart';
import 'package:siembra_ia/models/plot_model.dart';
import 'package:siembra_ia/models/alert_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Creates a minimal [PlotModel] for testing.
PlotModel _plot({String id = 'p1'}) => PlotModel(
      id: id,
      farmId: 'f1',
      nombre: 'Parcela Test',
      cultivo: 'Maíz',
      variedad: 'Híbrido 1',
      superficieHa: 5.0,
      geoPoint: const GeoPoint(25.7964, -109.0214),
      ownerId: 'u1',
      createdAt: DateTime(2024, 1, 1),
    );

/// Creates a minimal [VisitModel] with customisable params.
VisitModel _visit({
  double humedad = 50,
  bool plaga = false,
  int severidad = 0,
}) =>
    VisitModel(
      id: 'v1',
      plotId: 'p1',
      fechaHora: DateTime.now(),
      observaciones: '',
      etapaFenologica: EtapaFenologica.vegetativo,
      alturaPlantaCm: 80,
      humedadSueloPct: humedad,
      plagaPresente: plaga,
      severidadPlaga: severidad,
      notas: '',
      createdBy: 'u1',
      createdAt: DateTime.now(),
    );

/// Creates a [WeatherData] stub.
WeatherData _weather({
  double tempActual = 25,
  double tempMax = 28,
  double humedad = 60,
}) =>
    WeatherData(
      tempActual: tempActual,
      tempMax: tempMax,
      tempMin: 15,
      humedad: humedad,
      velocidadViento: 5,
      descripcion: 'nublado',
      iconCode: '04d',
      lat: 25.7964,
      lon: -109.0214,
      timestamp: DateTime.now(),
    );

/// Creates a [WeatherForecast] stub with optional rain flag.
WeatherForecast _forecast({bool rain = false}) {
  final entry = ForecastEntry(
    dateTime: DateTime.now().add(const Duration(hours: 6)),
    temp: 25,
    tempMax: 30,
    tempMin: 18,
    humedad: 65,
    probabilidadLluvia: rain ? 0.8 : 0.0,
    lluviaMm: rain ? 5 : 0,
    descripcion: rain ? 'lluvia' : 'despejado',
    iconCode: rain ? '10d' : '01d',
  );
  return WeatherForecast(entries: [entry], fetchedAt: DateTime.now());
}

void main() {
  final engine = RuleBasedEngine();

  group('RuleBasedEngine — regla hídrica', () {
    test('alerta cuando humedad < 25 y sin lluvia pronosticada', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(humedad: 20),
        currentWeather: _weather(),
        forecast: _forecast(rain: false),
      );
      expect(alerts.any((a) => a.categoria == 'hidrico'), isTrue);
      final alert = alerts.firstWhere((a) => a.categoria == 'hidrico');
      expect(alert.severidad, AlertSeverity.alta);
    });

    test('sin alerta cuando humedad >= 25', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(humedad: 30),
        currentWeather: _weather(),
        forecast: _forecast(rain: false),
      );
      expect(alerts.any((a) => a.categoria == 'hidrico'), isFalse);
    });

    test('sin alerta cuando hay lluvia pronosticada aunque humedad < 25', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(humedad: 20),
        currentWeather: _weather(),
        forecast: _forecast(rain: true),
      );
      expect(alerts.any((a) => a.categoria == 'hidrico'), isFalse);
    });
  });

  group('RuleBasedEngine — regla hongos', () {
    test('alerta cuando humedad aire > 70, temp 20-30, y lluvia próxima', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(humedad: 55),
        currentWeather: _weather(tempActual: 25, humedad: 75),
        forecast: _forecast(rain: true),
      );
      expect(alerts.any((a) => a.categoria == 'hongos'), isTrue);
    });

    test('sin alerta cuando no hay lluvia próxima', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(humedad: 55),
        currentWeather: _weather(tempActual: 25, humedad: 75),
        forecast: _forecast(rain: false),
      );
      expect(alerts.any((a) => a.categoria == 'hongos'), isFalse);
    });

    test('sin alerta cuando temperatura fuera de rango (>30)', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(humedad: 55),
        currentWeather: _weather(tempActual: 35, humedad: 80),
        forecast: _forecast(rain: true),
      );
      expect(alerts.any((a) => a.categoria == 'hongos'), isFalse);
    });
  });

  group('RuleBasedEngine — regla plaga', () {
    test('alerta cuando plaga presente y severidad >= 3', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(plaga: true, severidad: 3),
        currentWeather: _weather(),
        forecast: _forecast(),
      );
      expect(alerts.any((a) => a.categoria == 'plaga'), isTrue);
    });

    test('severidad alta cuando severidad >= 4', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(plaga: true, severidad: 4),
        currentWeather: _weather(),
        forecast: _forecast(),
      );
      final alert = alerts.firstWhere((a) => a.categoria == 'plaga');
      expect(alert.severidad, AlertSeverity.alta);
    });

    test('sin alerta cuando plaga presente pero severidad < 3', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(plaga: true, severidad: 2),
        currentWeather: _weather(),
        forecast: _forecast(),
      );
      expect(alerts.any((a) => a.categoria == 'plaga'), isFalse);
    });

    test('sin alerta cuando no hay plaga', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(plaga: false, severidad: 5),
        currentWeather: _weather(),
        forecast: _forecast(),
      );
      expect(alerts.any((a) => a.categoria == 'plaga'), isFalse);
    });
  });

  group('RuleBasedEngine — regla calor', () {
    test('alerta cuando tempMax > 36', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(),
        currentWeather: _weather(tempMax: 38),
        forecast: _forecast(),
      );
      expect(alerts.any((a) => a.categoria == 'calor'), isTrue);
      final alert = alerts.firstWhere((a) => a.categoria == 'calor');
      expect(alert.severidad, AlertSeverity.alta);
    });

    test('sin alerta cuando tempMax <= 36', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: _visit(),
        currentWeather: _weather(tempMax: 35),
        forecast: _forecast(),
      );
      expect(alerts.any((a) => a.categoria == 'calor'), isFalse);
    });
  });

  group('RuleBasedEngine — sin visita', () {
    test('retorna lista vacía cuando no hay última visita', () async {
      final alerts = await engine.generateAlerts(
        plot: _plot(),
        lastVisit: null,
        currentWeather: _weather(tempMax: 40),
        forecast: _forecast(rain: false),
      );
      expect(alerts, isEmpty);
    });
  });

  group('WeatherForecast helpers', () {
    test('hasRainIn detecta lluvia', () {
      final forecast = _forecast(rain: true);
      expect(forecast.hasRainIn(48), isTrue);
    });

    test('hasRainIn sin lluvia', () {
      final forecast = _forecast(rain: false);
      expect(forecast.hasRainIn(48), isFalse);
    });

    test('maxTempIn retorna max correcto', () {
      final forecast = _forecast(rain: false);
      // Our stub entry has tempMax: 30
      expect(forecast.maxTempIn(48), equals(30.0));
    });
  });
}
