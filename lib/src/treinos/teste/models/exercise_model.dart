import 'ia_serie.dart';

class Exercise {
  final String? name; // Nome do exercício
  final List<IASerie>? series; // Lista de séries
  final String? nota; // Nota do exercício
  final int? rest;
  //final int? totalDeSeries;

  Exercise({
    this.name,
    this.series,
    this.nota,
    this.rest,
    //this.totalDeSeries
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['nome'] as String?,
      series: (json['seriesDetalhadas'] as List<dynamic>?)
          ?.map((serieJson) =>
              IASerie.fromJson(serieJson as Map<String, dynamic>))
          .toList(), // Converte a lista de JSON para a lista de Serie
      nota: json['nota_sobre_exercicio'] as String?,
      rest: json['descanso_segundos'],
      //totalDeSeries: json['total_de_series']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': name,
      'seriesDetalhadas': series?.map((serie) => serie.toJson()).toList(),
      'nota_sobre_exercicio': nota,
      'descanso_segundos': rest,
      //'total_de_series': totalDeSeries,
    };
  }
}