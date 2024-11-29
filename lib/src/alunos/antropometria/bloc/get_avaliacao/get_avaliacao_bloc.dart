import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/antropometria_services.dart';
import 'get_avaliacao_event.dart';
import 'get_avaliacao_state.dart';

class GetAvaliacaoBloc extends Bloc<GetAvaliacaoEvent, GetAvaliacaoState> {
  GetAvaliacaoBloc() : super(GetAvaliacaoInitial()) {
    final AntropometriaServices antropometriaServices = AntropometriaServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarAvaliacao>(
      (event, emit) async {
        emit(GetAvaliacaoLoading());
        try {
          final avaliacao = await antropometriaServices.getAvaliacao(
              uid, event.alunoUid, event.avaliacaoId);
          avaliacao != null
              ? emit(
                  GetAvaliacaoLoaded(avaliacao),
                )
              : GetAvaliacaoError('Avaliacao não encontrada');
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetAvaliacaoError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
