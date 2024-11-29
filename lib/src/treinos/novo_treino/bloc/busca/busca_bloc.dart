import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../exercicios/model/exercicio_model.dart';
import 'events.dart';
import 'states.dart';

class BuscarExercicioBloc extends Bloc<ExercicioEvent, ExercicioFilterState> {
  final List<Exercicio> allExercicios;
  final _currentFilter = CurrentFilter();

  BuscarExercicioBloc(this.allExercicios)
      : super(ExercicioFilterState(allExercicios, CurrentFilter())) {
    on<UpdateSearchTerm>(_mapUpdateSearchTermToState);
    on<FilterByMecanismo>(_mapFilterByMecanismoToState);
    on<FilterByGrupoMuscular>(_mapFilterByGrupoMuscularToState);
    on<ClearFilter>(_mapClearFilterToState);
    on<ClearSpecificFilter>(_mapClearSpecificFilterToState);
  }

  void _mapUpdateSearchTermToState(
      UpdateSearchTerm event, Emitter<ExercicioFilterState> emit) {
    final term = event.term.toLowerCase();
    final filtered = allExercicios.where((exercicio) {
      return exercicio.nome.toLowerCase().contains(term) ||
          exercicio.grupoMuscular.toLowerCase().contains(term);
    }).toList();
    emit(ExercicioFilterState(filtered, _currentFilter));
  }

  void _mapFilterByMecanismoToState(
      FilterByMecanismo event, Emitter<ExercicioFilterState> emit) {
    _currentFilter.mecanismo = event.mecanismo;
    final filtered = allExercicios.where((exercicio) {
      bool matchesMecanismo = exercicio.mecanismo == event.mecanismo;
      bool matchesGrupoMuscular = _currentFilter.grupoMuscular == null ||
          exercicio.grupoMuscular == _currentFilter.grupoMuscular;
      return matchesMecanismo && matchesGrupoMuscular;
    }).toList();
    emit(ExercicioFilterState(filtered, _currentFilter));
  }

  void _mapFilterByGrupoMuscularToState(
      FilterByGrupoMuscular event, Emitter<ExercicioFilterState> emit) {
    _currentFilter.grupoMuscular = event.grupoMuscular;
    final filtered = allExercicios.where((exercicio) {
      bool matchesGrupoMuscular =
          exercicio.grupoMuscular == event.grupoMuscular;
      bool matchesMecanismo = _currentFilter.mecanismo == null ||
          exercicio.mecanismo == _currentFilter.mecanismo;
      return matchesGrupoMuscular && matchesMecanismo;
    }).toList();
    emit(ExercicioFilterState(filtered, _currentFilter));
  }

  void _mapClearFilterToState(
      ClearFilter event, Emitter<ExercicioFilterState> emit) {
    _currentFilter.mecanismo = null;
    _currentFilter.grupoMuscular = null;
    emit(ExercicioFilterState(allExercicios, _currentFilter));
  }

  void _mapClearSpecificFilterToState(
      ClearSpecificFilter event, Emitter<ExercicioFilterState> emit) {
    if (event.filterType == 'mecanismo') {
      _currentFilter.mecanismo = null;
    } else if (event.filterType == 'grupoMuscular') {
      _currentFilter.grupoMuscular = null;
    }

    final filtered = allExercicios.where((exercicio) {
      bool matchesMecanismo = _currentFilter.mecanismo == null ||
          exercicio.mecanismo == _currentFilter.mecanismo;
      bool matchesGrupoMuscular = _currentFilter.grupoMuscular == null ||
          exercicio.grupoMuscular == _currentFilter.grupoMuscular;
      return matchesMecanismo && matchesGrupoMuscular;
    }).toList();

    emit(ExercicioFilterState(filtered, _currentFilter));
  }
}
