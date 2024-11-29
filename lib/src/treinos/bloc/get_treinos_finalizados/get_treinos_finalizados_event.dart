import '../../models/treino_model.dart';

class GetTreinosFinalizadosEvent {}

class BuscarTreinosFinalizados extends GetTreinosFinalizadosEvent {
  final String alunoUid;
  final String? lastVisibleDocId;
  BuscarTreinosFinalizados(this.alunoUid, this.lastVisibleDocId);
}

class CarregarMaisTreinosFinalizados extends GetTreinosFinalizadosEvent {
  final String alunoUid;
  final String lastVisibleDocId;
  final List<TreinoFinalizado> treinosJaCarregados;
  CarregarMaisTreinosFinalizados(this.alunoUid, this.lastVisibleDocId, this.treinosJaCarregados);
}

// Evento para reiniciar o Bloc
class ReiniciarTreinosFinalizados extends GetTreinosFinalizadosEvent {}
