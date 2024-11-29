import 'repetition_model.dart';

class IASerie {
  List<Repetition>? repsDetails; // Lista de repetições
  String? tipo; // Tipo da série
  int? reps;

  IASerie({this.repsDetails, this.tipo, this.reps});

  factory IASerie.fromJson(Map<String, dynamic> json) {
    return IASerie(
      repsDetails: (json['reps'] as List<dynamic>?)
          ?.map(
              (repJson) => Repetition.fromJson(repJson as Map<String, dynamic>))
          .toList(),
      tipo: json['tipo'] as String?,
      reps: json['quantidade_reps'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': repsDetails?.map((rep) => rep.toJson()).toList(),
      'tipo': tipo,
      'quantidade_reps': reps,
    };
  }
}