import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/visit_model.dart';
import '../../models/photo_model.dart';
import '../../state/providers.dart';
import '../../utils/helpers.dart';
import '../widgets/common_widgets.dart';

final _visitByIdProvider =
    FutureProvider.family<VisitModel?, String>((ref, visitId) async {
  final snap = await FirebaseFirestore.instance
      .collection('visits')
      .doc(visitId)
      .get();
  if (!snap.exists) return null;
  return VisitModel.fromFirestore(snap);
});

final _visitPhotosProvider =
    StreamProvider.family<List<PhotoModel>, String>((ref, visitId) {
  return ref.read(photoRepositoryProvider).watchVisitPhotos(visitId);
});

class VisitDetailScreen extends ConsumerStatefulWidget {
  final String visitId;
  const VisitDetailScreen({super.key, required this.visitId});

  @override
  ConsumerState<VisitDetailScreen> createState() =>
      _VisitDetailScreenState();
}

class _VisitDetailScreenState extends ConsumerState<VisitDetailScreen> {
  bool _uploadingPhoto = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 75, maxWidth: 1280);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await ref.read(storageServiceProvider).uploadVisitPhoto(
            visitId: widget.visitId,
            file: File(picked.path),
          );
      final photo = PhotoModel(
        id: '',
        visitId: widget.visitId,
        urlStorage: url,
        labels: [],
        createdAt: DateTime.now(),
      );
      await ref.read(photoRepositoryProvider).createPhoto(photo);
      if (mounted) context.showSnackBar('Foto subida');
    } catch (e) {
      if (mounted) context.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitAsync = ref.watch(_visitByIdProvider(widget.visitId));
    final photosAsync = ref.watch(_visitPhotosProvider(widget.visitId));
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de visita')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImageSourceSheet,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Foto'),
      ),
      body: visitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const ErrorStateWidget(message: 'Error cargando visita'),
        data: (visit) {
          if (visit == null) {
            return const ErrorStateWidget(message: 'Visita no encontrada');
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow('Fecha', fmt.format(visit.fechaHora)),
                        _InfoRow('Etapa', visit.etapaFenologica.name),
                        _InfoRow('Altura planta',
                            '${visit.alturaPlantaCm.toStringAsFixed(0)} cm'),
                        _InfoRow('Humedad suelo',
                            '${visit.humedadSueloPct.toStringAsFixed(0)}%'),
                        if (visit.plagaPresente)
                          _InfoRow('Plaga',
                              'Presente — Severidad ${visit.severidadPlaga}/5',
                              color: Colors.red),
                        if (visit.observaciones.isNotEmpty)
                          _InfoRow('Observaciones', visit.observaciones),
                        if (visit.notas.isNotEmpty)
                          _InfoRow('Notas', visit.notas),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Fotos',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_uploadingPhoto)
                  const Center(child: CircularProgressIndicator()),
                photosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error cargando fotos'),
                  data: (photos) {
                    if (photos.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                            'Sin fotos aún. Toca el botón + para agregar.'),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: photos[i].urlStorage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
