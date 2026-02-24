import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plot_model.dart';

class PlotRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('plots');

  Stream<List<PlotModel>> watchUserPlots(String userId) {
    return _col
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PlotModel.fromFirestore).toList());
  }

  Future<List<PlotModel>> getUserPlots(String userId) async {
    final snap = await _col
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(PlotModel.fromFirestore).toList();
  }

  Future<List<PlotModel>> getFarmPlots(String farmId) async {
    final snap = await _col
        .where('farmId', isEqualTo: farmId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(PlotModel.fromFirestore).toList();
  }

  Future<PlotModel?> getPlot(String plotId) async {
    final doc = await _col.doc(plotId).get();
    if (!doc.exists) return null;
    return PlotModel.fromFirestore(doc);
  }

  Future<PlotModel> createPlot(PlotModel plot) async {
    final docRef = await _col.add(plot.toFirestore());
    final doc = await docRef.get();
    return PlotModel.fromFirestore(doc);
  }

  Future<void> updatePlot(PlotModel plot) async {
    await _col.doc(plot.id).update(plot.toFirestore());
  }

  Future<void> deletePlot(String plotId) async {
    await _col.doc(plotId).delete();
  }
}
