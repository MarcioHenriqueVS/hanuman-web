import 'package:flutter_bloc/flutter_bloc.dart';
import '../../autenticacao/services/user_services.dart';
import 'get_foto_events.dart';
import 'get_foto_states.dart';

class UserFotoBloc extends Bloc<UserFotoEvent, UserFotoState> {
  final UserServices userServices;

  UserFotoBloc({required this.userServices}) : super(UserFotoInitial()) {
    on<FetchUserFoto>((event, emit) async {
      emit(UserFotoLoading());
      try {
        final foto = await userServices.getUserPhoto(event.uid);
        emit(UserFotoLoaded(foto));
      } catch (_) {
        emit(UserFotoError('Erro ao buscar foto'));
      }
    });
    on<UpdateUserFoto>((event, emit) async {
      emit(UserFotoUpdated(event.foto));
    });
    // adicionar mais manipuladores conforme necessário...
  }
}
