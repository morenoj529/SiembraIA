import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/visit_model.dart';
import '../../models/plot_model.dart';
import '../../state/providers.dart';
import '../../state/auth_state.dart';
import '../../utils/helpers.dart';
import '../widgets/common_widgets.dart';

class NewVisitScreen extends ConsumerStatefulWidget {
  final String? plotId; // passed via router extra or navigation arg

  const NewVisitScreen({super.key, this.plotId});

  @override
  ConsumerState<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends ConsumerState<NewVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  EtapaFenologica _etapa = EtapaFenologica.vegetativo;
  double _alturaPlantaCm = 0;
  double _humedadSueloPct = 50;
  bool _plagaPresente = false;
  int _severidadPlaga = 0;
  bool _loading = false;
  String? _selectedPlotId;
  List<PlotModel> _plots = [];

  @override
  void initState() {
    super.initState();
    _selectedPlotId = widget.plotId;
    _loadPlots();
  }

  Future<void> _loadPlots() async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    final plots =
        await ref.read(plotRepositoryProvider).getUserPlots(uid);
    if (mounted) {
      setState(() {
        _plots = plots;
        if (_selectedPlotId == null && plots.isNotEmpty) {
          _selectedPlotId = plots.first.id;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlotId == null) {
      context.showSnackBar('Selecciona una parcela', isError: true);
      return;
    }
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      final visit = VisitModel(
        id: '',
        plotId: _selectedPlotId!,
        fechaHora: DateTime.now(),
        observaciones: _observacionesCtrl.text.trim(),
        etapaFenologica: _etapa,
        alturaPlantaCm: _alturaPlantaCm,
        humedadSueloPct: _humedadSueloPct,
        plagaPresente: _plagaPresente,
        severidadPlaga: _severidadPlaga,
        notas: _notasCtrl.text.trim(),
        createdBy: uid,
        createdAt: DateTime.now(),
      );
      final created =
          await ref.read(visitRepositoryProvider).createVisit(visit);
      if (mounted) {
        context.showSnackBar('Visita guardada');
        context.push('/visits/${created.id}');
      }
    } catch (e) {
      if (mounted) context.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva visita')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plot selector
                if (_plots.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedPlotId,
                    decoration: const InputDecoration(labelText: 'Parcela'),
                    items: _plots
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nombre),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedPlotId = v),
                    validator: (v) =>
                        v == null ? 'Selecciona una parcela' : null,
                  ),
                if (_plots.isEmpty)
                  const Text(
                    'No tienes parcelas. Crea una desde la pestaña Parcelas.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),

                // Etapa fenológica
                DropdownButtonFormField<EtapaFenologica>(
                  value: _etapa,
                  decoration: const InputDecoration(labelText: 'Etapa fenológica'),
                  items: EtapaFenologica.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(_etapaLabel(e)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _etapa = v);
                  },
                ),
                const SizedBox(height: 16),

                // Altura planta
                Text(
                  'Altura de planta: ${_alturaPlantaCm.toStringAsFixed(0)} cm',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Slider(
                  value: _alturaPlantaCm,
                  min: 0,
                  max: 300,
                  divisions: 300,
                  label: '${_alturaPlantaCm.toStringAsFixed(0)} cm',
                  onChanged: (v) => setState(() => _alturaPlantaCm = v),
                ),
                const SizedBox(height: 8),

                // Humedad suelo
                Text(
                  'Humedad del suelo: ${_humedadSueloPct.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Slider(
                  value: _humedadSueloPct,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${_humedadSueloPct.toStringAsFixed(0)}%',
                  onChanged: (v) => setState(() => _humedadSueloPct = v),
                ),
                const SizedBox(height: 16),

                // Plaga
                SwitchListTile(
                  title: const Text('¿Plaga presente?'),
                  value: _plagaPresente,
                  onChanged: (v) => setState(() {
                    _plagaPresente = v;
                    if (!v) _severidadPlaga = 0;
                  }),
                ),
                if (_plagaPresente) ...[
                  Text(
                    'Severidad de plaga: $_severidadPlaga / 5',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: _severidadPlaga.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: '$_severidadPlaga',
                    onChanged: (v) =>
                        setState(() => _severidadPlaga = v.toInt()),
                  ),
                ],
                const SizedBox(height: 16),

                // Observaciones
                TextFormField(
                  controller: _observacionesCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Observaciones'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Notas
                TextFormField(
                  controller: _notasCtrl,
                  decoration: const InputDecoration(labelText: 'Notas adicionales'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Guardar visita'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _etapaLabel(EtapaFenologica e) {
    const labels = {
      EtapaFenologica.germinacion: 'Germinación',
      EtapaFenologica.plantula: 'Plántula',
      EtapaFenologica.vegetativo: 'Vegetativo',
      EtapaFenologica.floracion: 'Floración',
      EtapaFenologica.fructificacion: 'Fructificación',
      EtapaFenologica.maduracion: 'Maduración',
      EtapaFenologica.cosecha: 'Cosecha',
    };
    return labels[e] ?? e.name;
  }
}
