class GetTreinosEvent {}

class BuscarTreinos extends GetTreinosEvent {
  final String alunoUid;
  final String pastaId;
  BuscarTreinos(this.alunoUid, this.pastaId);
}
