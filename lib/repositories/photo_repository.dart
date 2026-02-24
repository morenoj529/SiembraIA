import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_model.dart';

class PhotoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('photos');

  Stream<List<PhotoModel>> watchVisitPhotos(String visitId) {
    return _col
        .where('visitId', isEqualTo: visitId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PhotoModel.fromFirestore).toList());
  }

  Future<List<PhotoModel>> getVisitPhotos(String visitId) async {
    final snap = await _col
        .where('visitId', isEqualTo: visitId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(PhotoModel.fromFirestore).toList();
  }

  Future<PhotoModel> createPhoto(PhotoModel photo) async {
    final docRef = await _col.add(photo.toFirestore());
    final doc = await docRef.get();
    return PhotoModel.fromFirestore(doc);
  }

  Future<void> deletePhoto(String photoId) async {
    await _col.doc(photoId).delete();
  }
}
