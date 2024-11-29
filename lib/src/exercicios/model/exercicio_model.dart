

import '../../treinos/models/exercicio_treino_model.dart';
import '../../treinos/models/serie_model.dart';

class Exercicio {
  final String id;
  final String nome;
  final String grupoMuscular;
  final List<String> agonista;
  final List<String> antagonista;
  final List<String> sinergista;
  final String mecanismo;
  final String fotoUrl;
  final String videoUrl;
  final String? newId;

  Exercicio(
      {required this.id,
      required this.nome,
      required this.grupoMuscular,
      required this.agonista,
      required this.antagonista,
      required this.sinergista,
      required this.mecanismo,
      required this.fotoUrl,
      required this.videoUrl,
      this.newId});

  factory Exercicio.fromFirestore(Map<String, dynamic> dataMap, String id) {
    var data = dataMap['data'] as Map<String, dynamic>;

    return Exercicio(
        id: data['Id'],
        nome: data['Exercício'] ?? '',
        grupoMuscular: data['Grupo muscular'] ?? '',
        agonista: List<String>.from(data['Agonista'] ?? []),
        antagonista: List<String>.from(data['Antagonista'] ?? []),
        sinergista: List<String>.from(data['Sinergista'] ?? []),
        mecanismo: data['Mecanismo'] ?? '',
        fotoUrl: data['Foto url'] ?? '',
        videoUrl: data['Video url'] ?? '',
        newId: data['newId']);
  }
}

class ExercicioSelecionado {
  final String id;
  final String newId;
  final String nome;
  String? tipo;
  final String grupoMuscular;
  final List<String> agonista;
  final List<String> antagonista;
  final List<String> sinergista;
  final String mecanismo;
  final String fotoUrl;
  final String videoUrl;
  List<Serie>? series;
  Intervalo? intervalo;
  String? notas;

  ExercicioSelecionado(
      {required this.id,
      required this.newId,
      required this.nome,
      this.tipo,
      required this.grupoMuscular,
      required this.agonista,
      required this.antagonista,
      required this.sinergista,
      required this.mecanismo,
      required this.fotoUrl,
      required this.videoUrl,
      this.series,
      this.intervalo,
      this.notas});
}
