import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/antropometria_services.dart';
part 'get_foto_avaliacao_event.dart';
part 'get_foto_avaliacao_state.dart';

class GetFotoAvaliacaoBloc
    extends Bloc<GetFotoAvaliacaoEvent, GetFotoAvaliacaoState> {
  GetFotoAvaliacaoBloc() : super(GetFotoAvaliacaoInitial()) {
    AntropometriaServices antropometriaServices = AntropometriaServices();

    on<SelecionarFotoEvent>(
      (event, emit) async {
        try {
          final fotoBytes = await antropometriaServices.selectImageBytes();
          if (fotoBytes != null) {
            final updatedFotos = List<Uint8List?>.from(state.fotos);
            updatedFotos[event.fotoIndex] = fotoBytes;
            emit(GetFotoAvaliacaoLoaded(updatedFotos));
          } else {
            emit(GetFotoAvaliacaoInitial());
          }
        } catch (e) {
          emit(GetFotoAvaliacaoError(e.toString()));
        }
      },
    );

    on<RestartFotoEvent>(
      (event, emit) async {
        final updatedFotos = List<Uint8List?>.from(state.fotos);
        updatedFotos[event.fotoIndex] = null;
        emit(GetFotoAvaliacaoLoaded(updatedFotos));
      },
    );

    on<CarregarFotoExistenteEvent>(
      (event, emit) {
        final updatedFotos = List<Uint8List?>.from(state.fotos);
        updatedFotos[event.fotoIndex] = event.fotoBytes;
        emit(GetFotoAvaliacaoLoaded(updatedFotos));
      },
    );
  }
}
