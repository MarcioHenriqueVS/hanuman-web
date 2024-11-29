class GetAvaliacoesState {}

final class GetAvaliacoesInitial extends GetAvaliacoesState {}

final class GetAvaliacoesLoading extends GetAvaliacoesState {}

final class GetAvaliacoesLoaded extends GetAvaliacoesState {
  List<String> avaliacoesIds;

  GetAvaliacoesLoaded(this.avaliacoesIds);
}

final class GetAvaliacoesError extends GetAvaliacoesState {
  String message;

  GetAvaliacoesError(this.message);
}
