import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../tratamento/error_snackbar.dart';
import '../tratamento/success_snackbar.dart';
import 'log_services.dart';

class UserServices {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  LogServices logServices = LogServices();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<String?> registerUser(
      String name, String email, String password) async {
    if (!isEmailValid(email)) {
      return 'Por favor, insira um email válido.';
    }

    if (!isPasswordValid(password)) {
      return 'A senha deve conter no mínimo 6 caracteres.';
    }
    return await performRegistration(name, email, password);
  }

  Future<String> performRegistration(
      String name, String email, String password) async {
    String? token;
    if (kIsWeb) {
      token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BAab-Kx8H9rl5Lg_PNflviIKlOcENUwVfibdnWILYC45z06qp0e7-kH80Ln-vrq1LxrMZ_X-i_q-5WYiG5yIUjA');
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }

    debugPrint('token ----------> $token');

    var dio = Dio();
    String url =
        //'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/newCadastrov2';
        'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/newCadastrov2';

    try {
      final response = await dio.post(
        url,
        data: {'nome': name, 'email': email, 'senha': password, 'token': token},
      );

      debugPrint(response.data['message']);

      await Future.delayed(const Duration(seconds: 3));

      try {
        await logServices.login(email, password);
      } catch (e) {
        debugPrint('Erro ao fazer login: $e');
        return 'success';
      }
      return 'success';
    } on DioException catch (e) {
      debugPrint('Erro na requisição: ${e.message}');
      if (e.response != null) {
        debugPrint('Status: ${e.response?.statusCode}');
        debugPrint('Dados: ${e.response?.data}');
        return e.response?.data;
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      rethrow;
    }
  }

  Future<void> setPersonalClaim() async {
    try {
      var dio = Dio();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/setPersonalClaim';
      final response = await dio.post(url, data: {'uid': uid});
      debugPrint(response.data.toString());
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
      //e.message!;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'Erro no servidor: ${e.response!.statusCode}, ${e.response!.data}');
        rethrow;
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
        rethrow;
      }
    } on Exception catch (e) {
      debugPrint("General Exception: $e, ${e.toString()}");
      rethrow;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      rethrow;
      //e.toString();
    }
  }

  Future<String> getUserName(String uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getUserName');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint(result.data['message']);
      debugPrint(result.data['Nome']);
      return result.data['Nome'];
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      return 'Erro ao buscar nome';
    }
  }

  Future<String> getUserPhoto(String uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('getUserPhoto');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint(result.data['message']);
      return result.data['FotoUrl'];
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      return 'Erro ao buscar nome';
    }
  }

  Future<String?> getFCMtoken() async {
    try {
      final token = await messaging.getToken();
      return token;
    } catch (error) {
      debugPrint("Erro ao tentar obter o FCM token: $error");
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      return claims?['admin'] ?? false;
    }
    return false;
  }

  Future<bool> isPersonal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      debugPrint(claims?['personal']);
      return claims?['personal'] ?? false;
    }
    return false;
  }

  bool isEmailValid(String email) {
    return RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  Future<void> resetPassword(context, String email) async {
    try {
      if (isEmailValid(email)) {
        await firebaseAuth.sendPasswordResetEmail(email: email);
        // mensagemDeSucesso.showSuccessSnackbar(
        //     context, 'Email enviado com sucesso');
      } else {
        // tratamentoDeErros.showErrorSnackbar(
        //     context, 'Falha ao enviar email, tente novamente');
      }
    } catch (e) {
      debugPrint('Erro: $e');
      // tratamentoDeErros.showErrorSnackbar(
      //     context, 'Falha ao enviar email, tente novamente');
    }
  }

  Future<void> updateUserName(uid, nome) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/newUpdateUserName';

    try {
      final response = await dio.post(url, data: {
        'uid': uid,
        'nome': nome,
      });

      debugPrint(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      rethrow;
    }
  }

  Future<void> updateUserPhoto(uid, foto) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/newUpdateUserPhoto';

    try {
      final response = await dio.post(url, data: {
        'uid': uid,
        'foto': foto,
      });

      debugPrint(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      rethrow;
    }
  }

  Future<String?> selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null) return null;

    final PlatformFile file = result.files.first;

    debugPrint("File: $file");

    Uint8List? bytes = file.bytes;

    if (bytes == null) {
      debugPrint("File bytes is null, attempting to read manually.");

      try {
        final File imgFile = File(file.path!);
        bytes = await imgFile.readAsBytes();
      } catch (e) {
        debugPrint("Failed to read file bytes manually: $e");
        return null;
      }
    }

    final String base64Image = base64Encode(bytes);

    return base64Image;
  }

  Future<String?> pickImage() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (result == null) return null;

    final XFile file = result;

    // Uint8List bytes = await file.readAsBytes();

    //final String base64Image = base64Encode(bytes);

    return file.path;
  }

  Future<void> updateFcmToken(uid, token) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/updateFcmToken';

    try {
      final response = await dio.post(url, data: {
        'uid': uid,
        'token': token,
      });

      debugPrint(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      rethrow;
    }
  }

  Future<String?> getSavedFcmToken(String uid) async {
    const postUrl =
        "https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getFcmToken";

    Dio dio = Dio();

    try {
      Response response = await dio.post(
        postUrl,
        data: {
          'uid': uid,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('token buscado com sucesso');
        return response.data;
      } else {
        debugPrint('Falha ao buscar fcm token: ${response.data}');
        throw response.data;
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
      //e.message!;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'Erro no servidor: ${e.response!.statusCode}, ${e.response!.data}');
        if (e.response!.statusCode == 404) {
          return null;
        } else {
          rethrow;
        }
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
        rethrow;
      }
    } on Exception catch (e) {
      debugPrint("General Exception: $e, ${e.toString()}");
      rethrow;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      rethrow;
      //e.toString();
    }
    //return null;
  }

  String getFirstName() {
    final nome = firebaseAuth.currentUser!.displayName;

    // Verifica se o nome não é nulo e divide em partes
    if (nome != null && nome.isNotEmpty) {
      return nome.split(" ")[0]; // Retorna o primeiro nome
    }
    return ""; // Retorna uma string vazia se o nome for nulo ou vazio
  }
}
