import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/alunos_services.dart';

// Events
abstract class DeleteAlunoEvent {}

class DeleteAlunoStarted extends DeleteAlunoEvent {
  final String alunoUid;
  final String uid;

  DeleteAlunoStarted(this.alunoUid, this.uid);
}

// States
abstract class DeleteAlunoState {}

class DeleteAlunoInitial extends DeleteAlunoState {}

class DeleteAlunoLoading extends DeleteAlunoState {}

class DeleteAlunoSuccess extends DeleteAlunoState {}

class DeleteAlunoError extends DeleteAlunoState {
  final String message;
  DeleteAlunoError(this.message);
}

// Bloc
class DeleteAlunoBloc extends Bloc<DeleteAlunoEvent, DeleteAlunoState> {
  final AlunosServices _alunosServices;

  DeleteAlunoBloc(this._alunosServices) : super(DeleteAlunoInitial()) {
    on<DeleteAlunoStarted>(_onDeleteAlunoStarted);
  }

  Future<void> _onDeleteAlunoStarted(
    DeleteAlunoStarted event,
    Emitter<DeleteAlunoState> emit,
  ) async {
    emit(DeleteAlunoLoading());
    try {
      await _alunosServices.deleteAluno(event.alunoUid, event.uid);
      emit(DeleteAlunoSuccess());
    } catch (e) {
      emit(DeleteAlunoError(e.toString()));
    }
  }
}
