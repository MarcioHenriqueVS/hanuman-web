import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../alunos/antropometria/models/avaliacao_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'avaliacoes_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE avaliacoes_offline(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT,
            avaliacao TEXT,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertAvaliacaoOffline(
      String uid, AvaliacaoModel avaliacao) async {
    final db = await database;
    await db.insert(
      'avaliacoes_offline',
      {
        'uid': uid,
        'avaliacao': jsonEncode(avaliacao.toJsonOffline()),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAvaliacoesOffline() async {
    final db = await database;
    return await db.query('avaliacoes_offline');
  }

  Future<void> deleteAvaliacaoOffline(int id) async {
    final db = await database;
    await db.delete(
      'avaliacoes_offline',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
