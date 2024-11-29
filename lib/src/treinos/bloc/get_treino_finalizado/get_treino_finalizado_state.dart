import '../../models/treino_model.dart';

class GetTreinoFinalizadoState {}

final class GetTreinoFinalizadoInitial extends GetTreinoFinalizadoState {}

final class GetTreinoFinalizadoLoading extends GetTreinoFinalizadoState {}

final class GetTreinoFinalizadoLoaded extends GetTreinoFinalizadoState {
  TreinoFinalizado treino;

  GetTreinoFinalizadoLoaded(this.treino);
}

final class GetTreinoFinalizadoError extends GetTreinoFinalizadoState {
  String message;

  GetTreinoFinalizadoError(this.message);
}
