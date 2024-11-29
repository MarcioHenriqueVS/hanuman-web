import '../../models/avaliacao_model.dart';

class GetAvaliacoesDataState {}

final class GetAvaliacoesDataInitial extends GetAvaliacoesDataState {}

final class GetAvaliacoesDataLoading extends GetAvaliacoesDataState {}

final class GetAvaliacoesDataLoaded extends GetAvaliacoesDataState {
  List<AvaliacaoModel> avaliacoes;

  GetAvaliacoesDataLoaded(this.avaliacoes);
}

final class GetAvaliacoesDataEmpty extends GetAvaliacoesDataState {}

final class GetAvaliacoesDataError extends GetAvaliacoesDataState {
  String message;

  GetAvaliacoesDataError(this.message);
}
