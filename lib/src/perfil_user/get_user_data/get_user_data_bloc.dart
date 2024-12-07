import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'get_user_data_event.dart';
part 'get_user_data_state.dart';

class GetUserDataBloc extends Bloc<GetUserDataEvent, GetUserDataState> {
  GetUserDataBloc() : super(GetUserDataInitial()) {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    //final PerfilServices perfilServices = PerfilServices();
    on<GetUserData>(
      (event, emit) async {
        emit(GetUserDataLoading());
        try {
          final user = firebaseAuth.currentUser!;
          await user.reload();
          final updatedUser = firebaseAuth.currentUser;
          final uid = updatedUser!.uid;
          final nome = updatedUser.displayName;
          final fotoUrl = updatedUser.photoURL;
          final email = updatedUser.email;
          // final qtdTreinosFinalizados = await perfilServices
          //     .getQtdTreinosFinalizados(event.personalUid, uid);
          // final qtdAvaliacoesRealizadas = await perfilServices
          //     .getQtdAvaliacoesRealizadas(event.personalUid, uid);
          emit(
            GetUserDataLoaded(nome, fotoUrl, email, 0, 0),
          );
        } catch (e) {
          debugPrint(
              'erro ao buscar dados do usuario -------> ${e.toString()}');
          emit(GetUserDataError(e.toString()));
        }
      },
    );
  }
}
