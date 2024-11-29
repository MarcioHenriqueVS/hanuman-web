import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/antropometria_services.dart';
import 'get_avaliacao_recente_event.dart';
import 'get_avaliacao_recente_state.dart';

class GetAvaliacaoMaisRecenteBloc
    extends Bloc<GetAvaliacaoMaisRecenteEvent, GetAvaliacaoMaisRecenteState> {
  GetAvaliacaoMaisRecenteBloc() : super(GetAvaliacaoMaisRecenteInitial()) {
    final AntropometriaServices antropometriaServices = AntropometriaServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarAvaliacaoMaisRecente>(
      (event, emit) async {
        emit(GetAvaliacaoMaisRecenteLoading());
        try {
          final avaliacao = await antropometriaServices.getAvaliacaoMaisRecente(
              uid, event.alunoUid);
          avaliacao != null
              ? emit(
                  GetAvaliacaoMaisRecenteLoaded(avaliacao),
                )
              : emit(
                  GetAvaliacaoMaisRecenteEmpty(),
                );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetAvaliacaoMaisRecenteError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
