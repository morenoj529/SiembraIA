import 'package:cloud_firestore/cloud_firestore.dart';

enum EtapaFenologica {
  germinacion,
  plantula,
  vegetativo,
  floracion,
  fructificacion,
  maduracion,
  cosecha,
}

class VisitModel {
  final String id;
  final String plotId;
  final DateTime fechaHora;
  final String observaciones;
  final EtapaFenologica etapaFenologica;
  final double alturaPlantaCm;
  final double humedadSueloPct;
  final bool plagaPresente;
  final int severidadPlaga; // 0-5
  final String notas;
  final String createdBy;
  final DateTime createdAt;

  const VisitModel({
    required this.id,
    required this.plotId,
    required this.fechaHora,
    required this.observaciones,
    required this.etapaFenologica,
    required this.alturaPlantaCm,
    required this.humedadSueloPct,
    required this.plagaPresente,
    required this.severidadPlaga,
    required this.notas,
    required this.createdBy,
    required this.createdAt,
  });

  factory VisitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitModel(
      id: doc.id,
      plotId: data['plotId'] as String? ?? '',
      fechaHora:
          (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      observaciones: data['observaciones'] as String? ?? '',
      etapaFenologica: EtapaFenologica.values.firstWhere(
        (e) => e.name == (data['etapaFenologica'] as String? ?? 'vegetativo'),
        orElse: () => EtapaFenologica.vegetativo,
      ),
      alturaPlantaCm: (data['alturaPlantaCm'] as num?)?.toDouble() ?? 0.0,
      humedadSueloPct: (data['humedadSueloPct'] as num?)?.toDouble() ?? 0.0,
      plagaPresente: data['plagaPresente'] as bool? ?? false,
      severidadPlaga: data['severidadPlaga'] as int? ?? 0,
      notas: data['notas'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plotId': plotId,
        'fechaHora': Timestamp.fromDate(fechaHora),
        'observaciones': observaciones,
        'etapaFenologica': etapaFenologica.name,
        'alturaPlantaCm': alturaPlantaCm,
        'humedadSueloPct': humedadSueloPct,
        'plagaPresente': plagaPresente,
        'severidadPlaga': severidadPlaga,
        'notas': notas,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
