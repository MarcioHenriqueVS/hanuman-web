import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/treino_model.dart';

class TreinosPersonalServices {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'treinos_offline.db'),
      onCreate: (db, version) async {
        // Criar tabela de treinos
        await db.execute('''
          CREATE TABLE treinos(
            id TEXT PRIMARY KEY,
            pastaId TEXT,
            titulo TEXT,
            dados TEXT,
            timestamp TEXT,
            sincronizado INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  Future<bool> saveTreinoOffline(String pastaId, Treino treino) async {
    try {
      final db = await database;
      String treinoJson = jsonEncode(treino.toMap());

      await db.insert(
        'treinos',
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'pastaId': pastaId,
          'titulo': treino.titulo,
          'dados': treinoJson,
          'timestamp': DateTime.now().toIso8601String(),
          'sincronizado': 0
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar treino offline: $e');
      return false;
    }
  }

  Future<List<Treino>> getTreinosOffline(String pastaId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'treinos',
        where: 'pastaId = ?',
        whereArgs: [pastaId],
      );

      return maps.map((map) {
        Map<String, dynamic> treinoData = jsonDecode(map['dados']);
        return Treino.fromFirestore(treinoData, map['id']);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao recuperar treinos offline: $e');
      return [];
    }
  }

  Future<bool> sincronizarTreinosOffline() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> treinosNaoSincronizados = await db.query(
        'treinos',
        where: 'sincronizado = ?',
        whereArgs: [0],
      );

      for (var treinoMap in treinosNaoSincronizados) {
        try {
          // Decodifica os dados do treino
          Map<String, dynamic> treinoData = jsonDecode(treinoMap['dados']);

          // Ajusta o formato dos dados para corresponder ao esperado pelo fromFirestore
          Map<String, dynamic> formattedData = {
            'Titulo': treinoData['Titulo'],
            'Exercícios': treinoData['Exercicios'], // Note a mudança na chave
            'id': treinoMap['id']
          };

          Treino treino = Treino.fromFirestore(formattedData, treinoMap['id']);

          bool sucesso = await addTreinoCriado(
            uid,
            treinoMap['pastaId'],
            treino,
          );

          if (sucesso) {
            await db.update(
              'treinos',
              {'sincronizado': 1},
              where: 'id = ?',
              whereArgs: [treinoMap['id']],
            );
          }
        } catch (e) {
          debugPrint('Erro ao sincronizar treino específico: $e');
          continue; // Continua com o próximo treino mesmo se este falhar
        }
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao sincronizar treinos: $e');
      return false;
    }
  }

  Future<void> deleteTreinoOffline(String id) async {
    try {
      final db = await database;
      await db.delete(
        'treinos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erro ao deletar treino offline: $e');
    }
  }

  Future<bool> addTreinoCriado(
      String uid, String pastaId, Treino treino) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/addTreinoPersonalv2';

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
          'exercicios': treinoMap,
          'pastaId': pastaId,
          'timestamp': dataFormatada,
        },
      );

      debugPrint(response.data);
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar online: $e');
      // Se falhar ao salvar online, tenta salvar offline
      try {
        bool savedOffline = await saveTreinoOffline(pastaId, treino);
        if (savedOffline) {
          debugPrint('Treino salvo offline com sucesso');
          // Você pode querer mostrar uma mensagem para o usuário informando que o treino foi salvo offline
          return true;
        } else {
          debugPrint('Falha ao salvar treino offline');
          return false;
        }
      } catch (offlineError) {
        debugPrint('Erro ao salvar offline: $offlineError');
        return false;
      }
    }
  }

  Future<bool> verificarESincronizar() async {
    try {
      // Tenta sincronizar os treinos offline
      bool sincronizado = await sincronizarTreinosOffline();
      if (sincronizado) {
        debugPrint('Treinos sincronizados com sucesso');
        return true;
      } else {
        debugPrint('Falha ao sincronizar treinos');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar: $e');
      return false;
    }
  }

  Future<void> deleteTreinoCriado(uid, pastaId, treinoId) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/deleteTreinoPersonalv2';

    try {
      final response = await dio.post(url,
          data: {'uid': uid, 'pastaId': pastaId, 'treinoId': treinoId});

      debugPrint(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro na requisicao: ${e.code}\n${e.message}');
      rethrow;
    }
  }

  Future<bool> editTreinoCriado(uid, pastaId, treinoId, Treino treino) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/editTreinoPersonalv2';
    //'http://127.0.0.1:5001/hanuman-4e9f4/southamerica-east1/newGetTreinos';

    Map<String, dynamic> treinoMap = treino.toMap();

    try {
      final response = await dio.post(url, data: {
        'uid': uid,
        'exercicios': treinoMap,
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

  Future<List<Treino>> getTreinosCriados(String uid, String pastaId) async {
    var dio = Dio();
    String url =
        'https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/getTreinosPersonalv2';

    try {
      final response =
          await dio.post(url, data: {'uid': uid, 'pastaId': pastaId});

      if (response.data != null) {
        if (response.data is String) {
          return [];
        }
        List<dynamic> treinosData = response.data;
        List<Treino> treinosOnline = [];

        if (treinosData.isNotEmpty) {
          treinosOnline = treinosData.map((data) {
            if (data is Map) {
              return Treino.fromFirestore(
                data.cast<String, dynamic>(),
                data['id'],
              );
            }
            throw Exception('Formato de dados incorreto');
          }).toList();
        }
        return [...treinosOnline];
      } else {
        return [];
      }
    } on DioException catch (e) {
      debugPrint('Erro na requisição: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Erro desconhecido: $e');
      rethrow;
    }
  }
  // Adicione outras funções relacionadas a treinos aqui
}
