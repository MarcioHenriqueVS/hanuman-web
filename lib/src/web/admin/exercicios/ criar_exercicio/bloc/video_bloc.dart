import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_services.dart';
import 'events_video.dart';
import 'states_video.dart';

class VideoBloc extends Bloc<SelectVideoEvent, SelectVideoState> {
  final AdminServices adminServices;

  VideoBloc({required this.adminServices}) : super(SelectVideoInitial()) {
    on<VideoSelected>((event, emit) async {
      emit(SelectVideoLoading());
      try {
        final String? selectedVideo = await adminServices.selectVideo();

        if (selectedVideo != null) {
          emit(SelectVideoLoaded(selectedVideo));
        }
      } catch (_) {
        emit(SelectVideoError('Erro ao buscar credencial'));
      }
    });
  }
}
