import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AtualizacaoServices {
  Stream<List<Map<String, dynamic>>> atualizacoesStream() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('Personal')
        .doc(uid)
        .collection('atualizacoes')
        .limit(4)
        .snapshots()
        .map((snapshot) {
      // Zera a lista a cada nova consulta
      List<Map<String, dynamic>> atts = [];

      for (var doc in snapshot.docs) {
        atts.add({
          'id': doc.id, // Inclui o ID para identificação
          ...doc.data()
        });
      }

      // Ordena as atualizações pela chave 'timestamp', em ordem decrescente
      atts.sort((a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

      return atts;
    });
  }

  Future<List<Map<String, dynamic>>> buscarAtualizacoes() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final atts = await FirebaseFirestore.instance
        .collection('Personal')
        .doc(uid)
        .collection('atualizacoes')
        .orderBy('timestamp', descending: true)
        .limit(4)
        .get();

    return atts.docs.map((doc) => doc.data()).toList();
  }
}
