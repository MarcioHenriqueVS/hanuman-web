class GetTreinoFinalizadoEvent {}

class BuscarTreinoFinalizado extends GetTreinoFinalizadoEvent {
  final String alunoUid;
  final String treinoId;
  BuscarTreinoFinalizado(this.alunoUid, this.treinoId);
}
