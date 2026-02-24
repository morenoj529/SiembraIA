import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
import '../../utils/app_theme.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;

  const AlertCard({super.key, required this.alert});

  IconData get _icon {
    switch (alert.categoria) {
      case 'hidrico':
        return Icons.water_drop_outlined;
      case 'hongos':
        return Icons.coronavirus_outlined;
      case 'plaga':
        return Icons.bug_report_outlined;
      case 'calor':
        return Icons.thermostat;
      default:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = alertColor(alert.severidad);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(_icon, color: color),
        ),
        title: Text(
          alert.plotNombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(alert.mensaje),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            alertLabel(alert.severidad),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
