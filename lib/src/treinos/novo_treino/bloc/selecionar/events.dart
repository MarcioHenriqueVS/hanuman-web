
import '../../../../exercicios/model/exercicio_model.dart';

abstract class ExercicioSelectionEvent {}

class ToggleExercicioSelection extends ExercicioSelectionEvent {
  final ExercicioSelecionado exercicio;

  ToggleExercicioSelection(this.exercicio);
}

class AddToTempList extends ExercicioSelectionEvent {
  final ExercicioSelecionado exercicio;

  AddToTempList(this.exercicio);
}

class ClearTempList extends ExercicioSelectionEvent {}

class ClearExercicioSelection extends ExercicioSelectionEvent {}

class ConfirmExercicioSelection extends ExercicioSelectionEvent {}

class RemoveExercicioSelection extends ExercicioSelectionEvent {
  final ExercicioSelecionado exercicio;
  RemoveExercicioSelection(this.exercicio);
}

class RemoveSingleExercicioSelection extends ExercicioSelectionEvent {
  final ExercicioSelecionado exercicio;
  RemoveSingleExercicioSelection(this.exercicio);
}
