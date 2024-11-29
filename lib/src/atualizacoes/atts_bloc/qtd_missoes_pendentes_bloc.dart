import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/atualizacoes_services.dart';
import 'qtd_missoes_pendentes_event.dart';
import 'qtd_missoes_pendentes_state.dart';

class AttsHomeBloc extends Bloc<AttsHomeEvent, AttsHomeState> {
  AttsHomeBloc() : super(AttsHomeInitial()) {
    debugPrint("AttsHomeBloc - Iniciado");

    final AtualizacaoServices atualizacaoServices = AtualizacaoServices();
    on<BuscarAttsHome>(
      (event, emit) async {
        emit(AttsHomeLoading());
        try {
          debugPrint('Iniciando busca de atualizações');
          final atts = await atualizacaoServices.buscarAtualizacoes();
          
            if (!isClosed) {
              emit(AttsHomeLoaded(atts));
            
          }
        } catch (e) {
          emit(AttsHomeError(e.toString()));
          debugPrint('Erro na stream: $e');
        }
      },
    );
  }

  @override
  Future<void> close() {
    debugPrint("AttsHomeBloc - Fechado");
    return super.close();
  }
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// class AttsHomeBloc extends Bloc<AttsHomeEvent, AttsHomeState> {
//   final AtualizacaoServices atualizacaoServices = AtualizacaoServices();

//   AttsHomeBloc() : super(AttsHomeInitial()) {
//     on<BuscarAttsHome>((event, emit) async {
//       emit(AttsHomeLoading());

//       try {
//         // Escuta a stream e usa await for para processar cada evento da stream
//         await for (final List<Map<String, dynamic>> newAtts in atualizacaoServices.atualizacoesStream()) {
//           if (state is AttsHomeLoaded) {
//             // Se o estado atual já contém uma lista, adicionamos o novo documento
//             final currentAtts = (state as AttsHomeLoaded).atts;
//             List<Map<String, dynamic>> updatedAtts = List.from(currentAtts);

//             for (var newAtt in newAtts) {
//               // Verifica se o novo documento não está na lista
//               bool alreadyExists = updatedAtts.any((att) => att['id'] == newAtt['id']);

//               if (!alreadyExists) {
//                 updatedAtts.add(newAtt);
//               }
//             }

//             // Ordena por timestamp
//             updatedAtts.sort((a, b) =>
//               (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

//             // Emite o novo estado com a lista atualizada
//             if (!emit.isDone) {
//               emit(AttsHomeLoaded(updatedAtts));
//             }
//           } else {
//             // Se for o primeiro documento, emitimos diretamente
//             if (!emit.isDone) {
//               emit(AttsHomeLoaded(newAtts));
//             }
//           }
//         }
//       } catch (e) {
//         // Captura e emite o erro caso aconteça algum problema
//         if (!emit.isDone) {
//           emit(AttsHomeError(e.toString()));
//         }
//       }
//     });
//   }

//   @override
//   Future<void> close() {
//     debugPrint("AttsHomeBloc - Fechado");
//     return super.close();
//   }
// }
