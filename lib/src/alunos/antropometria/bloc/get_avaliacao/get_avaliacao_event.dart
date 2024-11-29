class GetAvaliacaoEvent {}

class BuscarAvaliacao extends GetAvaliacaoEvent {
  final String alunoUid;
  final String avaliacaoId;
  BuscarAvaliacao(this.alunoUid, this.avaliacaoId);
}
