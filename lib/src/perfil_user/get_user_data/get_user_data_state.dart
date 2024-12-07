part of 'get_user_data_bloc.dart';

sealed class GetUserDataState {}

final class GetUserDataInitial extends GetUserDataState {}

final class GetUserDataLoading extends GetUserDataState {}

final class GetUserDataLoaded extends GetUserDataState {
  String? nome;
  String? fotoUrl;
  String? email;
  int? qtdTreinosFinalizados;
  int? qtdAvaliacoesRealizadas;

  GetUserDataLoaded(this.nome, this.fotoUrl, this.email,
      this.qtdTreinosFinalizados, this.qtdAvaliacoesRealizadas);
}

final class GetUserDataError extends GetUserDataState {
  String message;

  GetUserDataError(this.message);
}
