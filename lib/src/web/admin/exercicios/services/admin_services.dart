import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../../autenticacao/tratamento/success_snackbar.dart';

class AdminServices {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  Future<bool> criarExercicio(
    String nomeDoExercicio,
    String grupoMuscular,
    String mecanismo,
    List<String> agonistas,
    List<String> antagonistas,
    List<String> sinergistas,
    String? fotoUrl,
    String? videoUrl,
  ) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('criarExercicio');
    try {
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'nome': nomeDoExercicio,
        'grupoMuscular': grupoMuscular,
        'agonista': agonistas,
        'antagonista': antagonistas,
        'sinergista': sinergistas,
        'mecanismo': mecanismo,
        'fotoUrl': fotoUrl,
        'videoUrl': videoUrl,
      });
      debugPrint(result.data['message']);
      return true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      return false;
    }
  }

  Future<String?> selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null) return null;

    final PlatformFile file = result.files.first;

    final Uint8List bytes = file.bytes!;
    final String base64Image = base64Encode(bytes);

    return base64Image;
  }

  Future<String?> selectVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null) return null;

    final PlatformFile file = result.files.first;

    final Uint8List bytes = file.bytes!;
    final String base64Video = base64Encode(bytes);

    return base64Video;
  }
}
