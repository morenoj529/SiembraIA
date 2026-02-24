import 'package:cloud_firestore/cloud_firestore.dart';

class PlotModel {
  final String id;
  final String farmId;
  final String nombre;
  final String cultivo;
  final String variedad;
  final double superficieHa;
  final GeoPoint geoPoint;
  final String ownerId;
  final DateTime createdAt;

  const PlotModel({
    required this.id,
    required this.farmId,
    required this.nombre,
    required this.cultivo,
    required this.variedad,
    required this.superficieHa,
    required this.geoPoint,
    required this.ownerId,
    required this.createdAt,
  });

  factory PlotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlotModel(
      id: doc.id,
      farmId: data['farmId'] as String? ?? '',
      nombre: data['nombre'] as String? ?? '',
      cultivo: data['cultivo'] as String? ?? '',
      variedad: data['variedad'] as String? ?? '',
      superficieHa: (data['superficieHa'] as num?)?.toDouble() ?? 0.0,
      geoPoint: data['geoPoint'] as GeoPoint? ??
          const GeoPoint(25.7964, -109.0214), // Los Mochis default
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'farmId': farmId,
        'nombre': nombre,
        'cultivo': cultivo,
        'variedad': variedad,
        'superficieHa': superficieHa,
        'geoPoint': geoPoint,
        'ownerId': ownerId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  PlotModel copyWith({
    String? nombre,
    String? cultivo,
    String? variedad,
    double? superficieHa,
    GeoPoint? geoPoint,
    String? farmId,
  }) {
    return PlotModel(
      id: id,
      farmId: farmId ?? this.farmId,
      nombre: nombre ?? this.nombre,
      cultivo: cultivo ?? this.cultivo,
      variedad: variedad ?? this.variedad,
      superficieHa: superficieHa ?? this.superficieHa,
      geoPoint: geoPoint ?? this.geoPoint,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }
}
