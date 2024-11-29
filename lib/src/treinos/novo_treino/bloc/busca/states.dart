
import '../../../../exercicios/model/exercicio_model.dart';

class CurrentFilter {
  String? mecanismo;
  String? grupoMuscular;

  CurrentFilter({this.mecanismo, this.grupoMuscular});
}

class ExercicioFilterState {
  final List<Exercicio> filteredExercicios;
  final CurrentFilter currentFilter;

  ExercicioFilterState(this.filteredExercicios, this.currentFilter);
}

