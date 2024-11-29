class ConcluirSerieState {}

class ConcluirSerieInitial extends ConcluirSerieState {}

class SerieMarcada {
  final bool isChecked;
  final Map<int, List<int>> tempVolumeList;
  final int totalVolume;

  SerieMarcada(this.isChecked, this.tempVolumeList, this.totalVolume);
}
