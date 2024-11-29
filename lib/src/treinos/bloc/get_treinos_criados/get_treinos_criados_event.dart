part of 'get_treinos_criados_bloc.dart';

class GetTreinosCriadosEvent {}

class BuscarTreinosCriados extends GetTreinosCriadosEvent {
  final String pastaId;
  BuscarTreinosCriados(this.pastaId);
}

