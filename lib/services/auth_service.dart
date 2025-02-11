import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar usuário
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveUserToken(userCredential.user?.uid ?? '');
      return userCredential.user;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      return null;
    }
  }

  // Fazer login do usuário
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveUserToken(userCredential.user?.uid ?? '');
      return userCredential.user;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  // Logout do usuário
  Future<void> logoutUser() async {
    await _auth.signOut();
    await clearUserToken();
  }

  // Verificar se há usuário autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Salvar token do usuário
  Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  // Obter token do usuário
  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  // Remover token do usuário ao deslogar
  Future<void> clearUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }
}