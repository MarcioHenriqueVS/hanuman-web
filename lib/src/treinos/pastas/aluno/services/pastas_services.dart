import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PastasServices {
  Color getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  Future<void> addPasta(String uid, String alunoUid, String nomePasta, String cor) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/addPastav2';
      final response = await dio.post(url,
          data: {'uid': uid, 'alunoUid': alunoUid, 'nomePasta': nomePasta, 'cor': cor});
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

  Future<void> updatePasta(String uid, String alunoUid, String pastaId,
      {String? cor, String? nomePasta}) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/updatePastav2';
      final response = await dio.post(
        url,
        data: {
          'uid': uid,
          'alunoUid': alunoUid,
          'pastaId': pastaId,
          if (cor != null) 'cor': cor,
          if (nomePasta != null) 'nomePasta': nomePasta,
        },
      );
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

  Future<void> deletePasta(String uid, String alunoUid, String pastaId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/deletePasta';
      final response = await dio.post(url,
          data: {'uid': uid, 'alunoUid': alunoUid, 'pastaId': pastaId});
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

  Future<List<Map<String, dynamic>>> getPastas(String uid, String alunoUid) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getPastasv2';
      final response =
          await dio.post(url, data: {'uid': uid, 'alunoUid': alunoUid});
      debugPrint(response.data.toString());
      if (response.data != null) {
         List<dynamic> pastasData = response.data as List<dynamic>;
        return pastasData.map((data) {
          if (data is Map) {
            return {
              'id': data['id'],
              'nome': data['nome'],
              'cor': data['cor'],
              'qtdTreinos': int.parse(
                data['qtdTreinos'].toString(),
              ), // Converter para int
            };
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
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      rethrow;
      //e.toString();
    }
  }
}