import 'training_sheet.dart';

class TrainingProgram {
  final List<TrainingSheet>? trainingSheets;

  TrainingProgram({this.trainingSheets});

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      trainingSheets: (json['fichas_de_treinamento'] as List<dynamic>?)
          ?.map((e) => TrainingSheet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}