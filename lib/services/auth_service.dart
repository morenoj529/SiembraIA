import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _fetchOrCreateProfile(credential.user!);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String nombre,
    required UserRole rol,
    String region = 'Los Mochis',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      email: email.trim(),
      nombre: nombre,
      rol: rol,
      region: region,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore());

    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel> _fetchOrCreateProfile(User firebaseUser) async {
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    final user = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      nombre: firebaseUser.displayName ?? '',
      rol: UserRole.agricultor,
      region: 'Los Mochis',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore());
    return user;
  }

  Future<UserModel?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(user.toFirestore());
  }
}
