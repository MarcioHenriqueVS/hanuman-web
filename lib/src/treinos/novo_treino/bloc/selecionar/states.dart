import '../../../../exercicios/model/exercicio_model.dart';

class ExercicioSelectionState {
  List<ExercicioSelecionado> tempSelectedExercicios;
  List<ExercicioSelecionado> selectedExercicios;
  final bool showFab;

  ExercicioSelectionState(this.tempSelectedExercicios, this.selectedExercicios, this.showFab);
}
