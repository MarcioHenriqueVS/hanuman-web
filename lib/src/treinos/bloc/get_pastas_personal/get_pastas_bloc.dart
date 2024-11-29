import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pastas/galeria/services/pastas_galeria_services.dart';
import 'get_pastas_event.dart';
import 'get_pastas_state.dart';

class GetPastasPersonalBloc extends Bloc<GetPastasPersonalEvent, GetPastasPersonalState> {
  GetPastasPersonalBloc() : super(GetPastasPersonalInitial()) {
    final PastasGaleriaServices pastasGaleriaServices = PastasGaleriaServices();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    on<BuscarPastasPersonal>(
      (event, emit) async {
        emit(GetPastasPersonalLoading());
        try {
          final pastas = await pastasGaleriaServices.getPastasPersonal(uid);
          emit(
            GetPastasPersonalLoaded(pastas),
          );
        } catch (e) {
          debugPrint(e.toString());
          emit(
            GetPastasPersonalError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
}
