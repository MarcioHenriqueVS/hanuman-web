import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../exercicios/model/exercicio_model.dart';
import 'events.dart';
import 'states.dart';

class ExercicioSelectionBloc
    extends Bloc<ExercicioSelectionEvent, ExercicioSelectionState> {
  ExercicioSelectionBloc() : super(ExercicioSelectionState([], [], false)) {
    on<ToggleExercicioSelection>(_mapToggleExercicioSelectionToState);
    on<AddToTempList>(_mapAddToTempListToState);
    on<ConfirmExercicioSelection>(_mapConfirmExercicioSelectionToState);
    on<ClearTempList>(_mapClearTempListToState);
    on<RemoveExercicioSelection>(_removeExercise);
    on<RemoveSingleExercicioSelection>(_removeSingleExerise);
  }

  void _mapToggleExercicioSelectionToState(
      ToggleExercicioSelection event, Emitter<ExercicioSelectionState> emit) {
    debugPrint('ExercicioSelectionToState');
    final currentList =
        List<ExercicioSelecionado>.from(state.selectedExercicios);
    if (currentList.contains(event.exercicio)) {
      currentList.remove(event.exercicio);
    } else {
      currentList.add(event.exercicio);
    }
    emit(ExercicioSelectionState(
        state.tempSelectedExercicios, currentList, true));
  }

  void _mapAddToTempListToState(
      AddToTempList event, Emitter<ExercicioSelectionState> emit) {
    final tempList =
        List<ExercicioSelecionado>.from(state.tempSelectedExercicios);
    if (!tempList.contains(event.exercicio)) {
      tempList.add(event.exercicio);
    }
    emit(ExercicioSelectionState(tempList, state.selectedExercicios, true));
  }

  void _mapConfirmExercicioSelectionToState(
      ConfirmExercicioSelection event, Emitter<ExercicioSelectionState> emit) {
    final currentTempList =
        List<ExercicioSelecionado>.from(state.tempSelectedExercicios);
    final currentMainList =
        List<ExercicioSelecionado>.from(state.selectedExercicios);
    currentMainList.addAll(currentTempList);
    emit(ExercicioSelectionState([], currentMainList, true));
  }

  void _mapClearTempListToState(
      ClearTempList event, Emitter<ExercicioSelectionState> emit) {
    emit(ExercicioSelectionState([], state.selectedExercicios, true));
  }

  void _removeExercise(
      RemoveExercicioSelection event, Emitter<ExercicioSelectionState> emit) {
    final tempList =
        List<ExercicioSelecionado>.from(state.tempSelectedExercicios);
    tempList.removeWhere((exercicio) => exercicio.id == event.exercicio.id);
    emit(ExercicioSelectionState(tempList, state.selectedExercicios, true));
  }

  void _removeSingleExerise(RemoveSingleExercicioSelection event,
      Emitter<ExercicioSelectionState> emit) {
    final tempList =
        List<ExercicioSelecionado>.from(state.tempSelectedExercicios);
    tempList
        .removeWhere((exercicio) => exercicio.newId == event.exercicio.newId);
    emit(ExercicioSelectionState(tempList, state.selectedExercicios, true));
  }

  
}
