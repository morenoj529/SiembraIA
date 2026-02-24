import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String visitId;
  final String urlStorage;
  final List<String> labels;
  final DateTime createdAt;

  const PhotoModel({
    required this.id,
    required this.visitId,
    required this.urlStorage,
    required this.labels,
    required this.createdAt,
  });

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      id: doc.id,
      visitId: data['visitId'] as String? ?? '',
      urlStorage: data['urlStorage'] as String? ?? '',
      labels: List<String>.from(data['labels'] as List? ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'visitId': visitId,
        'urlStorage': urlStorage,
        'labels': labels,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
