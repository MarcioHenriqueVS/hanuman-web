import '../../models/treino_model.dart';

class GetTreinosState {}

final class GetTreinosInitial extends GetTreinosState {}

final class GetTreinosLoading extends GetTreinosState {}

final class GetTreinosLoaded extends GetTreinosState {
  List<Treino> treinos;

  GetTreinosLoaded(this.treinos);
}

final class GetTreinosError extends GetTreinosState {
  String message;

  GetTreinosError(this.message);
}
