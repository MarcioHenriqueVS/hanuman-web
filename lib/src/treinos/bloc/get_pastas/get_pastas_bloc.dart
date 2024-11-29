import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/treino_services.dart';
import 'get_pastas_event.dart';
import 'get_pastas_state.dart';

class GetPastasBloc extends Bloc<GetPastasEvent, GetPastasState> {
  GetPastasBloc() : super(GetPastasInitial()) {
    final TreinoServices treinoServices = TreinoServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarPastas>(
      (event, emit) async {
        emit(GetPastasLoading());
        try {
          final pastas = await treinoServices.getPastas(uid, event.alunoUid);
          emit(
            GetPastasLoaded(pastas),
          );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetPastasError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
