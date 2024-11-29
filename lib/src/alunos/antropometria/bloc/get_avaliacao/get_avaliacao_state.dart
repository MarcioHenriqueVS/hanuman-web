
class GetAvaliacaoState {}

final class GetAvaliacaoInitial extends GetAvaliacaoState {}

final class GetAvaliacaoLoading extends GetAvaliacaoState {}

final class GetAvaliacaoLoaded extends GetAvaliacaoState {
  dynamic avaliacao;

  GetAvaliacaoLoaded(this.avaliacao);
}

final class GetAvaliacaoError extends GetAvaliacaoState {
  String message;

  GetAvaliacaoError(this.message);
}
