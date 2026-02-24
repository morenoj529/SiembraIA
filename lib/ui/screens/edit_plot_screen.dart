import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/plot_model.dart';
import '../../state/providers.dart';
import '../../state/auth_state.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../widgets/common_widgets.dart';

class EditPlotScreen extends ConsumerStatefulWidget {
  final String? plotId; // null = create new

  const EditPlotScreen({super.key, this.plotId});

  @override
  ConsumerState<EditPlotScreen> createState() => _EditPlotScreenState();
}

class _EditPlotScreenState extends ConsumerState<EditPlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cultivoCtrl = TextEditingController();
  final _variedadCtrl = TextEditingController();
  final _superficieCtrl = TextEditingController();
  final _latCtrl =
      TextEditingController(text: AppConstants.defaultLat.toString());
  final _lonCtrl =
      TextEditingController(text: AppConstants.defaultLon.toString());

  bool _loading = false;
  PlotModel? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.plotId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    try {
      final plot =
          await ref.read(plotRepositoryProvider).getPlot(widget.plotId!);
      if (plot != null && mounted) {
        _existing = plot;
        _nombreCtrl.text = plot.nombre;
        _cultivoCtrl.text = plot.cultivo;
        _variedadCtrl.text = plot.variedad;
        _superficieCtrl.text = plot.superficieHa.toString();
        _latCtrl.text = plot.geoPoint.latitude.toString();
        _lonCtrl.text = plot.geoPoint.longitude.toString();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      final lat = double.tryParse(_latCtrl.text) ?? AppConstants.defaultLat;
      final lon = double.tryParse(_lonCtrl.text) ?? AppConstants.defaultLon;

      if (_existing == null) {
        final plot = PlotModel(
          id: '',
          farmId: '',
          nombre: _nombreCtrl.text.trim(),
          cultivo: _cultivoCtrl.text.trim(),
          variedad: _variedadCtrl.text.trim(),
          superficieHa:
              double.tryParse(_superficieCtrl.text) ?? 0.0,
          geoPoint: GeoPoint(lat, lon),
          ownerId: uid,
          createdAt: DateTime.now(),
        );
        await ref.read(plotRepositoryProvider).createPlot(plot);
      } else {
        final updated = _existing!.copyWith(
          nombre: _nombreCtrl.text.trim(),
          cultivo: _cultivoCtrl.text.trim(),
          variedad: _variedadCtrl.text.trim(),
          superficieHa: double.tryParse(_superficieCtrl.text) ?? 0.0,
          geoPoint: GeoPoint(lat, lon),
        );
        await ref.read(plotRepositoryProvider).updatePlot(updated);
      }
      if (mounted) {
        context.showSnackBar('Parcela guardada');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cultivoCtrl.dispose();
    _variedadCtrl.dispose();
    _superficieCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plotId == null ? 'Nueva parcela' : 'Editar parcela'),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cultivoCtrl,
                  decoration: const InputDecoration(labelText: 'Cultivo'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _variedadCtrl,
                  decoration: const InputDecoration(labelText: 'Variedad'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _superficieCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Superficie (ha)'),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v);
                    return d == null || d < 0 ? 'Valor inválido' : null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Latitud'),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lonCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Longitud'),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.plotId == null ? 'Crear parcela' : 'Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
