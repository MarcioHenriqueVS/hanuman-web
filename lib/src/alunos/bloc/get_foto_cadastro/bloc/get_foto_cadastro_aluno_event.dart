part of 'get_foto_cadastro_aluno_bloc.dart';

sealed class GetFotoCadastroAlunoEvent {}

final class SelecionarFotoEvent extends GetFotoCadastroAlunoEvent {}

final class RestartFotoEvent extends GetFotoCadastroAlunoEvent {}
