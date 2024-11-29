class Repetition {
  final int? weight; // Peso da repetição
  final String? note; // Nota da repetição

  Repetition({this.weight, this.note});

  factory Repetition.fromJson(Map<String, dynamic> json) {
    return Repetition(
      weight: json['peso'] as int?,
      note: json['nota'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peso': weight,
      'nota': note,
    };
  }
}