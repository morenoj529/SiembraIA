import '../models/alert_model.dart';
import '../models/visit_model.dart';
import '../models/weather_model.dart';
import '../models/plot_model.dart';

/// Abstract interface for the AI recommendation engine.
/// The current implementation is rule-based (MVP).
/// Replace [RuleBasedEngine] with an LLM/model implementation when ready.
abstract class IAEngine {
  Future<List<AlertModel>> generateAlerts({
    required PlotModel plot,
    required VisitModel? lastVisit,
    required WeatherData? currentWeather,
    required WeatherForecast? forecast,
  });
}

/// MVP rule-based implementation of [IAEngine].
class RuleBasedEngine implements IAEngine {
  @override
  Future<List<AlertModel>> generateAlerts({
    required PlotModel plot,
    required VisitModel? lastVisit,
    required WeatherData? currentWeather,
    required WeatherForecast? forecast,
  }) async {
    final alerts = <AlertModel>[];

    if (lastVisit == null) return alerts;

    final humedad = lastVisit.humedadSueloPct;
    final tempMax = currentWeather?.tempMax ??
        forecast?.maxTempIn(48) ??
        0.0;
    final tempActual = currentWeather?.tempActual ?? 0.0;
    final humedadAire = currentWeather?.humedad ?? 0.0;
    final lluviaProxima = forecast?.hasRainIn(48) ?? false;

    int alertIndex = 0;

    String makeId() => '${plot.id}_${alertIndex++}';

    // Rule 1: Hídrico
    if (humedad < 25 && !lluviaProxima) {
      alerts.add(AlertModel(
        id: makeId(),
        plotId: plot.id,
        plotNombre: plot.nombre,
        mensaje:
            'Riesgo de estrés hídrico: humedad del suelo en ${humedad.toStringAsFixed(0)}% sin lluvia prevista en 48 h. Considera programar riego.',
        severidad: AlertSeverity.alta,
        categoria: 'hidrico',
        generadaEn: DateTime.now(),
      ));
    }

    // Rule 2: Hongos
    if (humedadAire > 70 && tempActual >= 20 && tempActual <= 30 && lluviaProxima) {
      alerts.add(AlertModel(
        id: makeId(),
        plotId: plot.id,
        plotNombre: plot.nombre,
        mensaje:
            'Condiciones favorables para hongos: humedad del aire ${humedadAire.toStringAsFixed(0)}%, temperatura ${tempActual.toStringAsFixed(1)} °C y lluvia próxima. Monitorear manchas foliares.',
        severidad: AlertSeverity.media,
        categoria: 'hongos',
        generadaEn: DateTime.now(),
      ));
    }

    // Rule 3: Plaga
    if (lastVisit.plagaPresente && lastVisit.severidadPlaga >= 3) {
      alerts.add(AlertModel(
        id: makeId(),
        plotId: plot.id,
        plotNombre: plot.nombre,
        mensaje:
            'Plaga detectada con severidad ${lastVisit.severidadPlaga}/5. Revisar control de plaga y realizar inspección detallada.',
        severidad: lastVisit.severidadPlaga >= 4
            ? AlertSeverity.alta
            : AlertSeverity.media,
        categoria: 'plaga',
        generadaEn: DateTime.now(),
      ));
    }

    // Rule 4: Golpe de calor
    if (tempMax > 36) {
      alerts.add(AlertModel(
        id: makeId(),
        plotId: plot.id,
        plotNombre: plot.nombre,
        mensaje:
            'Temperatura máxima de ${tempMax.toStringAsFixed(1)} °C prevista. Riesgo de golpe de calor; revisar riego y considerar sombreado.',
        severidad: AlertSeverity.alta,
        categoria: 'calor',
        generadaEn: DateTime.now(),
      ));
    }

    return alerts;
  }
}
