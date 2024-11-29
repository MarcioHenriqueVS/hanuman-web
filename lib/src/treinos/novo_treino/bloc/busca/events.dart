abstract class ExercicioEvent {}

class UpdateSearchTerm extends ExercicioEvent {
  final String term;

  UpdateSearchTerm(this.term);
}

class FilterByMecanismo extends ExercicioEvent {
  final String mecanismo;

  FilterByMecanismo(this.mecanismo);
}

class FilterByGrupoMuscular extends ExercicioEvent {
  final String grupoMuscular;

  FilterByGrupoMuscular(this.grupoMuscular);
}

class ClearFilter extends ExercicioEvent {}

class ClearSpecificFilter extends ExercicioEvent {
  final String filterType; // 'mecanismo' or 'grupoMuscular'
  ClearSpecificFilter(this.filterType);
}
