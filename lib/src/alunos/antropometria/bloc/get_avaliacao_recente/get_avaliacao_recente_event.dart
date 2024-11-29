class GetAvaliacaoMaisRecenteEvent {}

class BuscarAvaliacaoMaisRecente extends GetAvaliacaoMaisRecenteEvent {
  final String alunoUid;
  BuscarAvaliacaoMaisRecente(this.alunoUid);
}
