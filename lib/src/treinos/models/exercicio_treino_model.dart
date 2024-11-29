import '../../exercicios/model/exercicio_model.dart';
import 'serie_model.dart';

enum IntervaloTipo { segundos, minutos }

class Intervalo {
  final int valor;
  final IntervaloTipo tipo;

  Intervalo({required this.valor, required this.tipo});
}

class ExercicioTreino {
  String id;
  String newId;
  String nome;
  String grupoMuscular;
  List<String> agonista;
  List<String> antagonista;
  List<String> sinergista;
  String mecanismo;
  String fotoUrl;
  String videoUrl;
  List<Serie> series;
  Intervalo intervalo;
  String notas;

  ExercicioTreino({
    required this.id,
    required this.newId,
    required this.nome,
    required this.grupoMuscular,
    required this.agonista,
    required this.antagonista,
    required this.sinergista,
    required this.mecanismo,
    required this.fotoUrl,
    required this.videoUrl,
    required this.series,
    required this.intervalo,
    required this.notas,
  });

  factory ExercicioTreino.fromExercicio(ExercicioSelecionado exercicio,
      {String? notas, String? id}) {
    return ExercicioTreino(
      id: id ?? '',
      newId: exercicio.newId,
      nome: exercicio.nome,
      grupoMuscular: exercicio.grupoMuscular,
      agonista: exercicio.agonista,
      antagonista: exercicio.antagonista,
      sinergista: exercicio.sinergista,
      mecanismo: exercicio.mecanismo,
      fotoUrl: exercicio.fotoUrl,
      videoUrl: exercicio.videoUrl,
      series: [],
      intervalo: Intervalo(valor: 0, tipo: IntervaloTipo.segundos),
      notas: notas ?? '',
    );
  }
}
