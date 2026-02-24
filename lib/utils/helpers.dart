import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog<void>(
      context: this,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(this).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

String friendlyFirebaseError(Object e) {
  final msg = e.toString();
  if (msg.contains('user-not-found') || msg.contains('wrong-password') ||
      msg.contains('invalid-credential')) {
    return 'Correo o contraseña incorrectos.';
  }
  if (msg.contains('email-already-in-use')) {
    return 'Este correo ya está registrado.';
  }
  if (msg.contains('weak-password')) {
    return 'La contraseña debe tener al menos 6 caracteres.';
  }
  if (msg.contains('network-request-failed')) {
    return 'Sin conexión a internet. Verifica tu red.';
  }
  if (msg.contains('too-many-requests')) {
    return 'Demasiados intentos. Intenta de nuevo más tarde.';
  }
  return 'Ocurrió un error. Por favor intenta de nuevo.';
}
