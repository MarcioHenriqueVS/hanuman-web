import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/aluno_model.dart';
import '../../services/alunos_services.dart';
part 'get_alunos_event.dart';
part 'get_alunos_state.dart';

class GetAlunosBloc extends Bloc<GetAlunosEvent, GetAlunosState> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  String? lastVisibleDocId;
  bool isFetchingMore = false;

  GetAlunosBloc() : super(GetAlunosInitial()) {
    final AlunosServices alunosServices = AlunosServices();

    // Lida com a busca inicial dos treinos
    on<BuscarAlunos>(
      (event, emit) async {
        emit(GetAlunosLoading());
        try {
          List<AlunoModel> alunos = await alunosServices.getAlunos(
            uid,
            //event.alunoUid,
            event.lastVisibleDocId,
          );

          lastVisibleDocId = alunos.last.uid;

          alunos.isEmpty
              ? emit(GetAlunosDataIsEmpty())
              : emit(GetAlunosLoaded(alunos));
        } catch (e) {
          if (e.toString().contains('No element')) {
            emit(GetAlunosDataIsEmpty());
          } else {
            emit(GetAlunosError(e.toString()));
          }
        }
      },
    );

    // Lida com o carregamento de mais treinos
    on<CarregarMaisAlunos>(
      (event, emit) async {
        if (isFetchingMore) return;

        isFetchingMore = true;
        emit(GetAlunosLoadingMore());

        try {
          List<AlunoModel> novosTreinos = await alunosServices.getAlunos(
            uid,
            //event.alunoUid,
            event.lastVisibleDocId,
          );

          if (novosTreinos.isEmpty) {
            emit(GetAlunosNoMoreData(event.alunosJaCarregados));
          } else {
            lastVisibleDocId = novosTreinos.last.uid;
            List<AlunoModel> todosAlunos = [
              ...event.alunosJaCarregados,
              ...novosTreinos,
            ];
            emit(GetAlunosLoadedMore(todosAlunos));
          }
        } catch (e) {
          emit(GetAlunosError(e.toString()));
        }

        isFetchingMore = false;
      },
    );

    // Lida com o reinício do Bloc
    on<ReiniciarAlunosBloc>(
      (event, emit) {
        // Reiniciar o estado para o inicial
        lastVisibleDocId = null;
        isFetchingMore = false;
        emit(GetAlunosInitial());
      },
    );
  }
}
