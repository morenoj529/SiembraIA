import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadVisitPhoto({
    required String visitId,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final ref =
        _storage.ref().child('visits/$visitId/photos/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deletePhoto(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // Ignore errors when deleting (file may already be gone)
    }
  }
}
