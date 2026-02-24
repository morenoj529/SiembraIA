import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visit_model.dart';

class VisitRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('visits');

  Stream<List<VisitModel>> watchPlotVisits(String plotId) {
    return _col
        .where('plotId', isEqualTo: plotId)
        .orderBy('fechaHora', descending: true)
        .snapshots()
        .map((s) => s.docs.map(VisitModel.fromFirestore).toList());
  }

  Future<List<VisitModel>> getPlotVisits(String plotId) async {
    final snap = await _col
        .where('plotId', isEqualTo: plotId)
        .orderBy('fechaHora', descending: true)
        .get();
    return snap.docs.map(VisitModel.fromFirestore).toList();
  }

  Future<VisitModel?> getLastVisit(String plotId) async {
    final snap = await _col
        .where('plotId', isEqualTo: plotId)
        .orderBy('fechaHora', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return VisitModel.fromFirestore(snap.docs.first);
  }

  Future<VisitModel> createVisit(VisitModel visit) async {
    final docRef = await _col.add(visit.toFirestore());
    final doc = await docRef.get();
    return VisitModel.fromFirestore(doc);
  }

  Future<void> updateVisit(VisitModel visit) async {
    await _col.doc(visit.id).update(visit.toFirestore());
  }

  Future<void> deleteVisit(String visitId) async {
    await _col.doc(visitId).delete();
  }
}
