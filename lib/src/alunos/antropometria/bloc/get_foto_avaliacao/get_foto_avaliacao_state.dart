part of 'get_foto_avaliacao_bloc.dart';

class GetFotoAvaliacaoState {
  final List<Uint8List?> fotos;

  GetFotoAvaliacaoState({required this.fotos});
}

class GetFotoAvaliacaoInitial extends GetFotoAvaliacaoState {
  GetFotoAvaliacaoInitial() : super(fotos: [null, null, null, null]);
}

class GetFotoAvaliacaoLoaded extends GetFotoAvaliacaoState {
  GetFotoAvaliacaoLoaded(List<Uint8List?> fotos) : super(fotos: fotos);
}

class GetFotoAvaliacaoError extends GetFotoAvaliacaoState {
  final String error;

  GetFotoAvaliacaoError(this.error) : super(fotos: [null, null, null, null]);
}

