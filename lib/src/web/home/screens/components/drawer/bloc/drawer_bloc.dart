import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../autenticacao/services/user_services.dart';
import 'events_bloc.dart';
import 'states_bloc.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  DrawerBloc() : super(DrawerInitial()) {
    final UserServices userServices = UserServices();
    on<UserIsAdmin>((event, emit) async {
      emit(DrawerLoading());
      try {
        bool isAdmin = await userServices.isAdmin();
        emit(DrawerLoaded(isAdmin));
      } catch (_) {
        emit(DrawerError('Erro ao buscar credencial'));
      }
    });
  }
}
