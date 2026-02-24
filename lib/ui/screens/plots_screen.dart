import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/farm_state.dart';
import '../../models/plot_model.dart';
import '../widgets/common_widgets.dart';

class PlotsScreen extends ConsumerStatefulWidget {
  const PlotsScreen({super.key});

  @override
  ConsumerState<PlotsScreen> createState() => _PlotsScreenState();
}

class _PlotsScreenState extends ConsumerState<PlotsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final plotsAsync = ref.watch(plotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcelas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nueva parcela',
            onPressed: () => context.push('/plots/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar parcela…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: plotsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateWidget(
                message: 'Error al cargar parcelas',
                onRetry: () => ref.invalidate(plotsProvider),
              ),
              data: (plots) {
                final filtered = _query.isEmpty
                    ? plots
                    : plots
                        .where((p) =>
                            p.nombre.toLowerCase().contains(_query) ||
                            p.cultivo.toLowerCase().contains(_query))
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    message: plots.isEmpty
                        ? 'No tienes parcelas registradas.\nToca el + para agregar una.'
                        : 'Sin resultados para "$_query"',
                    icon: Icons.grass_outlined,
                    onAction:
                        plots.isEmpty ? () => context.push('/plots/new') : null,
                    actionLabel: 'Agregar parcela',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _PlotCard(plot: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlotCard extends StatelessWidget {
  final PlotModel plot;
  const _PlotCard({required this.plot});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.grass, color: Color(0xFF2E7D32)),
        ),
        title: Text(plot.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${plot.cultivo} · ${plot.variedad}\n'
            '${plot.superficieHa.toStringAsFixed(2)} ha'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/plots/${plot.id}'),
      ),
    );
  }
}
