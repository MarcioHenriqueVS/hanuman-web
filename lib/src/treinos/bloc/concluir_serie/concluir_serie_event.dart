class ConcluirSerieEvent {}

class MarcarSerie extends ConcluirSerieEvent {
  int exercicioIndex;
  int serieIndex;
  int kg;
  int reps;

  MarcarSerie(this.exercicioIndex, this.serieIndex, this.kg, this.reps);
}

class AddTempList extends ConcluirSerieEvent {
  final int volumeTotal;

  AddTempList(this.volumeTotal);
}

class ConfirmExercicioSelection extends ConcluirSerieEvent {}

class LimparTempList extends ConcluirSerieEvent {}

class ClearSerieSelection extends ConcluirSerieEvent {}

class DesmarcarSerie extends ConcluirSerieEvent {
  final int index;
    final int kg;
  final int reps;

  DesmarcarSerie(this.index, this.kg, this.reps);
}
