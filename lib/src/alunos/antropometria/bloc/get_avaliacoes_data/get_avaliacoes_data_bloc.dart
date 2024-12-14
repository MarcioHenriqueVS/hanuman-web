import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/avaliacao_model.dart';
import '../../services/antropometria_services.dart';
import 'get_avaliacoes_data_event.dart';
import 'get_avaliacoes_data_state.dart';

class GetAvaliacoesDataBloc
    extends Bloc<GetAvaliacoesDataEvent, GetAvaliacoesDataState> {
  GetAvaliacoesDataBloc() : super(GetAvaliacoesDataInitial()) {
    final AntropometriaServices antropometriaServices = AntropometriaServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarAvaliacoesData>(
      (event, emit) async {
        emit(GetAvaliacoesDataLoading());
        try {
          final avaliacoes = await antropometriaServices.getAvaliacoesData(
              uid, event.alunoUid);
          avaliacoes != null
              ? emit(
                  GetAvaliacoesDataLoaded(avaliacoes),
                )
              : emit(
                  GetAvaliacoesDataEmpty(),
                );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetAvaliacoesDataError(
              e.toString(),
            ),
          );
        }
      },
    );

    on<AtualizarAvaliacaoData>((event, emit) {
      if (state is GetAvaliacoesDataLoaded) {
        final currentState = state as GetAvaliacoesDataLoaded;
        final updatedAvaliacoes =
            List<AvaliacaoModel>.from(currentState.avaliacoes);
        final index =
            updatedAvaliacoes.indexWhere((a) => a.id == event.avaliacao.id);
        if (index != -1) {
          updatedAvaliacoes[index] = event.avaliacao;
          emit(GetAvaliacoesDataLoaded(updatedAvaliacoes));
        }
      }
    });
  }
}
