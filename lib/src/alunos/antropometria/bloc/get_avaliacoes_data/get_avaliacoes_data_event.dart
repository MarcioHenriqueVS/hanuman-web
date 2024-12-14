import '../../models/avaliacao_model.dart';

class GetAvaliacoesDataEvent {}

class BuscarAvaliacoesData extends GetAvaliacoesDataEvent {
  final String alunoUid;
  BuscarAvaliacoesData(this.alunoUid);
}

class AtualizarAvaliacaoData extends GetAvaliacoesDataEvent {
  final AvaliacaoModel avaliacao;
  AtualizarAvaliacaoData(this.avaliacao);
}
