
class GetAvaliacaoMaisRecenteState {}

final class GetAvaliacaoMaisRecenteInitial extends GetAvaliacaoMaisRecenteState {}

final class GetAvaliacaoMaisRecenteLoading extends GetAvaliacaoMaisRecenteState {}

final class GetAvaliacaoMaisRecenteLoaded extends GetAvaliacaoMaisRecenteState {
  dynamic avaliacao;

  GetAvaliacaoMaisRecenteLoaded(this.avaliacao);
}

// nenhuma avaliacao encontrada
final class GetAvaliacaoMaisRecenteEmpty extends GetAvaliacaoMaisRecenteState {}

final class GetAvaliacaoMaisRecenteError extends GetAvaliacaoMaisRecenteState {
  String message;

  GetAvaliacaoMaisRecenteError(this.message);
}
