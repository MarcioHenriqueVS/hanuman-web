import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/avaliacao_model.dart';
import '../../../database/database_helper.dart';

class AntropometriaServices {
  final uid = FirebaseAuth.instance.currentUser!.uid;

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
    return bytes;
  }

  Future<void> _saveAvaliacaoOffline(AvaliacaoModel avaliacao) async {
    try {
      if (avaliacao.titulo.isEmpty) {
        throw Exception('Título da avaliação não pode estar vazio');
      }

      await DatabaseHelper.instance.insertAvaliacaoOffline(uid, avaliacao);
      debugPrint(
          "Avaliação salva offline com sucesso - ID: ${avaliacao.titulo}");
    } catch (e) {
      debugPrint("Erro ao salvar avaliação offline: ${e.toString()}");
      throw Exception('Falha ao salvar avaliação offline: ${e.toString()}');
    }
  }

  Future<void> addAvaliacao(AvaliacaoModel avaliacao) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/addAvaliacaov2';

      // Validações básicas
      if (avaliacao.alunoUid.isEmpty) {
        throw Exception('ID do aluno inválido');
      }

      final response = await dio.post(
        url,
        data: {'uid': uid, 'avaliacao': avaliacao.toJson()},
        options: Options(
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao salvar avaliação: ${response.statusMessage}');
      }

      debugPrint("Avaliação salva com sucesso: ${response.data}");
    } on DioException catch (e) {
      debugPrint("Erro de conexão ao salvar avaliação: ${e.message}");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        await _saveAvaliacaoOffline(avaliacao);
        debugPrint("Avaliação salva offline após timeout");
      } else {
        await _saveAvaliacaoOffline(avaliacao);
        debugPrint("Avaliação salva offline após erro de conexão");
      }
    } catch (e) {
      debugPrint("Erro inesperado ao salvar avaliação: $e");
      await _saveAvaliacaoOffline(avaliacao);
    }
  }

  Future<void> deleteAvaliacao(
      String uid, String alunoUid, String avaliacaoId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/deleteAvaliacaov2';
      final response = await dio.post(url, data: {
        'personalUid': uid,
        'alunoUid': alunoUid,
        'avaliacaoId': avaliacaoId
      });
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

  Future<List<String>> getAvaliacoes(String uid, String alunoUid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getAvaliacoesv2';
      final response =
          await dio.post(url, data: {'uid': uid, 'alunoUid': alunoUid});
      debugPrint(response.data.toString());
      if (response.data != null) {
        List<dynamic> avaliacoesData = response.data as List<dynamic>;
        return avaliacoesData.map((data) {
          if (data is Map) {
            debugPrint(data['id']);
            return data['id'] as String;
          }
          throw Exception('Data format is not correct');
        }).toList();
      } else {
        debugPrint("Nenhuma pasta encontrado para o UID fornecido.");
        throw Exception('Nenhuma pasta encontrado para o UID fornecido.');
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
        rethrow;
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
        rethrow;
      }
    } on Exception catch (e) {
      debugPrint("General Exception: $e, ${e.toString()}");
      rethrow;
      //e.toString();
    }
  }

  Future<AvaliacaoModel?> getAvaliacao(
      String personalUid, String alunoUid, String avaliacaoId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getAvaliacaov2';

      final response = await dio.post(url, data: {
        'personalUid': personalUid,
        'alunoUid': alunoUid,
        'avaliacaoId': avaliacaoId,
      });
      debugPrint(response.data.toString());
      if (response.data != null && response.statusCode != 204) {
        final avaliacao = AvaliacaoModel.fromJson(response.data);
        debugPrint('timestamp -------> ${avaliacao.timestamp}');
        return avaliacao;
      } else {
        debugPrint("Nenhuma avaliacao encontrada.");
        //throw Exception('Pasta vazia');
        return null;
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
    //return null;
  }

  //funcao que retorna uma lista de AvaliacaoModel
  Future<List<AvaliacaoModel>?> getAvaliacoesData(
      String personalUid, String alunoUid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getAvaliacoesDatav2';

      final response = await dio.post(url, data: {
        'uid': personalUid,
        'alunoUid': alunoUid,
      });
      debugPrint(response.data.toString());
      if (response.data != null) {
        List<dynamic> avaliacoesData = response.data as List<dynamic>;
        if (avaliacoesData.isEmpty) {
          return null;
        }
        return avaliacoesData.map((data) {
          if (data is Map) {
            debugPrint(data['id']);
            return AvaliacaoModel.fromJson(
                data['avaliacao'] as Map<String, dynamic>);
          }
          throw Exception('Data format is not correct');
        }).toList();
      } else {
        debugPrint("Nenhuma pasta encontrado para o UID fornecido.");
        return null;
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
        rethrow;
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
        rethrow;
      }
    } on Exception catch (e) {
      debugPrint("General Exception: $e, ${e.toString()}");
      rethrow;
      //e.toString();
    }
  }

  Future<AvaliacaoModel?> getAvaliacaoMaisRecente(
      String personalUid, String alunoUid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getAvaliacaoMaisRecentev2';

      final response = await dio.post(url, data: {
        'uid': personalUid,
        'alunoUid': alunoUid,
      });
      debugPrint(response.data.toString());
      if (response.data != null && response.statusCode != 204) {
        final avaliacao = AvaliacaoModel.fromJson(response.data);
        debugPrint('timestamp -------> ${avaliacao.timestamp}');
        return avaliacao;
      } else {
        debugPrint("Nenhuma avaliacao encontrada.");
        //throw Exception('Pasta vazia');
        return null;
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
    //return null;
  }

  Future<void> sincronizarAvaliacoesOffline() async {
    try {
      final avaliacoesOffline =
          await DatabaseHelper.instance.getAvaliacoesOffline();

      if (avaliacoesOffline.isEmpty) {
        debugPrint('Nenhuma avaliação offline para sincronizar');
        return;
      }

      int sucessos = 0;
      int falhas = 0;
      List<String> erros = [];

      for (var avaliacaoOffline in avaliacoesOffline) {
        try {
          final avaliacaoString = avaliacaoOffline['avaliacao'] as String;
          final avaliacaoMap =
              jsonDecode(avaliacaoString) as Map<String, dynamic>;

          // Validação dos dados
          if (!_validarDadosAvaliacao(avaliacaoMap)) {
            throw Exception('Dados da avaliação inválidos ou incompletos');
          }

          final avaliacao = AvaliacaoModel(
            alunoUid: avaliacaoMap['alunoUid'],
            timestamp: avaliacaoMap['timestamp'],
            titulo: avaliacaoMap['titulo'],
            peso: avaliacaoMap['peso']?.toDouble(),
            altura: avaliacaoMap['altura']?.toDouble(),
            pantEsq: avaliacaoMap['pantEsq']?.toDouble(),
            pantDir: avaliacaoMap['pantDir']?.toDouble(),
            coxaEsq: avaliacaoMap['coxaEsq']?.toDouble(),
            coxaDir: avaliacaoMap['coxaDir']?.toDouble(),
            quadril: avaliacaoMap['quadril']?.toDouble(),
            cintura: avaliacaoMap['cintura']?.toDouble(),
            cintEscapular: avaliacaoMap['cintEscapular']?.toDouble(),
            torax: avaliacaoMap['torax']?.toDouble(),
            bracoEsq: avaliacaoMap['bracoEsq']?.toDouble(),
            bracoDir: avaliacaoMap['bracoDir']?.toDouble(),
            antebracoEsq: avaliacaoMap['antebracoEsq']?.toDouble(),
            antebracoDir: avaliacaoMap['antebracoDir']?.toDouble(),
            pantu: avaliacaoMap['pantu']?.toDouble(),
            coxa: avaliacaoMap['coxa']?.toDouble(),
            abdominal: avaliacaoMap['abdominal']?.toDouble(),
            supraespinal: avaliacaoMap['supraespinal']?.toDouble(),
            suprailiaca: avaliacaoMap['suprailiaca']?.toDouble(),
            toracica: avaliacaoMap['toracica']?.toDouble(),
            biciptal: avaliacaoMap['biciptal']?.toDouble(),
            triciptal: avaliacaoMap['triciptal']?.toDouble(),
            axilarMedia: avaliacaoMap['axilarMedia']?.toDouble(),
            subescapular: avaliacaoMap['subescapular']?.toDouble(),
            formula: avaliacaoMap['formula'],
            imc: avaliacaoMap['imc']?.toDouble(),
            classificacaoImc: avaliacaoMap['classificacaoImc'],
            bf: avaliacaoMap['bf']?.toDouble(),
            mm: avaliacaoMap['mm']?.toDouble(),
            mg: avaliacaoMap['mg']?.toDouble(),
            rce: avaliacaoMap['rce']?.toDouble(),
            classificacaoRce: avaliacaoMap['classificacaoRce'],
            fotos: List<String>.from(avaliacaoMap['fotos'] ?? []),
            obs: avaliacaoMap['obs'],
            sexo: avaliacaoMap['sexo'],
          );

          await addAvaliacao(avaliacao);
          await DatabaseHelper.instance
              .deleteAvaliacaoOffline(avaliacaoOffline['id'] as int);

          sucessos++;
          debugPrint(
              'Avaliação sincronizada com sucesso: ID ${avaliacaoOffline['id']}');
        } catch (e) {
          falhas++;
          erros.add('ID ${avaliacaoOffline['id']}: ${e.toString()}');
          debugPrint(
              'Erro ao sincronizar avaliação ${avaliacaoOffline['id']}: $e');
          continue;
        }
      }

      debugPrint('Sincronização completa: $sucessos sucessos, $falhas falhas');
      if (erros.isNotEmpty) {
        debugPrint('Erros durante a sincronização:\n${erros.join('\n')}');
      }
    } catch (e) {
      debugPrint('Erro durante a sincronização: $e');
      throw Exception('Falha na sincronização das avaliações: ${e.toString()}');
    }
  }

  bool _validarDadosAvaliacao(Map<String, dynamic> avaliacaoMap) {
    return avaliacaoMap['alunoUid'] != null &&
        avaliacaoMap['timestamp'] != null &&
        avaliacaoMap['titulo'] != null;
  }

  String classificarIMC(double imc) {
    if (imc < 18.5) {
      return 'Abaixo do peso';
    } else if (imc >= 18.5 && imc < 24.9) {
      return 'Eutrofia (Peso normal)';
    } else if (imc >= 25.0 && imc < 29.9) {
      return 'Sobrepeso';
    } else if (imc >= 30.0 && imc < 34.9) {
      return 'Obesidade Grau 1';
    } else if (imc >= 35.0 && imc < 39.9) {
      return 'Obesidade Grau 2';
    } else if (imc >= 40.0) {
      return 'Obesidade Grau 3';
    } else {
      return 'Valor de IMC inválido';
    }
  }

  String classificarRCE(double rce) {
    if (rce < 0) {
      return 'Valor de RCE inválido';
    } else if (rce < 0.5) {
      return 'Baixo risco';
    } else if (rce >= 0.5 && rce < 0.6) {
      return 'Risco aumentado';
    } else if (rce >= 0.6) {
      return 'Risco muito aumentado';
    } else {
      return 'Valor de RCE inválido';
    }
  }

  double calcularIMC(double peso, double altura) {
    double imc = peso / (altura * altura);
    return imc;
  }

  double calcularPesoIdeal(double altura) {
    double pesoIdeal = 22 * (altura * altura);
    return pesoIdeal;
  }

  double calcularRCE(double circunferenciaCintura, double altura) {
    double alturaEmCm = altura > 3 ? altura : altura * 100;
    double rce = circunferenciaCintura / alturaEmCm;
    return rce;
  }

  double calcularMassaGorda(double peso, double percentualGordura) {
    double massaGorda = peso * (percentualGordura / 100);
    return massaGorda;
  }

  double calcularMassaMagra(double peso, double percentualGordura) {
    double massaMagra = peso * (1 - (percentualGordura / 100));
    return massaMagra;
  }

  double calcularPercentualGorduraJacksonPollock7(
      double triceps,
      double subescapular,
      double peitoral,
      double axilarMedio,
      double supraIliaca,
      double abdominal,
      double coxa,
      int idade,
      bool isMale) {
    // Soma das 7 dobras cutâneas
    double somaDobras = triceps +
        subescapular +
        peitoral +
        axilarMedio +
        supraIliaca +
        abdominal +
        coxa;

    // Calcular a densidade corporal usando a fórmula de Jackson e Pollock 7 dobras
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.112 -
          (0.00043499 * somaDobras) +
          (0.00000055 * somaDobras * somaDobras) -
          (0.00028826 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.097 -
          (0.00046971 * somaDobras) +
          (0.00000056 * somaDobras * somaDobras) -
          (0.00012828 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    return percentualGordura;
  }

  double calcularPercentualGorduraJacksonPollock4(
      double triceps,
      double supraIliaca,
      double abdominal,
      double coxa,
      int idade,
      bool isMale) {
    // Soma das dobras cutâneas
    double somaDobras = triceps + supraIliaca + abdominal + coxa;

    // Calcular a densidade corporal usando a fórmula de Jackson e Pollock 4 dobras
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.112 -
          (0.00043499 * somaDobras) +
          (0.00000055 * somaDobras * somaDobras) -
          (0.00028826 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.096095 -
          (0.0006952 * somaDobras) +
          (0.0000011 * somaDobras * somaDobras) -
          (0.0000714 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    return percentualGordura;
  }

  double calcularPercentualGorduraJacksonPollock3(double triceps,
      double supraIliaca, double abdominal, int idade, bool isMale) {
    // Soma das dobras cutâneas
    double somaDobras = triceps + supraIliaca + abdominal;

    // Calcular a densidade corporal usando a fórmula de Jackson e Pollock 3 dobras
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.10938 -
          (0.0008267 * somaDobras) +
          (0.0000016 * somaDobras * somaDobras) -
          (0.0002574 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.0994921 -
          (0.0009929 * somaDobras) +
          (0.0000023 * somaDobras * somaDobras) -
          (0.0001392 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    return percentualGordura;
  }

  double calcularPercentualGorduraDurninWomersley(
      double triceps,
      double subescapular,
      double supraIliaca,
      double bicipital,
      int idade,
      bool isMale) {
    // Soma das dobras cutâneas
    double somaDobras = triceps + subescapular + supraIliaca + bicipital;

    // Calcular a densidade corporal usando a fórmula de Durnin-Womersley
    double densidadeCorporal;

    if (isMale) {
      // Fórmula para homens
      densidadeCorporal = 1.10938 -
          (0.0008267 * somaDobras) +
          (0.0000016 * somaDobras * somaDobras) -
          (0.0002574 * idade);
    } else {
      // Fórmula para mulheres
      densidadeCorporal = 1.0994921 -
          (0.0009929 * somaDobras) +
          (0.0000023 * somaDobras * somaDobras) -
          (0.0001392 * idade);
    }

    // Calcular o percentual de gordura corporal usando a densidade corporal
    double percentualGordura = (495 / densidadeCorporal) - 450;

    return percentualGordura;
  }
}
