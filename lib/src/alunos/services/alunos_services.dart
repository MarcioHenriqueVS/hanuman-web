import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../autenticacao/tratamento/error_snackbar.dart';
import '../../autenticacao/tratamento/success_snackbar.dart';
import '../../perfil_user/foto/get_foto_bloc.dart';
import '../../perfil_user/foto/get_foto_events.dart';
import '../models/aluno_model.dart';

class AlunosServices {
  final MensagemDeSucesso _mensagemDeSucesso = MensagemDeSucesso();
  final TratamentoDeErros _tratamentoDeErros = TratamentoDeErros();

  Future<Map<String, dynamic>> addAluno(
      String uid,
      String nome,
      String dataDeNascimento,
      String telefone,
      String email,
      String senha,
      String obs,
      String sexo,
      String cpf,
      String frequencia,
      String objetivo,
      String foco,
      String nivel,
      {String? fotoUrl}) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/addAlunov2';

      DateTime timestamp = DateTime.now();

      String dataFormatada =
          DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(timestamp);

      final response = await dio.post(url, data: {
        'uid': uid,
        'nome': nome,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        'dataDeNascimento': dataDeNascimento,
        'telefone': telefone,
        'email': email,
        'senha': senha,
        'obs': obs,
        'sexo': sexo,
        'cpf': cpf,
        'frequencia': frequencia,
        'objetivo': objetivo,
        'foco': foco,
        'nivel': nivel,
        'lastAtt': dataFormatada,
        'status': 'Ativo'
      });
      debugPrint(response.data.toString());
      if (response.data != null) {
        return {'status': 200, 'message': response.data};
      } else {
        debugPrint("Erro ao tentar cadastrar aluno.");
        throw Exception('Erro ao tentar cadastrar aluno.');
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
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

  Future<void> deleteAluno(String alunoUid, String uid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/deleteAlunov2';
      final response = await dio.post(url, data: {
        'uid': uid,
        'alunoUid': alunoUid,
      });
      //debugPrint(response.data.toString());
      if (response.statusCode == 200) {
        //debugPrint('fotoUrl -----> ${response.data['fotoUrl']}');
        return response.data;
      } else {
        debugPrint("Erro ao tentar editar dados do aluno.");
        throw Exception('Erro ao tentar editar dados aluno.');
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
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

  Future<Map<String, dynamic>> editAluno(
    String uid,
    String alunoUid,
    {String? nome,
    String? dataDeNascimento,
    String? telefone,
    String? email,
    String? sexo,
    String? obs,
    String? cpf,
    String? frequencia,
    String? objetivo,
    String? foco,
    String? nivel,
    String? status,
    String? lastAtt,
    String? fotoUrl}) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/editAlunov2';
          
      Map<String, dynamic> data = {
        'uid': uid,
        'alunoUid': alunoUid,
      };

      // Adiciona apenas os campos que não são nulos
      if (nome != null) data['nome'] = nome;
      if (fotoUrl != null) data['fotoUrl'] = fotoUrl;
      if (dataDeNascimento != null) data['dataDeNascimento'] = dataDeNascimento;
      if (telefone != null) data['telefone'] = telefone;
      if (email != null) data['email'] = email;
      if (sexo != null) data['sexo'] = sexo;
      if (obs != null) data['obs'] = obs;
      if (cpf != null) data['cpf'] = cpf;
      if (frequencia != null) data['frequencia'] = frequencia;
      if (objetivo != null) data['objetivo'] = objetivo;
      if (foco != null) data['foco'] = foco;
      if (nivel != null) data['nivel'] = nivel;
      if (status != null) data['status'] = status;
      if (lastAtt != null) data['lastAtt'] = lastAtt;

      final response = await dio.post(url, data: data);

      if (response.statusCode == 200) {
        return response.statusCode == 200
            ? {'status': 200, 'message': response.data}
            : {'status': 400, 'message': response.data};
      } else {
        debugPrint("Erro ao tentar editar dados do aluno.");
        throw Exception('Erro ao tentar editar dados aluno.');
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
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

  Future<List<AlunoModel>> getAlunos(String uid, lastVisibleDocId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getAlunosv2';
      //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/getAlunos';
      final response = await dio.post(url,
          data: {'uid': uid, 'lastVisibleDocId': lastVisibleDocId, 'limit': 0});
      debugPrint('resposta ----------> ${response.data.toString()}');
      if (response.data != null) {
        List<dynamic> alunosData = response.data as List<dynamic>;
        return alunosData.map((data) {
          if (data is Map) {
            return AlunoModel.fromFirestore(data.cast<String, dynamic>());
          }
          throw Exception('Data format is not correct');
        }).toList();
      } else {
        debugPrint("Erro ao tentar cadastrar aluno.");
        throw Exception('Erro ao tentar cadastrar aluno.');
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
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

  Future<AlunoModel> getAluno(String personalUid, String alunoUid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getAlunov2';

      final response = await dio.post(url, data: {
        'uid': personalUid,
        'alunoUid': alunoUid,
      });
      debugPrint(response.data.toString());
      final data = response.data as Map<String, dynamic>;
      return AlunoModel.fromFirestoreNew(data);
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

  // update status do aluno
  Future<void> updateStatusAluno(String uid, String alunoUid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/alternarStatusAlunov2';
      final response = await dio.post(url, data: {
        'uid': uid,
        'alunoUid': alunoUid,
      });
      debugPrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint("Erro ao tentar editar dados do aluno.");
        throw Exception('Erro ao tentar editar dados aluno.');
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      rethrow;
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

  Map<String, dynamic> safeMapCast(Map<Object?, Object?>? data) {
    if (data == null) return {};

    return data.map(
      (key, value) => MapEntry(key as String, castValue(value)),
    );
  }

  dynamic castValue(dynamic value) {
    if (value is Map) {
      return safeMapCast(value);
    } else if (value is List) {
      return value.map((e) => castValue(e)).toList();
    }
    return value;
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

  Future<bool> updateUserPhoto(context, uid, foto) async {
    final userBloc = BlocProvider.of<UserFotoBloc>(context);
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('updateUserPhoto');
    try {
      await callable.call(<String, dynamic>{'uid': uid, 'foto': foto});
      _mensagemDeSucesso.showSuccessSnackbar(
          context, 'Foto alterada com sucesso');
      final newFoto = await getUserPhoto(uid);
      userBloc.add(UpdateUserFoto(newFoto));
      return true;
    } on FirebaseFunctionsException catch (e) {
      _tratamentoDeErros.showErrorSnackbar(
          context, 'Falha ao alterar a foto, tente novamente');
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

    debugPrint("File: $file");

    Uint8List? bytes = file.bytes;

    // Se os bytes estão null, tenta ler manualmente.
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

  Future<Uint8List?> selectImageBytes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return null;

    final PlatformFile file = result.files.first;

    Uint8List? bytes = file.bytes;

    if (bytes == null) {
      final filePath = file.path;
      if (filePath != null) {
        final file = File(filePath);
        bytes = await file.readAsBytes();
      }
    }

    debugPrint('File: $file');
    debugPrint('bytes ----------> ${bytes.toString()}');

    return bytes;
  }

  Future<String?> convertBytesToBase64(Uint8List bytes) async {
    final String base64Image = base64Encode(bytes);
    return base64Image;
  }
}
