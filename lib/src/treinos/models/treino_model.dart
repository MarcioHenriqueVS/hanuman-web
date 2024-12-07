import 'package:intl/intl.dart';
import '../teste/models/exercise_model.dart';
import '../teste/models/ia_serie.dart';
import '../teste/models/repetition_model.dart';
import '../teste/models/training_sheet.dart';
import 'exercicio_treino_model.dart';
import 'serie_model.dart';

class Treino {
  final String? id;
  String titulo;
  List<ExercicioTreino> exercicios;
  String? timestamp;
  String? volume;
  String? series;
  String? duracao;
  String? nota;
  String? foto;
  bool? habilitado;

  Treino(
      {this.id,
      required this.titulo,
      required this.exercicios,
      this.timestamp,
      this.volume,
      this.series,
      this.duracao,
      this.nota,
      this.foto,
      this.habilitado});

  factory Treino.fromFirestore(Map<String, dynamic> dataMap, String id) {
    var exerciciosList = dataMap['Exercícios'] as List;

    bool habilitado = dataMap['habilitado'] ?? true;

    List<ExercicioTreino> exercicios = exerciciosList.map((e) {
      var seriesList = e['series'] as List;

      List<Serie> series = seriesList.map((s) {
        return Serie(
          reps: s['reps'] ?? 0,
          kg: s['kg'] ?? 0.0,
          tipo: s['tipo'] ?? 'Normal',
        );
      }).toList();

      Intervalo intervalo = Intervalo(
        valor: e['intervalo']['valor'] ?? 0,
        tipo: (e['intervalo']['tipo'] == "minutos")
            ? IntervaloTipo.minutos
            : IntervaloTipo.segundos,
      );

      return ExercicioTreino(
        id: e['id'] ?? '',
        newId: e['newId'] ?? '',
        nome: e['nome'] ?? '',
        grupoMuscular: e['grupoMuscular'] ?? '',
        agonista: List<String>.from(e['agonista'] ?? []),
        antagonista: List<String>.from(e['antagonista'] ?? []),
        sinergista: List<String>.from(e['sinergista'] ?? []),
        mecanismo: e['mecanismo'] ?? '',
        fotoUrl: e['fotoUrl'] ?? '',
        videoUrl: e['videoUrl'] ?? '',
        series: series,
        intervalo: intervalo,
        notas: e['notas'] ?? '',
      );
    }).toList();

    return Treino(
        id: id,
        titulo: dataMap['Titulo'] ?? '',
        exercicios: exercicios,
        habilitado: habilitado);
  }

  Map<String, dynamic> toMap() {
    return {
      'Titulo': titulo,
      'Exercicios': exercicios
          .map((e) => {
                'id': e.id,
                'nome': e.nome,
                'grupoMuscular': e.grupoMuscular,
                'agonista': e.agonista,
                'antagonista': e.antagonista,
                'sinergista': e.sinergista,
                'mecanismo': e.mecanismo,
                'fotoUrl': e.fotoUrl,
                'videoUrl': e.videoUrl,
                'series': e.series
                    .map((s) => {'reps': s.reps, 'kg': s.kg, 'tipo': s.tipo})
                    .toList(),
                'intervalo': {
                  'valor': e.intervalo.valor,
                  'tipo': e.intervalo.tipo == IntervaloTipo.minutos
                      ? "minutos"
                      : "segundos"
                },
                'notas': e.notas,
              })
          .toList(),
    };
  }

  Map<String, dynamic> toNewMap() {
    return {
      'titulo': titulo,
      'timestamp': timestamp,
      'volume': volume,
      'series': series,
      'duracao': duracao,
      'nota': nota,
      'foto': foto,
      'exercicios': exercicios
          .map((e) => {
                'id': e.id,
                'nome': e.nome,
                'grupoMuscular': e.grupoMuscular,
                'agonista': e.agonista,
                'antagonista': e.antagonista,
                'sinergista': e.sinergista,
                'mecanismo': e.mecanismo,
                'fotoUrl': e.fotoUrl,
                'videoUrl': e.videoUrl,
                'series': e.series
                    .map((s) => {
                          'reps': s.reps,
                          'kg': s.kg,
                          'tipo': s.tipo,
                          'check': s.check
                        })
                    .toList(),
                'intervalo': {
                  'valor': e.intervalo.valor,
                  'tipo': e.intervalo.tipo == IntervaloTipo.minutos
                      ? "minutos"
                      : "segundos"
                },
                'notas': e.notas,
              })
          .toList()
    };
  }

  TrainingSheet toTrainingSheet(Treino treino) {
    return TrainingSheet(
      day: treino.titulo ?? '', // Usar título como representação do dia
      exercises: treino.exercicios.map((exercicio) {
        return Exercise(
          name: exercicio.nome ??
              'Nome do Exercício', // Valor padrão se nome for nulo
          series: exercicio.series.map((serie) {
            return IASerie(
              repsDetails: serie.reps != null
                  ? List.generate(serie.reps!, (index) {
                      return Repetition(
                        weight:
                            serie.kg ?? 0, // Pega o peso ou usa 0 como padrão
                        note: '', // Nota padrão ou outro valor
                      );
                    })
                  : null, // Lista de repetições opcional
              tipo: serie.tipo ?? 'Normal', // Tipo da série com valor padrão
              reps: serie.reps, // Quantidade de repetições
            );
          }).toList(),
          nota: exercicio.notas ?? '', // Nota do exercício, valor opcional
          rest: exercicio.intervalo.valor, // Tempo de descanso
          //totalDeSeries: exercicio.series.length, // Total de séries
        );
      }).toList(),
      durationMinutes: treino.duracao != null
          ? int.tryParse(treino.duracao!)
          : 0, // Converte duração para int
      notes: treino.nota ?? '', // Notas da planilha de treino
    );
  }

  Treino copyWith({
    String? titulo,
    List<ExercicioTreino>? exercicios,
  }) {
    return Treino(
      titulo: titulo ?? this.titulo,
      exercicios: exercicios ?? this.exercicios,
    );
  }
}

class TreinoFinalizado {
  final String? id;
  String titulo;
  List<ExercicioTreino> exercicios;
  String? timestamp;
  String? volume;
  String? series;
  String? duracao;
  String? nota;
  String? foto;

  TreinoFinalizado(
      {this.id,
      required this.titulo,
      required this.exercicios,
      this.timestamp,
      this.volume,
      this.series,
      this.duracao,
      this.nota,
      this.foto});

  factory TreinoFinalizado.fromFirestore(Map<String, dynamic> dataMap) {
    final id = dataMap['id'];
    var exerciciosList = dataMap['treino'] as List;
    var duracao = dataMap['duracao'];
    var nota = dataMap['nota'];
    var seriesTotal = dataMap['series'];
    // Extraindo o timestamp do formato Firestore
    final seconds = dataMap['timestamp']['_seconds'];
    final nanoseconds = dataMap['timestamp']['_nanoseconds'];

    // Convertendo para DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000);

    // Formatando para String
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    var timestamp = formattedDate;
    var foto = dataMap['foto'];
    var volume = dataMap['volume'];

    List<ExercicioTreino> exercicios = exerciciosList.map((e) {
      var seriesList = e['series'] as List;

      List<Serie> series = seriesList.map((s) {
        return Serie(
            reps: s['reps'] ?? 0,
            kg: s['kg'] ?? 0.0,
            tipo: s['tipo'] ?? 'Normal',
            check: s['check'] ?? false);
      }).toList();

      Intervalo intervalo = Intervalo(
        valor: e['intervalo']['valor'] ?? 0,
        tipo: (e['intervalo']['tipo'] == "minutos")
            ? IntervaloTipo.minutos
            : IntervaloTipo.segundos,
      );

      return ExercicioTreino(
        id: e['id'] ?? '',
        newId: e['newId'] ?? '',
        nome: e['nome'] ?? '',
        grupoMuscular: e['grupoMuscular'] ?? '',
        agonista: List<String>.from(e['agonista'] ?? []),
        antagonista: List<String>.from(e['antagonista'] ?? []),
        sinergista: List<String>.from(e['sinergista'] ?? []),
        mecanismo: e['mecanismo'] ?? '',
        fotoUrl: e['fotoUrl'] ?? '',
        videoUrl: e['videoUrl'] ?? '',
        series: series,
        intervalo: intervalo,
        notas: e['notas'] ?? '',
      );
    }).toList();

    return TreinoFinalizado(
        id: id,
        titulo: dataMap['titulo'] ?? '',
        exercicios: exercicios,
        duracao: duracao,
        volume: volume,
        foto: foto,
        series: seriesTotal,
        nota: nota,
        timestamp: timestamp);
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'Titulo': titulo,
  //     '': exercicios
  //         .map((e) => {
  //               'id': e.id,
  //               'nome': e.nome,
  //               'grupoMuscular': e.grupoMuscular,
  //               'agonista': e.agonista,
  //               'antagonista': e.antagonista,
  //               'sinergista': e.sinergista,
  //               'mecanismo': e.mecanismo,
  //               'fotoUrl': e.fotoUrl,
  //               'videoUrl': e.videoUrl,
  //               'series': e.series
  //                   .map((s) => {'reps': s.reps, 'kg': s.kg, 'tipo': s.tipo})
  //                   .toList(),
  //               'intervalo': {
  //                 'valor': e.intervalo.valor,
  //                 'tipo': e.intervalo.tipo == IntervaloTipo.minutos
  //                     ? "minutos"
  //                     : "segundos"
  //               },
  //               'notas': e.notas,
  //             })
  //         .toList()
  //   };
  // }

  // Map<String, dynamic> toNewMap() {
  //   return {
  //     'titulo': titulo,
  //     'timestamp': timestamp,
  //     'volume': volume,
  //     'series': series,
  //     'duracao': duracao,
  //     'nota': nota,
  //     'foto': foto,
  //     'exercicios': exercicios
  //         .map((e) => {
  //               'id': e.id,
  //               'nome': e.nome,
  //               'grupoMuscular': e.grupoMuscular,
  //               'agonista': e.agonista,
  //               'antagonista': e.antagonista,
  //               'sinergista': e.sinergista,
  //               'mecanismo': e.mecanismo,
  //               'fotoUrl': e.fotoUrl,
  //               'videoUrl': e.videoUrl,
  //               'series': e.series
  //                   .map((s) => {
  //                         'reps': s.reps,
  //                         'kg': s.kg,
  //                         'tipo': s.tipo,
  //                         'check': s.check
  //                       })
  //                   .toList(),
  //               'intervalo': {
  //                 'valor': e.intervalo.valor,
  //                 'tipo': e.intervalo.tipo == IntervaloTipo.minutos
  //                     ? "minutos"
  //                     : "segundos"
  //               },
  //               'notas': e.notas,
  //             })
  //         .toList()
  //   };
  // }

  Treino copyWith({
    String? titulo,
    List<ExercicioTreino>? exercicios,
  }) {
    return Treino(
        titulo: titulo ?? this.titulo,
        exercicios: exercicios ?? this.exercicios);
  }
}
