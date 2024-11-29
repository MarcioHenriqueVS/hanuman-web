import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../../exercicios/model/exercicio_model.dart';
import '../../notificacoes/fcm.dart';
import '../models/exercicio_treino_model.dart';
import '../models/serie_model.dart';
import '../models/treino_model.dart';
import '../teste/models/exercise_model.dart';
import '../teste/models/ia_serie.dart';
import '../teste/models/training_program_model.dart';
import '../teste/models/training_sheet.dart';

class TreinoServices {
  final treinoData = {
    "Titulo": "Treino A - Quadríceps e Panturrilhas",
    "Exercícios": [
      {
        "id": "",
        "nome": "Agachamento Livre",
        "grupoMuscular": "",
        "agonista": [],
        "antagonista": [],
        "sinergista": [],
        "mecanismo": "",
        "fotoUrl": "",
        "videoUrl": "",
        "series": [
          {"reps": 6, "kg": 0, "tipo": "Normal"},
          {"reps": 8, "kg": 0, "tipo": "Dropset"}
        ],
        "intervalo": {"valor": 180, "tipo": "segundos"},
        "notas": ""
      },
      {
        "id": "",
        "nome": "Leg Press",
        "grupoMuscular": "",
        "agonista": [],
        "antagonista": [],
        "sinergista": [],
        "mecanismo": "",
        "fotoUrl": "",
        "videoUrl": "",
        "series": [
          {"reps": 10, "kg": 0, "tipo": "Normal"},
          {"reps": 12, "kg": 0, "tipo": "Normal"}
        ],
        "intervalo": {"valor": 120, "tipo": "segundos"},
        "notas": ""
      },
      {
        "id": "",
        "nome": "Extensão de Pernas",
        "grupoMuscular": "",
        "agonista": [],
        "antagonista": [],
        "sinergista": [],
        "mecanismo": "",
        "fotoUrl": "",
        "videoUrl": "",
        "series": [
          {"reps": 12, "kg": 0, "tipo": "Normal"},
          {"reps": 15, "kg": 0, "tipo": "Normal"}
        ],
        "intervalo": {"valor": 75, "tipo": "segundos"},
        "notas": ""
      },
      {
        "id": "",
        "nome": "Elevacão de Panturrilha no Leg Press",
        "grupoMuscular": "",
        "agonista": [],
        "antagonista": [],
        "sinergista": [],
        "mecanismo": "",
        "fotoUrl": "",
        "videoUrl": "",
        "series": [
          {"reps": 15, "kg": 0, "tipo": "Normal"},
          {"reps": 20, "kg": 0, "tipo": "Normal"}
        ],
        "intervalo": {"valor": 60, "tipo": "segundos"},
        "notas": ""
      }
    ]
  };

  final FirebaseMessagingService _firebaseMessagingServices =
      FirebaseMessagingService();

  // Future<bool> addTreino(uid, alunoUid, pastaId, Treino treino) async {
  //   debugPrint('-------------');
  //   debugPrint(pastaId);
  //   debugPrint('--------- aluno uid --------');
  //   debugPrint(alunoUid);
  //   debugPrint('--------- uid --------');
  //   debugPrint(uid);
  //   HttpsCallable callable =
  //       FirebaseFunctions.instanceFor(region: 'southamerica-east1')
  //           .httpsCallable('criarTreinov2');

  //   debugPrint('Iniciando conversão do Treino para Map');

  //   Map<String, dynamic> treinoMap = treino.toMap();

  //   DateTime timestamp = DateTime.now();

  //   String dataFormatada =
  //       DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(timestamp);

  //   try {
  //     final HttpsCallableResult result = await callable.call(
  //       <String, dynamic>{
  //         'uid': uid,
  //         'exercicios': treinoMap,
  //         'alunoUid': alunoUid,
  //         'pastaId': pastaId,
  //         'timestamp': dataFormatada
  //       },
  //     );

  //     if (result.data['success'] == true) {
  //       final treinoDocId = result.data['token'];
  //       _firebaseMessagingServices.enviarNotificacaoParaAluno(
  //           alunoUid,
  //           'Novo treino!',
  //           'Seu personal adicionou um novo treino, clique para ver', {
  //         'info': treinoDocId,
  //         'infoAdicional': pastaId,
  //         'infoAdicional2': uid,
  //         'tipo': 'novoTreino',
  //       });
  //     }

  //     debugPrint(result.data['message']);
  //     return true;
  //   } on FirebaseFunctionsException catch (e) {
  //     debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
  //     return false;
  //   }
  // }

  Future<bool> addTreino(
      String uid, String alunoUid, String pastaId, Treino treino) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/addTreinov2';

    Map<String, dynamic> treinoMap = treino.toMap();

    DateTime timestamp = DateTime.now();

    String dataFormatada =
        DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(timestamp);

    try {
      // Tenta salvar online primeiro
      final response = await dio.post(
        url,
        data: {
          'uid': uid,
          'alunoUid': alunoUid,
          'exercicios': treinoMap,
          'pastaId': pastaId,
          'timestamp': dataFormatada
        },
      );

      if (response.data['success'] == true) {
        final treinoDocId = response.data['token'];
        _firebaseMessagingServices.enviarNotificacaoParaAluno(
          alunoUid,
          'Novo treino!',
          'Seu personal adicionou um novo treino, clique para ver',
          {
            'info': treinoDocId,
            'infoAdicional': pastaId,
            'infoAdicional2': uid,
            'tipo': 'novoTreino',
          },
        );
      }

      return true;
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

  Future<void> deleteTreino(uid, alunoUid, pastaId, treinoId) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/deleteTreino';

    try {
      final response = await dio.post(url, data: {
        'uid': uid,
        'alunoUid': alunoUid,
        'pastaId': pastaId,
        'treinoId': treinoId
      });

      debugPrint(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      rethrow;
    }
  }

  Future<bool> editTreino(
      uid, alunoUid, pastaId, treinoId, Treino treino) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/editTreino';
    //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/newGetTreinos';

    Map<String, dynamic> treinoMap = treino.toMap();

    try {
      final response = await dio.post(url, data: {
        'uid': uid,
        'exercicios': treinoMap,
        'alunoUid': alunoUid,
        'pastaId': pastaId,
        'treinoId': treinoId
      });

      debugPrint(response.data);
      return true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      return false;
    }
  }

  Future<List<Treino>> getTreinos(
      String uid, String alunoUid, String pastaId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/newGetTreinosv2';
      //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/newGetTreinos';

      final response = await dio.post(url,
          data: {'uid': uid, 'alunoUid': alunoUid, 'pastaId': pastaId});
      debugPrint(response.data.toString());
      if (response.data != null && response.statusCode != 204) {
        List<dynamic> treinosData = response.data;
        if (treinosData.isNotEmpty) {
          return treinosData.map((data) {
            if (data is Map) {
              return Treino.fromFirestore(
                data.cast<String, dynamic>(),
                data['id'],
              );
            }
            throw Exception('Data format is not correct');
          }).toList();
        } else {
          return [];
        }
      } else {
        debugPrint("Nenhum treino encontrado na pasta.");
        //throw Exception('Pasta vazia');
        return [];
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

  Future<TreinoFinalizado?> getTreinoFinalizado(
      String personalUid, String alunoUid, String treinoId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getTreinoFinalizado';
      //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/newGetTreinos';

      final response = await dio.post(url, data: {
        'personalUid': personalUid,
        'alunoUid': alunoUid,
        'treinoId': treinoId
      });
      debugPrint(response.data.toString());
      dynamic treino;
      if (response.data != null && response.statusCode != 204) {
        dynamic treinoData = response.data;
        if (treinoData.isNotEmpty) {
          if (treinoData is Map) {
            treino = TreinoFinalizado.fromFirestore(
                treinoData.cast<String, dynamic>());
          }
          return treino;
        } else {
          return null;
        }
      } else {
        debugPrint("Nenhum treino encontrado na pasta.");
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

  Future<List<TreinoFinalizado>> getTreinosFinalizados(
      String uid, String alunoUid, String? lastVisibleDocId) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getTreinosFinalizados';

      final response = await dio.post(url, data: {
        'personalUid': uid,
        'alunoUid': alunoUid,
        "lastVisibleDocId": lastVisibleDocId,
        'limit': 10
      });
      debugPrint('data ------------> ${response.data.toString()}');
      if (response.data.toString() == '[]') {
        debugPrint('true');
        return [];
      } else {
        if (response.data != null && response.statusCode != 204) {
          List<dynamic>? treinosData = response.data['treinosFinalizados'];

          if (treinosData != null) {
            if (treinosData.isNotEmpty) {
              return treinosData.map((data) {
                if (data is Map) {
                  return TreinoFinalizado.fromFirestore(
                    data.cast<String, dynamic>(),
                  );
                }
                throw Exception('Data format is not correct');
              }).toList();
            } else {
              debugPrint('retornando lista vazia');
              return [];
            }
          } else {
            debugPrint(
                "Nenhum treino encontrado na pasta ou formato incorreto.");
            return [];
          }
        } else {
          debugPrint(response.statusMessage);
          throw Exception('Erro na requisição');
        }
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

  Future<void> addPasta(
      String uid, String alunoUid, String nomePasta, String cor) async {
    try {
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/addPastav2';
      final response = await dio.post(url, data: {
        'uid': uid,
        'alunoUid': alunoUid,
        'nomePasta': nomePasta,
        'cor': cor
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

  Future<List<Map<String, dynamic>>> getPastas(
      String uid, String alunoUid) async {
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

  final json = {
    "training_sheets": [
      {
        "day": "Segunda-feira",
        "exercises": [
          {"name": "Supino Reto", "sets": 4, "reps": 6, "rest_seconds": 90},
          {"name": "Press Militar", "sets": 3, "reps": 8, "rest_seconds": 90},
          {
            "name": "Desenvolvimento Lateral com Halteres",
            "sets": 3,
            "reps": 12,
            "rest_seconds": 60
          },
          {"name": "Tríceps Testa", "sets": 3, "reps": 10, "rest_seconds": 60},
          {"name": "Flexão de Braço", "sets": 3, "reps": 10, "rest_seconds": 60}
        ],
        "duration_minutes": 60,
        "notes":
            "Concentre-se na forma correta, principalmente nos movimentos compostos. Aqueça-se antes de começar."
      },
      {
        "day": "Terça-feira",
        "exercises": [
          {
            "name": "Agachamento Livre",
            "sets": 4,
            "reps": 6,
            "rest_seconds": 120
          },
          {"name": "Leg Press", "sets": 3, "reps": 10, "rest_seconds": 90},
          {
            "name": "Passada com Halteres",
            "sets": 3,
            "reps": 10,
            "rest_seconds": 90
          },
          {
            "name": "Panturrilha no Smith",
            "sets": 4,
            "reps": 12,
            "rest_seconds": 60
          },
          {
            "name": "Abdominais com Peso",
            "sets": 3,
            "reps": 15,
            "rest_seconds": 60
          }
        ],
        "duration_minutes": 60,
        "notes":
            "Enfatize o controle no movimento durante o agachamento para evitar lesões."
      },
      {
        "day": "Quinta-feira",
        "exercises": [
          {"name": "Barra Fixa", "sets": 4, "reps": 6, "rest_seconds": 120},
          {"name": "Remada Curvada", "sets": 3, "reps": 8, "rest_seconds": 90},
          {
            "name": "Pulldown na Polia Alta",
            "sets": 3,
            "reps": 10,
            "rest_seconds": 90
          },
          {"name": "Rosca Direta", "sets": 3, "reps": 10, "rest_seconds": 60},
          {"name": "Rosca Martelo", "sets": 3, "reps": 12, "rest_seconds": 60}
        ],
        "duration_minutes": 60,
        "notes":
            "Foque na ativação muscular durante a barra fixa, usando assistências se necessário."
      },
      {
        "day": "Sexta-feira",
        "exercises": [
          {
            "name": "Levantamento Terra",
            "sets": 4,
            "reps": 6,
            "rest_seconds": 150
          },
          {"name": "Leg Stiff", "sets": 3, "reps": 8, "rest_seconds": 90},
          {
            "name": "Glúteo na Máquina",
            "sets": 3,
            "reps": 10,
            "rest_seconds": 90
          },
          {
            "name": "Abdução de Quadril",
            "sets": 3,
            "reps": 12,
            "rest_seconds": 60
          },
          {
            "name": "Prancha Isométrica",
            "sets": 3,
            "reps": 30,
            "rest_seconds": 60
          }
        ],
        "duration_minutes": 60,
        "notes":
            "Certifique-se de manter uma postura adequada durante o levantamento terra para proteger suas costas."
      }
    ]
  };

  List<ExercicioSelecionado> transformarTrainingProgram(TrainingSheet sheet) {
    List<ExercicioSelecionado> exerciciosSelecionados = [];

    // Itera sobre os dias de treino
    for (var exercise in sheet.exercises!) {
      // Cria um novo ExercicioSelecionado a partir de cada exercício
      ExercicioSelecionado exercicioSelecionado = ExercicioSelecionado(
        id: generateUniqueId(), // Você pode usar uma função para gerar um ID único
        newId: generateUniqueId(),
        nome: exercise.name ?? 'Nome', // Nome do exercício, ou um valor padrão
        notas: exercise.nota ?? '',
        //tipo: exercise.series. ?? 'Normal',
        grupoMuscular: '', // Pode ser definido com um valor padrão
        agonista: [], // Pode ser uma lista vazia ou com valores padrão
        antagonista: [], // Pode ser uma lista vazia ou com valores padrão
        sinergista: [], // Pode ser uma lista vazia ou com valores padrão
        mecanismo: '', // Pode ser um valor padrão
        fotoUrl: '', // Pode ser uma URL vazia ou uma URL padrão
        videoUrl: '', // Pode ser uma URL vazia ou uma URL padrão
        series: _converterParaSeries(exercise), // Converte as séries
        intervalo: Intervalo(
            valor: exercise.rest!,
            tipo: IntervaloTipo.segundos // Exemplo de intervalo padrão
            ),
      );
      exerciciosSelecionados.add(exercicioSelecionado);
    }
    return exerciciosSelecionados;
  }

// Função para converter os dados das séries
  List<Serie> _converterParaSeries(Exercise exercise) {
    List<IASerie> series =
        exercise.series ?? []; // Lista de séries do exercício
    // int totalDeSeries = exercise.totalDeSeries ?? 0; // Pega o total de séries
    // debugPrint('total de series ------> ${totalDeSeries.toString()}');

    // Lista que vai acumular todas as séries
    List<Serie> seriesList = [];

    // Para cada IASerie, gerar o número total de Séries
    for (var iaserie in series) {
      // Pega a quantidade de repetições para esta série
      int quantidadeReps = iaserie.reps ?? 0;

      // Adiciona a quantidade de séries conforme o valor de totalDeSeries
      //for (int i = 0; i < totalDeSeries; i++) {
      seriesList.add(Serie(
        reps: quantidadeReps, // Define o número de repetições
        kg: iaserie.repsDetails?.isNotEmpty == true
            ? iaserie.repsDetails![0].weight ?? 0
            : 0, // Usa o peso da primeira repetição ou 0
        tipo: iaserie.tipo ?? '', // Usa o tipo da IASerie
        check: false, // Defina conforme necessário
      ));
      //}
    }

    debugPrint('series list lenght ------> ${seriesList.length.toString()}');

    return seriesList; // Retorna a lista completa de séries
  }

// Exemplo de função para gerar IDs únicos
  String generateUniqueId() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Future<TrainingProgram?> getTreinoIA(
      String dias,
      String nivel,
      String objetivo,
      String foco,
      List<String> grupamentosMusculares,
      String? sexo) async {
    try {
      String grupamentosMuscularesString = grupamentosMusculares.join(', ');
      debugPrint(grupamentosMuscularesString);
      var dio = Dio();
      String url =
          'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getTrainingPlan7';
      //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/getTrainingPlan';

      final response = await dio.post(
        url,
        data: {
          'nivel': nivel,
          'dias': dias,
          'objetivo': objetivo,
          'foco': foco,
          'grupamentosAlvos': grupamentosMusculares,
          'sexo': sexo,
        },
      );

      // if (response.data != null && response.statusCode == 200) {
      //   debugPrint(response.data);
      //   if (response.data is String) {
      //     final decodedData = jsonDecode(response.data);
      //     return TrainingProgram.fromJson(decodedData);
      //   } else if (response.data is Map<String, dynamic>) {
      //     // Caso a resposta já seja um Map
      //     return TrainingProgram.fromJson(response.data);
      //   } else {
      //     debugPrint("Resposta inesperada: ${response.data}");
      //     throw Exception("Resposta inesperada: ${response.data}");
      //   }
      // }

      // // Caso o retorno seja um Map, processa diretamente
      if (response.data is Map<String, dynamic>) {
        return TrainingProgram.fromJson(response.data);
      }
      // // Caso o retorno seja uma lista, ajusta o processamento (se necessário)
      // else if (response.data is List) {
      //   // Adaptar conforme a estrutura da lista recebida
      //   // Exemplo: você pode precisar converter a lista de volta para um `TrainingProgram`
      //   // Dependendo da estrutura do seu `TrainingProgram`
      //   final mapData = {
      //     'treinos': response.data, // Exemplo: nome do campo 'treinos' no JSON
      //   };
      //return TrainingProgram.fromJson(response.data);

      //}
      else {
        debugPrint("Resposta inesperada: ${response.data}");
        throw Exception("Resposta inesperada: ${response.data}");
      }

      //return TrainingProgram.fromJson(json);
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'Erro no servidor: ${e.response!.statusCode}, ${e.response!.data}');
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
      }
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      if (e.details != null) {
        debugPrint("Detalhes do erro: ${e.details}");
      }
      rethrow;
    } catch (e, s) {
      debugPrint("Erro desconhecido: $e");
      debugPrint("Stack trace: $s");
      rethrow;
    }
  }

  Treino trainingSheetToTreino(TrainingSheet trainingSheet) {
    // Mapear os exercícios do TrainingSheet para ExercicioTreino
    List<ExercicioTreino> exerciciosTreino =
        trainingSheet.exercises?.map((exercise) {
              // Aqui estamos gerando as séries, utilizando a lista de IASerie
              List<IASerie> series =
                  exercise.series ?? []; // Lista de IASerie do exercício

              // Mapeia cada IASerie para a classe Serie
              List<Serie> serieList = series.map((iaserie) {
                return Serie(
                  reps: iaserie.reps ?? 0, // Número de repetições na série
                  kg: iaserie.repsDetails?.isNotEmpty == true
                      ? iaserie.repsDetails![0].weight ?? 0
                      : 0, // Pega o peso da primeira repetição ou 0
                  tipo: iaserie.tipo ??
                      'Normal', // Tipo da série, ajuste conforme necessário
                  check: false, // Ajustar conforme necessário
                );
              }).toList();

              return ExercicioTreino(
                id: '', // Adicionar id adequado se necessário
                newId: '', // Adicionar newId adequado se necessário
                nome: exercise.name ?? '',
                grupoMuscular:
                    '', // Grupo muscular não fornecido, ajustar conforme necessário
                agonista: [], // Ajustar conforme necessário
                antagonista: [], // Ajustar conforme necessário
                sinergista: [], // Ajustar conforme necessário
                mecanismo: '', // Ajustar conforme necessário
                fotoUrl: '', // Ajustar conforme necessário
                videoUrl: '', // Ajustar conforme necessário
                series: serieList, // Usar a lista de Series gerada
                intervalo: Intervalo(
                    valor: exercise.rest!, tipo: IntervaloTipo.segundos),
                notas: '', // Notas não fornecidas no exercício
              );
            }).toList() ??
            [];

    return Treino(
      id: const UuidV4().generate(),
      titulo: trainingSheet.day ?? 'Treino Sem Título',
      exercicios: exerciciosTreino,
      duracao: trainingSheet.durationMinutes?.toString(),
      nota: trainingSheet.notes,
    );
  }

  ExercicioSelecionado transformExerciseToExercicioSelecionado(
      Exercise exercise) {
    // Gera um ID único para o newId
    String newId = UniqueKey().toString();

    // Transforma as séries do exercício em uma lista de objetos Serie
    List<Serie> seriesList = [];
    if (exercise.series != null) {
      for (var iaserie in exercise.series!) {
        // Para cada IASerie, cria um objeto Serie
        // Pega o peso da primeira repetição ou 0 se não houver
        int peso = iaserie.repsDetails?.isNotEmpty == true
            ? iaserie.repsDetails!.first.weight ?? 0
            : 0;

        // Adiciona a série com base na quantidade de reps
        if (iaserie.reps != null && iaserie.reps! > 0) {
          for (int i = 0; i < iaserie.reps!; i++) {
            seriesList.add(Serie(
              reps: peso, // Pega o peso da repetição ou 0 se não houver
              kg: peso, // Você pode ajustar esse valor conforme necessário
              tipo: iaserie.tipo ?? 'Normal', // Usa o tipo da IASerie
            ));
          }
        }
      }
    }

    // Cria o intervalo com base no rest (descanso)
    Intervalo intervalo = Intervalo(
      valor: exercise.rest ??
          60, // Usa o descanso do exercício, com 60 como padrão
      tipo: IntervaloTipo.segundos,
    );

    // Retorna o objeto ExercicioSelecionado
    return ExercicioSelecionado(
      id: const UuidV4().generate(), // Coloque o ID real, se houver
      newId: newId,
      nome: exercise.name ?? 'Nome',
      tipo: exercise
          .nota, // A propriedade tipo não estava no Exercise, ajuste conforme necessário
      grupoMuscular: '', // Defina um valor padrão ou extraia de outro lugar
      agonista: [''], // Defina um valor padrão ou extraia de outro lugar
      antagonista: [''], // Defina um valor padrão ou extraia de outro lugar
      sinergista: [''], // Defina um valor padrão ou extraia de outro lugar
      mecanismo: '', // Defina um valor padrão ou extraia de outro lugar
      fotoUrl: 'https://example.com/foto.jpg', // Defina a URL real da foto
      videoUrl: 'https://example.com/video.mp4', // Defina a URL real do vídeo
      series: seriesList.isNotEmpty ? seriesList : null,
      intervalo: intervalo,
      notas: exercise.nota,
    );
  }

  Future<bool> editTreinoMessage(
      String uid, String messageId, int index, TrainingSheet treino) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/editMessage';

    // debugPrint('----------- TrainingSheet ---------');
    // debugPrintTrainingSheet(treino);
    // debugPrint('----------- TrainingSheet ---------');

    Map<String, dynamic> treinoMap = treino.toJson();

    // Imprimindo a quantidade de séries em cada exercício
    if (treino.exercises != null) {
      for (var exercise in treino.exercises!) {
        if (exercise.series != null) {
          int seriesCount = exercise.series!.length;
          debugPrint('Exercício: ${exercise.name}, Séries: $seriesCount');
        }
      }
    }

    try {
      debugPrint('----------- treinoMap ---------');
      debugPrintTreinoMap(treinoMap);
      debugPrint('----------- treinoMap ---------');
      debugPrint(messageId);
      debugPrint(index.toString());
      final response = await dio.post(url, data: {
        'uid': uid,
        'id': messageId,
        'index': index,
        'novoDiaDeTreino': treinoMap,
      });

      debugPrint(response.data);
      //FirebaseFirestore.instance.collection('treinoteste').doc().set(treinoMap);
      return true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      return false;
    }
  }

  void debugPrintTreinoMap(Map<String, dynamic> treinoMap) {
    final jsonString = jsonEncode(treinoMap);
    debugPrint(jsonString,
        wrapWidth:
            1024); // wrapWidth aumenta o limite da linha para evitar truncagem
  }

  void debugPrintTrainingSheet(TrainingSheet trainingSheet) {
    final jsonString = jsonEncode(trainingSheet.toJson());
    debugPrint(jsonString, wrapWidth: 1024); // wrapWidth para evitar truncagem
  }
}
