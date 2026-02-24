import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/farm_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/common_widgets.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(alertsProvider),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          message: 'Error generando alertas',
          onRetry: () => ref.invalidate(alertsProvider),
        ),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const EmptyStateWidget(
              message: 'Sin alertas activas. ¡Todo en orden!',
              icon: Icons.check_circle_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: alerts.length,
            itemBuilder: (_, i) => AlertCard(alert: alerts[i]),
          );
        },
      ),
    );
  }
}
