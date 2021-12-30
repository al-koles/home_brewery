
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> createUserWithEmail(String _email, String _password) async {
    final user = (await _firebaseAuth.createUserWithEmailAndPassword(
      email: _email,
      password: _password,
    ))
        .user;
    return user;
  }

  Future<User?> signInWithEmail(String _email, String _password) async {
    final user = (await _firebaseAuth.signInWithEmailAndPassword(
      email: _email,
      password: _password,
    ))
        .user;
    return user;
  }

  String? getCurrentEmail() {
    return _firebaseAuth.currentUser!.email;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> get authStream => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;
}
