import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../services/ia_engine.dart';
import '../services/storage_service.dart';
import '../repositories/farm_repository.dart';
import '../repositories/plot_repository.dart';
import '../repositories/visit_repository.dart';
import '../repositories/photo_repository.dart';
import '../utils/constants.dart';

// ── Services ────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final weatherServiceProvider = Provider<WeatherService>(
  (_) => WeatherService(apiKey: AppConstants.openWeatherApiKey),
);

final iaEngineProvider = Provider<IAEngine>((_) => RuleBasedEngine());

final storageServiceProvider = Provider<StorageService>((_) => StorageService());

// ── Repositories ─────────────────────────────────────────────────────────────

final farmRepositoryProvider =
    Provider<FarmRepository>((_) => FarmRepository());

final plotRepositoryProvider =
    Provider<PlotRepository>((_) => PlotRepository());

final visitRepositoryProvider =
    Provider<VisitRepository>((_) => VisitRepository());

final photoRepositoryProvider =
    Provider<PhotoRepository>((_) => PhotoRepository());
