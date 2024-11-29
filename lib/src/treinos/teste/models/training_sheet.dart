import 'exercise_model.dart';

class TrainingSheet {
  final String? day;
  final List<Exercise>? exercises;
  final int? durationMinutes;
  final String? notes;
  bool? check = true;

  TrainingSheet(
      {this.day,
      this.exercises,
      this.durationMinutes,
      this.notes,
      this.check = true});

  factory TrainingSheet.fromJson(Map<String, dynamic> json) {
    return TrainingSheet(
      day: json['dia'] as String?,
      exercises: (json['exercicios'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationMinutes: json['duracao_minutos'] as int?,
      notes: json['notas'] as String?,
    );
  }
  // Método para converter TrainingSheet em JSON
  Map<String, dynamic> toJson() {
    return {
      'dia': day,
      'exercicios': exercises?.map((e) => e.toJson()).toList(),
      'duracao_minutos': durationMinutes,
      'notas': notes,
    };
  }
}