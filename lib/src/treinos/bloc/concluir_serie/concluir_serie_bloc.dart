import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'concluir_serie_event.dart';
import 'concluir_serie_state.dart';

class ConcluirSerieBloc extends Bloc<ConcluirSerieEvent, SerieMarcada> {
  ConcluirSerieBloc() : super(SerieMarcada(false, {}, 0)) {
    on<MarcarSerie>(_mapToggleSerieSelectionToState);
    //on<AddTempList>(_mapAddToTempListToState);
    //on<DesmarcarSerie>();
  }

  void _mapToggleSerieSelectionToState(
      MarcarSerie event, Emitter<SerieMarcada> emit) {
    final currentExercicioList = Map<int, List<int>>.from(state.tempVolumeList);

    final currentList = currentExercicioList[event.exercicioIndex] ?? [];

    final int serieVolume = event.kg * event.reps;

    if (currentList.contains(event.serieIndex)) {
      currentList.remove(event.serieIndex);
      emit(
        SerieMarcada(
            true, currentExercicioList, state.totalVolume - serieVolume),
      );
    } else {
      currentList.add(event.serieIndex);
      currentExercicioList[event.exercicioIndex] = currentList;
      emit(
        SerieMarcada(
            true, currentExercicioList, state.totalVolume + serieVolume),
      );
      debugPrint(state.totalVolume.toString());
    }
  }

  // void _mapAddToTempListToState(AddTempList event, Emitter<SerieMarcada> emit) {
  //   final tempList = List<int>.from(state.tempVolumeList);
  //   if (!tempList.contains(event.volumeTotal)) {
  //     tempList.add(event.volumeTotal);
  //   }
  //   emit(SerieMarcada(
  //     true,
  //     tempList,
  //     state.totalVolume,
  //   ));
  // }
}
