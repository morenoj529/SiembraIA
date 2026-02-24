import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farm_model.dart';
import '../models/alert_model.dart';
import '../models/plot_model.dart';
import 'providers.dart';
import 'auth_state.dart';

// ── Farms ────────────────────────────────────────────────────────────────────

final farmsProvider = StreamProvider.autoDispose<List<FarmModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final userId = userAsync.valueOrNull?.uid;
  if (userId == null) return const Stream.empty();
  return ref.read(farmRepositoryProvider).watchUserFarms(userId);
});

// ── Plots ────────────────────────────────────────────────────────────────────

final plotsProvider = StreamProvider.autoDispose<List<PlotModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final userId = userAsync.valueOrNull?.uid;
  if (userId == null) return const Stream.empty();
  return ref.read(plotRepositoryProvider).watchUserPlots(userId);
});

// ── Alerts ───────────────────────────────────────────────────────────────────

final alertsProvider =
    FutureProvider.autoDispose<List<AlertModel>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final userId = userAsync.valueOrNull?.uid;
  if (userId == null) return [];

  final plots =
      await ref.read(plotRepositoryProvider).getUserPlots(userId);

  final allAlerts = <AlertModel>[];
  final visitRepo = ref.read(visitRepositoryProvider);
  final weatherSvc = ref.read(weatherServiceProvider);
  final engine = ref.read(iaEngineProvider);

  for (final plot in plots) {
    final lastVisit = await visitRepo.getLastVisit(plot.id);
    final weather = await weatherSvc.getCurrentWeather(
      plot.geoPoint.latitude,
      plot.geoPoint.longitude,
    );
    final forecast = await weatherSvc.getForecast(
      plot.geoPoint.latitude,
      plot.geoPoint.longitude,
    );

    final plotAlerts = await engine.generateAlerts(
      plot: plot,
      lastVisit: lastVisit,
      currentWeather: weather,
      forecast: forecast,
    );
    allAlerts.addAll(plotAlerts);
  }

  // Sort: alta first, then media, then baja
  allAlerts.sort((a, b) {
    const order = {
      AlertSeverity.alta: 0,
      AlertSeverity.media: 1,
      AlertSeverity.baja: 2,
    };
    return (order[a.severidad] ?? 2).compareTo(order[b.severidad] ?? 2);
  });

  return allAlerts;
});
