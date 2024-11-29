class GetPastasEvent {}

class BuscarPastas extends GetPastasEvent {
  final String alunoUid;
  BuscarPastas(this.alunoUid);
}
