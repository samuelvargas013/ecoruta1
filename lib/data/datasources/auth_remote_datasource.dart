import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Acceso directo a Firebase Auth + Firestore para autenticación (F-01).
abstract class AuthRemoteDataSource {
  Stream<User?> get firebaseAuthState;
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String name, String email, String password, UserRole role);
  Future<UserModel> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<UserModel> getCurrentUser();
}

/// Implementación real: es el ÚNICO lugar de la app que habla directamente
/// con Firebase Auth y con Google Sign-In. Si mañana se cambia de proveedor,
/// solo se modifica esta clase.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required this._auth,
    required this._firestore,
    required this._googleSignIn,
  });

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  @override
  Stream<User?> get firebaseAuthState => _auth.authStateChanges();

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return _fetchProfile(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
      String name, String email, String password, UserRole role) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final uid = cred.user!.uid;
      await cred.user!.updateDisplayName(name);

      final model = UserModel(
        uid: uid,
        email: email.trim(),
        name: name,
        role: role,
      );
      await _users.doc(uid).set(model.toMap());
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Inicio de sesión con Google cancelado.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final uid = userCred.user!.uid;

      // Crear perfil si es la primera vez que entra con Google.
      final doc = await _users.doc(uid).get();
      if (!doc.exists) {
        final model = UserModel(
          uid: uid,
          email: userCred.user!.email ?? '',
          name: userCred.user!.displayName ?? 'Usuario',
          photoUrl: userCred.user!.photoURL,
        );
        await _users.doc(uid).set(model.toMap());
        return model;
      }
      return UserModel.fromDoc(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    // El cierre de Google puede fallar en web (no inicializado): no debe
    // impedir el cierre de sesión de Firebase, que es el que realmente importa.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('No hay sesión activa.');
    return _fetchProfile(user.uid);
  }

  Future<UserModel> _fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw AuthException('Perfil de usuario no encontrado.');
    return UserModel.fromDoc(doc);
  }

  /// Traduce los códigos de error técnicos de Firebase
  /// a mensajes entendibles para el usuario final.
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Correo no válido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña es muy débil (mín. 6 caracteres).';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      default:
        return 'Error de autenticación ($code).';
    }
  }
}
