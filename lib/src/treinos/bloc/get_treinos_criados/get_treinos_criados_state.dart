part of 'get_treinos_criados_bloc.dart';

class GetTreinosCriadosState {}

final class GetTreinosCriadosInitial extends GetTreinosCriadosState {}

final class GetTreinosCriadosLoading extends GetTreinosCriadosState {}

final class GetTreinosCriadosLoaded extends GetTreinosCriadosState {
  List<Treino> treinos;

  GetTreinosCriadosLoaded(this.treinos);
}

final class GetTreinosCriadosError extends GetTreinosCriadosState {
  String message;

  GetTreinosCriadosError(this.message);
}

