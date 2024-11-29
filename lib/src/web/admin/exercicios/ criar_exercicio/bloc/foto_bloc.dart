import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_services.dart';
import 'events_foto.dart';
import 'states_foto.dart';

class FotoBloc extends Bloc<SelectFotoEvent, SelectFotoState> {
  final AdminServices adminServices;

  FotoBloc({required this.adminServices})
      : super(SelectFotoInitial()) {
    on<FotoSelected>((event, emit) async {
      emit(SelectFotoLoading());
      try {
        final String? selectedImage = await adminServices.selectImage();
        
        if (selectedImage != null) {
          emit(SelectFotoLoaded(selectedImage));
        }
      } catch (_) {
        emit(SelectFotoError('Erro ao buscar credencial'));
      }
    });
  }
}
