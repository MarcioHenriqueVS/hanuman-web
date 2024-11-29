class GetAvaliacoesDataEvent {}

class BuscarAvaliacoesData extends GetAvaliacoesDataEvent {
  final String alunoUid;
  BuscarAvaliacoesData(this.alunoUid);
}
