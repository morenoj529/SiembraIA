import 'package:cloud_firestore/cloud_firestore.dart';

class FarmModel {
  final String id;
  final String nombre;
  final String ownerId;
  final String ubicacionGeneral;
  final List<String> colaboradores;
  final DateTime createdAt;

  const FarmModel({
    required this.id,
    required this.nombre,
    required this.ownerId,
    required this.ubicacionGeneral,
    required this.colaboradores,
    required this.createdAt,
  });

  factory FarmModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmModel(
      id: doc.id,
      nombre: data['nombre'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      ubicacionGeneral: data['ubicacionGeneral'] as String? ?? '',
      colaboradores: List<String>.from(data['colaboradores'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'ownerId': ownerId,
        'ubicacionGeneral': ubicacionGeneral,
        'colaboradores': colaboradores,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  FarmModel copyWith({
    String? nombre,
    String? ubicacionGeneral,
    List<String>? colaboradores,
  }) {
    return FarmModel(
      id: id,
      nombre: nombre ?? this.nombre,
      ownerId: ownerId,
      ubicacionGeneral: ubicacionGeneral ?? this.ubicacionGeneral,
      colaboradores: colaboradores ?? this.colaboradores,
      createdAt: createdAt,
    );
  }
}
