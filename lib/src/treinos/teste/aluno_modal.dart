import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/get_pastas/get_pastas_bloc.dart';
import '../bloc/get_pastas/get_pastas_state.dart';
import '../pages/galeria/components/add_pasta_dialog.dart';
import '../services/treino_services.dart';
import 'enviar_treino_dialog.dart';
import 'models/training_sheet.dart';

class AlunoModal extends StatefulWidget {
  final String? alunoUid;
  final List<TrainingSheet>? treinos;
  const AlunoModal({super.key, this.alunoUid, this.treinos});

  @override
  State<AlunoModal> createState() => _AlunoModalState();
}

class _AlunoModalState extends State<AlunoModal> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final pastaIdController = TextEditingController();

  void enviarTreinoDialog(String pastaId, List<TrainingSheet> trainingSheets) {
    showDialog(
      context: context,
      builder: (context) => EnviarTreinoDialog(
        pastaId: pastaId,
        trainingSheets: trainingSheets,
        alunoUid: widget.alunoUid,
        uid: uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPastasBloc, GetPastasState>(
      builder: (context, pastasState) {
        if (pastasState is GetPastasInitial) {
          return const Center(child: Text('Iniciando busca das pastas'));
        } else if (pastasState is GetPastasLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (pastasState is GetPastasError) {
          return const Center(
            child: Text('Erro ao tentar buscar pastas, recarregue a tela',
                textAlign: TextAlign.center),
          );
        } else if (pastasState is GetPastasLoaded) {
          final pastasIds = pastasState.pastasIds;
          return Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 800,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selecione a pasta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddPastaDialog(
                                  pastaAluno: true,
                                  alunoUid: widget.alunoUid,
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Nova Pasta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Grid de Pastas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: pastasIds.length,
                        itemBuilder: (context, index) {
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: () => enviarTreinoDialog(
                                pastasIds[index]['id'],
                                widget.treinos!,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[700]!),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      size: 48,
                                      color: Colors.blue[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      pastasIds[index]['nome'],
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Erro inesperado, tente novamente'));
        }
      },
    );
  }
}
