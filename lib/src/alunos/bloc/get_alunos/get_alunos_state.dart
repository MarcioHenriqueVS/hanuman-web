part of 'get_alunos_bloc.dart';

sealed class GetAlunosState {}

final class GetAlunosInitial extends GetAlunosState {}

final class GetAlunosLoading extends GetAlunosState {}

final class GetAlunosLoaded extends GetAlunosState {
  List<AlunoModel> alunos;

  GetAlunosLoaded(this.alunos);
}

final class GetAlunosDataIsEmpty extends GetAlunosState {}

final class GetAlunosLoadingMore extends GetAlunosState {}

final class GetAlunosLoadedMore extends GetAlunosState {
  List<AlunoModel> alunos;

  GetAlunosLoadedMore(this.alunos);
}

final class GetAlunosNoMoreData extends GetAlunosState {
  List<AlunoModel> alunos;

  GetAlunosNoMoreData(this.alunos);
}

final class GetAlunosError extends GetAlunosState {
  String message;

  GetAlunosError(this.message);
}
