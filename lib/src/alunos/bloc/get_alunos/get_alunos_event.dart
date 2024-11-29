part of 'get_alunos_bloc.dart';

abstract class GetAlunosEvent {}

class BuscarAlunos extends GetAlunosEvent {
  final String? lastVisibleDocId;
  BuscarAlunos({this.lastVisibleDocId});
}

class CarregarMaisAlunos extends GetAlunosEvent {
  final String lastVisibleDocId;
  final List<AlunoModel> alunosJaCarregados;

  CarregarMaisAlunos({
    required this.lastVisibleDocId,
    required this.alunosJaCarregados,
  });
}

class ReiniciarAlunosBloc extends GetAlunosEvent {}
