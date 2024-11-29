import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/antropometria_services.dart';
import 'get_avaliacoes_event.dart';
import 'get_avaliacoes_state.dart';

class GetAvaliacoesBloc extends Bloc<GetAvaliacoesEvent, GetAvaliacoesState> {
  GetAvaliacoesBloc() : super(GetAvaliacoesInitial()) {
    final AntropometriaServices antropometriaServices = AntropometriaServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarAvaliacoes>(
      (event, emit) async {
        emit(GetAvaliacoesLoading());
        try {
          final pastas = await antropometriaServices.getAvaliacoes(uid, event.alunoUid);
          emit(
            GetAvaliacoesLoaded(pastas),
          );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetAvaliacoesError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
