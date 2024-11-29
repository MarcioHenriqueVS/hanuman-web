import '../../models/treino_model.dart';

class GetTreinosFinalizadosState {}

final class GetTreinosFinalizadosInitial extends GetTreinosFinalizadosState {}

final class GetTreinosFinalizadosLoading extends GetTreinosFinalizadosState {}

final class GetTreinosFinalizadosLoaded extends GetTreinosFinalizadosState {
  List<TreinoFinalizado> treinos;

  GetTreinosFinalizadosLoaded(this.treinos);
}

final class GetTreinosFinalizadosLoadingMore
    extends GetTreinosFinalizadosState {}

final class GetTreinosFinalizadosLoadedMore extends GetTreinosFinalizadosState {
  List<TreinoFinalizado> treinos;

  GetTreinosFinalizadosLoadedMore(this.treinos);
}

final class GetTreinosFinalizadosNoMoreData extends GetTreinosFinalizadosState {
  List<TreinoFinalizado> treinos;

  GetTreinosFinalizadosNoMoreData(this.treinos);
}

final class GetTreinosFinalizadosIsEmpty extends GetTreinosFinalizadosState {}

final class GetTreinosFinalizadosError extends GetTreinosFinalizadosState {
  String message;

  GetTreinosFinalizadosError(this.message);
}
