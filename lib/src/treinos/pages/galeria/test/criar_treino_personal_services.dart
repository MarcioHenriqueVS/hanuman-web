import 'package:flutter/material.dart';
import '../../../../exercicios/model/exercicio_model.dart';
import '../../../models/exercicio_treino_model.dart';
import '../../../models/serie_model.dart';
import 'components/interval_picker.dart';

class CriarTreinoServices {
  List<String> getIntervalos() {
    List<String> intervalos = [];
    for (int i = 5; i <= 3 * 60 + 55; i += 5) {
      // De 5 em 5 segundos até 3 minutos e 55 segundos
      if (i < 60) {
        intervalos.add("$i seg");
      } else {
        final minutos = i ~/ 60;
        final segundos = i % 60;
        intervalos.add("$minutos:${segundos.toString().padLeft(2, '0')} min");
      }
    }
    for (int i = 4; i <= 7; i++) {
      // De 1 em 1 minuto de 4 até 7 minutos
      intervalos.add("$i:00 min");
    }
    return intervalos;
  }

  void addNewExercicio(List<TextEditingController> notasControllers) {
    notasControllers.add(TextEditingController());
  }

  List<Serie> getSeriesForExercicio(ExercicioSelecionado exercicio,
      Map<String, List<Serie>> exercicioSeriesMap) {
    // Obter a lista de séries para o id do exercício
    return exercicioSeriesMap[exercicio.newId] ?? [];
  }

  Intervalo getIntervalForExercicio(ExercicioSelecionado exercicio,
      Map<String, String?> exerciseIntervalMap) {
    // Obter o valor do intervalo como uma string
    String? intervalString = exerciseIntervalMap[exercicio.newId];
    if (intervalString == null) {
      return Intervalo(valor: 0, tipo: IntervaloTipo.segundos);
    }

    if (intervalString.contains("min")) {
      int? mins = int.tryParse(intervalString.split(" ")[0]);
      return Intervalo(valor: mins ?? 0, tipo: IntervaloTipo.minutos);
    } else {
      int? secs = int.tryParse(intervalString.split(" ")[0]);
      return Intervalo(valor: secs ?? 0, tipo: IntervaloTipo.segundos);
    }
  }

  void showIntervalPicker(BuildContext context, intervalos, nome,
      Map<String, String?> exerciseIntervalMap) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: IntervalPickerWidget(
            intervalos: intervalos,
            nome: nome,
            exerciseIntervalMap: exerciseIntervalMap,
          ),
        );
      },
    );
  }

  String verificarTipo(String tipo) {
    if (tipo.contains('segundos')) {
      return 'seg';
    } else {
      return 'min';
    }
  }
}
