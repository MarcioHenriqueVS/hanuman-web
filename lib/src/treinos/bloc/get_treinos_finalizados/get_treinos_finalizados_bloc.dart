import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/treino_model.dart';
import '../../services/treino_services.dart';
import 'get_treinos_finalizados_event.dart';
import 'get_treinos_finalizados_state.dart';

// class GetTreinosFinalizadosBloc
//     extends Bloc<GetTreinosFinalizadosEvent, GetTreinosFinalizadosState> {
//   GetTreinosFinalizadosBloc() : super(GetTreinosFinalizadosInitial()) {
//     final TreinoServices treinoServices = TreinoServices();
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     on<BuscarTreinosFinalizados>(
//       (event, emit) async {
//         emit(GetTreinosFinalizadosLoading());
//         try {
//           List<TreinoFinalizado> treinos =
//               await treinoServices.getTreinosFinalizados(uid, event.alunoUid);
//           emit(
//             GetTreinosFinalizadosLoaded(treinos),
//           );
//         } catch (e) {
//           debugPrint(e.toString());
//           emit(
//             GetTreinosFinalizadosError(
//               e.toString(),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

class GetTreinosFinalizadosBloc
    extends Bloc<GetTreinosFinalizadosEvent, GetTreinosFinalizadosState> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  String? lastVisibleDocId;
  bool isFetchingMore = false;

  GetTreinosFinalizadosBloc() : super(GetTreinosFinalizadosInitial()) {
    final TreinoServices treinoServices = TreinoServices();

    // Lida com a busca inicial dos treinos
    on<BuscarTreinosFinalizados>(
      (event, emit) async {
        emit(GetTreinosFinalizadosLoading());
        try {
          List<TreinoFinalizado> treinos =
              await treinoServices.getTreinosFinalizados(
            uid,
            event.alunoUid,
            event.lastVisibleDocId,
          );

          lastVisibleDocId = treinos.last.id;

          treinos.isEmpty
              ? emit(GetTreinosFinalizadosIsEmpty())
              : emit(GetTreinosFinalizadosLoaded(treinos));
        } catch (e) {
          emit(GetTreinosFinalizadosError(e.toString()));
        }
      },
    );

    // Lida com o carregamento de mais treinos
    on<CarregarMaisTreinosFinalizados>(
      (event, emit) async {
        if (isFetchingMore) return;

        isFetchingMore = true;
        emit(GetTreinosFinalizadosLoadingMore());

        try {
          List<TreinoFinalizado> novosTreinos =
              await treinoServices.getTreinosFinalizados(
            uid,
            event.alunoUid,
            event.lastVisibleDocId,
          );

          if (novosTreinos.isEmpty) {
            emit(GetTreinosFinalizadosNoMoreData(event.treinosJaCarregados));
          } else {
            lastVisibleDocId = novosTreinos.last.id;
            List<TreinoFinalizado> todosTreinos = [
              ...event.treinosJaCarregados,
              ...novosTreinos,
            ];
            emit(GetTreinosFinalizadosLoadedMore(todosTreinos));
          }
        } catch (e) {
          emit(GetTreinosFinalizadosError(e.toString()));
        }

        isFetchingMore = false;
      },
    );

    // Lida com o reinício do Bloc
    on<ReiniciarTreinosFinalizados>(
      (event, emit) {
        // Reiniciar o estado para o inicial
        lastVisibleDocId = null;
        isFetchingMore = false;
        emit(GetTreinosFinalizadosInitial());
      },
    );
  }
}
