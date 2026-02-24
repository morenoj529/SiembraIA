enum AlertSeverity { baja, media, alta }

class AlertModel {
  final String id;
  final String plotId;
  final String plotNombre;
  final String mensaje;
  final AlertSeverity severidad;
  final String categoria; // 'hidrico', 'hongos', 'plaga', 'calor'
  final DateTime generadaEn;

  const AlertModel({
    required this.id,
    required this.plotId,
    required this.plotNombre,
    required this.mensaje,
    required this.severidad,
    required this.categoria,
    required this.generadaEn,
  });

  AlertModel copyWith({AlertSeverity? severidad}) {
    return AlertModel(
      id: id,
      plotId: plotId,
      plotNombre: plotNombre,
      mensaje: mensaje,
      severidad: severidad ?? this.severidad,
      categoria: categoria,
      generadaEn: generadaEn,
    );
  }
}
