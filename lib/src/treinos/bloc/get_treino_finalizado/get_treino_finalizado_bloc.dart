import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/treino_services.dart';
import 'get_treino_finalizado_event.dart';
import 'get_treino_finalizado_state.dart';

class GetTreinoFinalizadoBloc
    extends Bloc<GetTreinoFinalizadoEvent, GetTreinoFinalizadoState> {
  GetTreinoFinalizadoBloc() : super(GetTreinoFinalizadoInitial()) {
    final TreinoServices treinoServices = TreinoServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarTreinoFinalizado>(
      (event, emit) async {
        emit(GetTreinoFinalizadoLoading());
        try {
          final treino = await treinoServices.getTreinoFinalizado(
              uid, event.alunoUid, event.treinoId);
          treino != null
              ? emit(
                  GetTreinoFinalizadoLoaded(treino),
                )
              : emit(GetTreinoFinalizadoError('Nenhum treino encontrado'));
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetTreinoFinalizadoError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
