import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/treino_model.dart';
import '../../services/treinos_personal_service.dart';
part 'get_treinos_criados_event.dart';
part 'get_treinos_criados_state.dart';

class GetTreinosCriadosBloc extends Bloc<GetTreinosCriadosEvent, GetTreinosCriadosState> {
  GetTreinosCriadosBloc() : super(GetTreinosCriadosInitial()) {
    final TreinosPersonalServices treinosPersonalServices =
      TreinosPersonalServices();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarTreinosCriados>((event, emit) async {
      emit(GetTreinosCriadosLoading());
        try {
          final treinos = await treinosPersonalServices.getTreinosCriados(
              uid, event.pastaId);
          emit(
            GetTreinosCriadosLoaded(treinos),
          );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetTreinosCriadosError(
              e.toString(),
            ),
          );
        }
    });
  }
}
