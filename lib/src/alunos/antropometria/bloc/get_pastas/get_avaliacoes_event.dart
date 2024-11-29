class GetAvaliacoesEvent {}

class BuscarAvaliacoes extends GetAvaliacoesEvent {
  final String alunoUid;
  BuscarAvaliacoes(this.alunoUid);
}
