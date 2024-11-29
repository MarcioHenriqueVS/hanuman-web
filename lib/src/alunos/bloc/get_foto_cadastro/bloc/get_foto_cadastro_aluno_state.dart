part of 'get_foto_cadastro_aluno_bloc.dart';

sealed class GetFotoCadastroAlunoState {}

final class GetFotoCadastroAlunoInitial extends GetFotoCadastroAlunoState {}

final class GetFotoCadastroAlunoLoading extends GetFotoCadastroAlunoState {}

final class GetFotoCadastroAlunoLoaded extends GetFotoCadastroAlunoState {
  Uint8List? fotoBytes;

  GetFotoCadastroAlunoLoaded(this.fotoBytes);
}

final class GetFotoCadastroAlunoError extends GetFotoCadastroAlunoState {
  String errorMessage;

  GetFotoCadastroAlunoError(this.errorMessage);
}
