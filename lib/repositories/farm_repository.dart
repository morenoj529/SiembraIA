import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm_model.dart';

class FarmRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('farms');

  Stream<List<FarmModel>> watchUserFarms(String userId) {
    // Firestore does not support orderBy with OR disjunction containing
    // arrayContains, so we merge two streams client-side.
    final owned = _col
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map(FarmModel.fromFirestore).toList());
    return owned;
  }

  Future<List<FarmModel>> getUserFarms(String userId) async {
    final snap = await _col
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(FarmModel.fromFirestore).toList();
  }

  Future<FarmModel?> getFarm(String farmId) async {
    final doc = await _col.doc(farmId).get();
    if (!doc.exists) return null;
    return FarmModel.fromFirestore(doc);
  }

  Future<FarmModel> createFarm(FarmModel farm) async {
    final docRef = await _col.add(farm.toFirestore());
    final doc = await docRef.get();
    return FarmModel.fromFirestore(doc);
  }

  Future<void> updateFarm(FarmModel farm) async {
    await _col.doc(farm.id).update(farm.toFirestore());
  }

  Future<void> deleteFarm(String farmId) async {
    await _col.doc(farmId).delete();
  }
}
