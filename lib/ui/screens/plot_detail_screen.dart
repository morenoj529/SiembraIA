import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/plot_model.dart';
import '../../models/visit_model.dart';
import '../../state/providers.dart';
import '../widgets/common_widgets.dart';

final _plotDetailProvider =
    FutureProvider.family<PlotModel?, String>((ref, plotId) async {
  return ref.read(plotRepositoryProvider).getPlot(plotId);
});

final _plotVisitsProvider =
    StreamProvider.family<List<VisitModel>, String>((ref, plotId) {
  return ref.read(visitRepositoryProvider).watchPlotVisits(plotId);
});

class PlotDetailScreen extends ConsumerWidget {
  final String plotId;
  const PlotDetailScreen({super.key, required this.plotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotAsync = ref.watch(_plotDetailProvider(plotId));
    final visitsAsync = ref.watch(_plotVisitsProvider(plotId));

    return plotAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: ErrorStateWidget(message: 'Error cargando parcela')),
      data: (plot) {
        if (plot == null) {
          return Scaffold(
              body: ErrorStateWidget(message: 'Parcela no encontrada'));
        }
        return _PlotDetailBody(
            plot: plot, visitsAsync: visitsAsync, plotId: plotId);
      },
    );
  }
}

class _PlotDetailBody extends StatelessWidget {
  final PlotModel plot;
  final AsyncValue<List<VisitModel>> visitsAsync;
  final String plotId;

  const _PlotDetailBody(
      {required this.plot,
      required this.visitsAsync,
      required this.plotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plot.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => context.push('/plots/edit/${plot.id}'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/visits/new', extra: plot.id),
        icon: const Icon(Icons.add),
        label: const Text('Nueva visita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(plot: plot),
            const SizedBox(height: 16),
            visitsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const ErrorStateWidget(message: 'Error cargando visitas'),
              data: (visits) {
                if (visits.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Sin visitas registradas todavía.',
                    icon: Icons.calendar_today_outlined,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChartCard(title: 'Altura planta (cm)', visits: visits,
                        getValue: (v) => v.alturaPlantaCm),
                    const SizedBox(height: 12),
                    _ChartCard(title: 'Humedad suelo (%)', visits: visits,
                        getValue: (v) => v.humedadSueloPct),
                    const SizedBox(height: 12),
                    Text('Historial de visitas',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...visits.map((v) => _VisitTile(visit: v, plotId: plotId)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final PlotModel plot;
  const _InfoCard({required this.plot});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información de la parcela',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _InfoRow('Cultivo', plot.cultivo),
            _InfoRow('Variedad', plot.variedad),
            _InfoRow('Superficie', '${plot.superficieHa.toStringAsFixed(2)} ha'),
            _InfoRow(
              'Ubicación',
              '${plot.geoPoint.latitude.toStringAsFixed(5)}, '
                  '${plot.geoPoint.longitude.toStringAsFixed(5)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<VisitModel> visits;
  final double Function(VisitModel) getValue;

  const _ChartCard(
      {required this.title,
      required this.visits,
      required this.getValue});

  @override
  Widget build(BuildContext context) {
    final sorted = [...visits]
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    final spots = sorted
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), getValue(e.value)))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF2E7D32),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd/MM').format(sorted[idx].fechaHora),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (val, meta) => Text(
                        val.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  final VisitModel visit;
  final String plotId;
  const _VisitTile({required this.visit, required this.plotId});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
        title: Text(fmt.format(visit.fechaHora)),
        subtitle: Text('Etapa: ${visit.etapaFenologica.name} · '
            'Altura: ${visit.alturaPlantaCm.toStringAsFixed(0)} cm · '
            'Humedad: ${visit.humedadSueloPct.toStringAsFixed(0)}%'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/visits/${visit.id}'),
        isThreeLine: true,
      ),
    );
  }
}
