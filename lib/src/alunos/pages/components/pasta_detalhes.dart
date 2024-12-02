import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../treinos/bloc/get_treinos/get_treinos_bloc.dart';
import '../../../treinos/bloc/get_treinos/get_treinos_event.dart';
import '../../../treinos/bloc/get_treinos/get_treinos_state.dart';
import '../../../treinos/editar_treino/new_edit_treino_screen.dart';
import '../../../treinos/pages/galeria/test/criar_treino_personal_screen.dart';
import '../../../utils.dart';

class PastaDetalhes extends StatefulWidget {
  final Map<String, dynamic> pasta;
  final String alunoUid;
  final String? sexo;
  const PastaDetalhes(
      {super.key, required this.pasta, required this.alunoUid, this.sexo});

  @override
  State<PastaDetalhes> createState() => _PastaDetalhesState();
}

class _PastaDetalhesState extends State<PastaDetalhes> {
  @override
  void initState() {
    super.initState();
    // Disparar evento para buscar treinos da pasta
    context.read<GetTreinosBloc>().add(
          BuscarTreinos(widget.alunoUid, widget.pasta['id']),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.pasta['cor'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.folder, color: widget.pasta['cor'], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pasta['nome'],
                        style: SafeGoogleFont(
                          'Outfit',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.pasta['qtdTreinos']} treinos',
                        style: SafeGoogleFont(
                          'Readex Pro',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Implementar ação para criar um novo treino
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovoTreinoPersonalScreen2(
                          funcao: 'addTreino',
                          pastaId: widget.pasta['id'],
                          alunoUid: widget.alunoUid,
                          sexo: widget.sexo,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Criar Treino',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.pasta['cor'],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<GetTreinosBloc, GetTreinosState>(
                builder: (context, state) {
                  if (state is GetTreinosLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GetTreinosError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is GetTreinosLoaded) {
                    final treinos = state.treinos;

                    if (treinos.isEmpty) {
                      return const Center(
                        child: Text('Nenhum treino encontrado nesta pasta'),
                      );
                    }

                    return ListView.builder(
                      itemCount: treinos.length,
                      itemBuilder: (context, index) {
                        final treino = treinos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: widget.pasta['cor'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.fitness_center,
                                  color: widget.pasta['cor']),
                            ),
                            title: Text(
                              treino.titulo == ''
                                  ? 'Sem título'
                                  : treino.titulo,
                              style: SafeGoogleFont('Outfit', fontSize: 16),
                            ),
                            subtitle: Text(
                              '${treino.exercicios.length} exercícios',
                              style: SafeGoogleFont(
                                'Readex Pro',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                //imprimir no log o json completo do treino
                                debugPrint(treino.toMap().toString());
                                // Implementar navegação para o treino
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewEditarTreinoScreen(
                                      treino: treino,
                                      pastaId: widget.pasta['id'],
                                      treinoId: treino.id!,
                                      alunoUid: widget.alunoUid,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
