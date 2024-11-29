import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/treino_services.dart';
import 'get_treinos_event.dart';
import 'get_treinos_state.dart';

class GetTreinosBloc extends Bloc<GetTreinosEvent, GetTreinosState> {
  GetTreinosBloc() : super(GetTreinosInitial()) {
    final TreinoServices treinoServices = TreinoServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarTreinos>(
      (event, emit) async {
        emit(GetTreinosLoading());
        try {
          final treinos = await treinoServices.getTreinos(
              uid, event.alunoUid, event.pastaId);
          emit(
            GetTreinosLoaded(treinos),
          );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetTreinosError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
