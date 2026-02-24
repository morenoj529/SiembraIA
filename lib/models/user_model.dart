import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { agricultor, ingeniero }

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final UserRole rol;
  final String region;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.region,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      nombre: data['nombre'] as String? ?? '',
      rol: UserRole.values.firstWhere(
        (r) => r.name == (data['rol'] as String? ?? 'agricultor'),
        orElse: () => UserRole.agricultor,
      ),
      region: data['region'] as String? ?? 'Los Mochis',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'nombre': nombre,
        'rol': rol.name,
        'region': region,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? nombre,
    UserRole? rol,
    String? region,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      region: region ?? this.region,
      createdAt: createdAt,
    );
  }
}
