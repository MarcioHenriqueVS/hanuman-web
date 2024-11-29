import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../tratamento/error_snackbar.dart';
import '../tratamento/success_snackbar.dart';

class LogServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

   Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      debugPrint('Erro: $e');
      tratamentoDeErros.showErrorSnackbar(
          context, 'Falha ao tentar sair, tente novamente');
      return false;
    }
  }

    Future<bool?> isPersonal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      return claims?['personal'];
    }
    return null;
  }
}
