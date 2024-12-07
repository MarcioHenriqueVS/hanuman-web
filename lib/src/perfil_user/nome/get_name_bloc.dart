import 'package:flutter_bloc/flutter_bloc.dart';
import '../../autenticacao/services/user_services.dart';
import 'get_name_events.dart';
import 'get_name_states.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserServices userServices;

  UserBloc({required this.userServices}) : super(UserInitial()) {
    on<FetchUserName>((event, emit) async {
      emit(UserNameLoading());
      try {
        final name = await userServices.getUserName(event.uid);
        emit(UserNameLoaded(name));
      } catch (_) {
        emit(UserNameError('Erro ao buscar nome'));
      }
    });
    on<UpdateUserName>((event, emit) async {
      emit(UserNameUpdated(event.newName));
    });
    // Você pode adicionar mais manipuladores conforme necessário...
  }
}
