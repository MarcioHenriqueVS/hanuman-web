import 'package:cloud_firestore/cloud_firestore.dart';

class AlunoModel {
  final String uid;
  final String nome;
  final String sexo;
  final String? dataDeNascimento;
  final String email;
  final String? telefone;
  String? fotoUrl;
  final String? obs;
  final String? cpf;
  final String? frequencia;
  final String? objetivo;
  final String? foco;
  final String? nivel;
  bool? status;
  Timestamp? lastAtt;
  Timestamp? lastActivity;
  String? personalUid;

  AlunoModel(
      {required this.uid,
      required this.nome,
      required this.sexo,
      this.dataDeNascimento,
      required this.email,
      this.telefone,
      this.fotoUrl,
      this.obs,
      this.cpf,
      this.frequencia,
      this.objetivo,
      this.foco,
      this.nivel,
      this.status,
      this.lastAtt,
      this.lastActivity,
      this.personalUid});

  factory AlunoModel.fromFirestore(Map<String, dynamic> dataMap) {
    var data = dataMap['data'] as Map<String, dynamic>;

    // Converter lastAtt de Map para Timestamp
    Timestamp? lastAtt;
    if (data['lastAtt'] != null) {
      var lastAttMap = data['lastAtt'] as Map<String, dynamic>;
      lastAtt = Timestamp(
        lastAttMap['_seconds'] as int,
        lastAttMap['_nanoseconds'] as int,
      );
    }

    // Converter lastActivity de Map para Timestamp
    Timestamp? lastActivity;
    if (data['lastActivity'] != null) {
      var lastActivityMap = data['lastActivity'] as Map<String, dynamic>;
      lastActivity = Timestamp(
        lastActivityMap['_seconds'] as int,
        lastActivityMap['_nanoseconds'] as int,
      );
    }

    return AlunoModel(
      uid: data['alunoUid'],
      nome: data['nome'],
      sexo: data['sexo'],
      dataDeNascimento: data['dataDeNascimento'],
      email: data['email'],
      telefone: data['telefone'],
      fotoUrl: data['fotoUrl'],
      obs: data['obs'],
      cpf: data['cpf'],
      frequencia: data['frequencia'],
      objetivo: data['objetivo'],
      foco: data['foco'],
      nivel: data['nivel'],
      status: data['status'],
      lastAtt: lastAtt,
      lastActivity: lastActivity,
      personalUid: data['personalUid'],
    );
  }

  factory AlunoModel.fromFirestoreNew(Map<String, dynamic> data) {
    // Converter lastAtt de Map para Timestamp
    Timestamp? lastAtt;
    if (data['lastAtt'] != null) {
      if (data['lastAtt'] is Map) {
        var lastAttMap = data['lastAtt'] as Map<String, dynamic>;
        lastAtt = Timestamp(
          lastAttMap['_seconds'] as int,
          lastAttMap['_nanoseconds'] as int,
        );
      } else if (data['lastAtt'] is Timestamp) {
        lastAtt = data['lastAtt'] as Timestamp;
      }
    }

    // Converter lastActivity de Map para Timestamp
    Timestamp? lastActivity;
    if (data['lastActivity'] != null) {
      if (data['lastActivity'] is Map) {
        var lastActivityMap = data['lastActivity'] as Map<String, dynamic>;
        lastActivity = Timestamp(
          lastActivityMap['_seconds'] as int,
          lastActivityMap['_nanoseconds'] as int,
        );
      } else if (data['lastActivity'] is Timestamp) {
        lastActivity = data['lastActivity'] as Timestamp;
      }
    }

    return AlunoModel(
        uid: data['alunoUid'],
        nome: data['nome'],
        sexo: data['sexo'],
        dataDeNascimento: data['dataDeNascimento'],
        email: data['email'],
        telefone: data['telefone'],
        fotoUrl: data['fotoUrl'],
        obs: data['obs'],
        cpf: data['cpf'],
        frequencia: data['frequencia'],
        objetivo: data['objetivo'],
        foco: data['foco'],
        nivel: data['nivel'],
        status: data['status'],
        lastAtt: lastAtt,
        lastActivity: lastActivity,
        personalUid: data['personalUid']);
  }
}
