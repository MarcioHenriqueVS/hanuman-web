part of 'get_foto_avaliacao_bloc.dart';

sealed class GetFotoAvaliacaoEvent {}

// Evento para selecionar uma foto para um campo específico
class SelecionarFotoEvent extends GetFotoAvaliacaoEvent {
  final int fotoIndex;

  SelecionarFotoEvent(this.fotoIndex);
}

// Evento para reiniciar a foto de um campo específico
class RestartFotoEvent extends GetFotoAvaliacaoEvent {
  final int fotoIndex;

  RestartFotoEvent(this.fotoIndex);
}

