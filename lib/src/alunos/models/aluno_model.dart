import 'package:intl/intl.dart';

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
  String? lastAtt;
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
      this.personalUid});

  factory AlunoModel.fromFirestore(Map<String, dynamic> dataMap) {
    var data = dataMap['data'] as Map<String, dynamic>;

    // Converter lastAtt de DateTime para String formatada
    String? formattedLastAtt;
    if (data['lastAtt'] is DateTime) {
      formattedLastAtt = DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR')
          .format(data['lastAtt'] as DateTime);
    } else if (data['lastAtt'] is String) {
      formattedLastAtt = data['lastAtt'];
    } else {
      formattedLastAtt =
          null; // Alterado para retornar null quando não houver data
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
        lastAtt: formattedLastAtt,
        personalUid: data['personalUid']);
  }

  factory AlunoModel.fromFirestoreNew(Map<String, dynamic> data) {
    // Converter lastAtt de DateTime para String formatada
    String? formattedLastAtt;
    if (data['lastAtt'] is DateTime) {
      formattedLastAtt = DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR')
          .format(data['lastAtt'] as DateTime);
    } else if (data['lastAtt'] is String) {
      formattedLastAtt = data['lastAtt'];
    } else {
      formattedLastAtt =
          null; // Alterado para retornar null quando não houver data
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
        lastAtt: formattedLastAtt,
        personalUid: data['personalUid']);
  }
}
