import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../flutter_flow/ff_button_options.dart';
import '../../pastas/galeria/services/pastas_galeria_services.dart';
import 'components/add_pasta_dialog.dart';
import 'components/update_pasta_dialog.dart';
import '../../screens/treinos_criados/personal_treinos_criados_screen.dart';
import '../../../utils.dart';
import '../../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../../bloc/get_pastas_personal/get_pastas_event.dart';
import '../../bloc/get_pastas_personal/get_pastas_state.dart';
import '../../bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
import 'test/criar_treino_personal_screen.dart';

class TreinosListPage extends StatefulWidget {
  const TreinosListPage({super.key});

  @override
  State<TreinosListPage> createState() => _TreinosListPageState();
}

class _TreinosListPageState extends State<TreinosListPage> {
  final PastasGaleriaServices _pastasGaleriaServices = PastasGaleriaServices();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> titulosDosTreinos = [];

  @override
  void initState() {
    super.initState();
    //context.read<GetPastasPersonalBloc>().add(BuscarPastasPersonal());
  }

  void _mostrarDetalhesPasta(BuildContext context, Map<String, dynamic> pasta) {
    context
        .read<GetTreinosCriadosBloc>()
        .add(BuscarTreinosCriados(pasta['id']));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Theme.of(context).colorScheme.surface, // Adicionado
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
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: pasta['cor'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.folder, color: pasta['cor'], size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pasta['nome'],
                            style: SafeGoogleFont(
                              'Open Sans',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${pasta['qtdTreinos']} treinos',
                            style: SafeGoogleFont(
                              'Open Sans',
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
                              pastaId: pasta['id'],
                              funcao: 'addTreinoPersonal',
                              titulosDosTreinosSalvos: titulosDosTreinos,
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
                        backgroundColor: pasta['cor'],
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
                  child: BlocBuilder<GetTreinosCriadosBloc,
                      GetTreinosCriadosState>(
                    builder: (context, state) {
                      if (state is GetTreinosCriadosLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is GetTreinosCriadosError) {
                        return Center(child: Text(state.message));
                      }

                      if (state is GetTreinosCriadosLoaded) {
                        final treinos = state.treinos;
                        titulosDosTreinos =
                            treinos.map((treino) => treino.titulo).toList();

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
                                    color: pasta['cor'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.fitness_center,
                                      color: pasta['cor']),
                                ),
                                title: Text(
                                  treino.titulo == ''
                                      ? 'Sem título'
                                      : treino.titulo,
                                  style:
                                      SafeGoogleFont('Open Sans', fontSize: 16),
                                ),
                                subtitle: Text(
                                  '${treino.exercicios.length} exercícios',
                                  style: SafeGoogleFont(
                                    'Open Sans',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    //imprimir no log o json completo do treino
                                    //debugPrint(treino.toMap());
                                    // Implementar navegação para o treino
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TreinoCriadoScreen(
                                          treino: treino,
                                          pastaId: pasta['id'],
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
      },
    );
  }

  void _mostrarDialogNovaPasta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPastaDialog(
          pastaAluno: false,
        );
      },
    );
  }

  void _mostrarDialogConfirmacaoExclusao(Map<String, dynamic> pasta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar exclusão',
            style: TextStyle(color: Colors.white),
          ),
          content: Text('Deseja realmente excluir a pasta "${pasta['nome']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  context.loaderOverlay.show();
                  await _pastasGaleriaServices.deletePastaPersonal(
                    uid,
                    pasta['nome'],
                  );
                  if (context.mounted) {
                    context.loaderOverlay.hide();
                    GFToast.showToast(
                      'Pasta excluída com sucesso',
                      context,
                      backgroundColor: Colors.green,
                    );
                    BlocProvider.of<GetPastasPersonalBloc>(context)
                        .add(BuscarPastasPersonal());
                  }
                } catch (e) {
                  if (context.mounted) {
                    GFToast.showToast(
                      'Erro ao excluir pasta',
                      context,
                      backgroundColor: Colors.red,
                    );
                    context.loaderOverlay.hide();
                  }
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogEditarPasta(Map<String, dynamic> pasta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return UpdatePastaDialog(
              pasta: pasta,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return Container(
            width: double.infinity,
            padding: maxWidth > 1200
                ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20)
                : const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pastas de Treinos',
                          style: SafeGoogleFont(
                            'Open Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface, // Adicionado
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organize seus treinos em pastas',
                          style: SafeGoogleFont(
                            'Open Sans',
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7), // Modificado
                          ),
                        ),
                      ],
                    ),
                    FFButtonWidget(
                      onPressed: _mostrarDialogNovaPasta,
                      text: 'Nova pasta',
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 15,
                      ),
                      options: FFButtonOptions(
                        height: 40,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: Colors.green,
                        textStyle: SafeGoogleFont(
                          'Open Sans',
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        elevation: 3,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                BlocBuilder<GetPastasPersonalBloc, GetPastasPersonalState>(
                  builder: (context, state) {
                    if (state is GetPastasPersonalLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is GetPastasPersonalError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is GetPastasPersonalLoaded) {
                      if (state.pastasIds.isEmpty) {
                        return _buildEmptyState();
                      } else {
                        final pastas = state.pastasIds
                            .map((pasta) => {
                                  'id': pasta['id'],
                                  'nome': pasta['nome'],
                                  'qtdTreinos': pasta['qtdTreinos']
                                      as int, // Garantir que é int
                                  'cor': _pastasGaleriaServices
                                      .getColorFromString(pasta['cor']),
                                })
                            .toList();

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth > 1200
                                    ? 4
                                    : constraints.maxWidth > 800
                                        ? 3
                                        : constraints.maxWidth > 600
                                            ? 2
                                            : 1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.2,
                              ),
                              itemCount: pastas.length,
                              itemBuilder: (context, index) {
                                final pasta = pastas[index];
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _mostrarDetalhesPasta(context, pasta),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight:
                                            120, // Altura máxima definida
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface, // Modificado
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .dividerColor, // Modificado
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: pasta['cor']
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.folder,
                                                        color: pasta['cor'],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        pasta['nome'],
                                                        style: SafeGoogleFont(
                                                          'Open Sans',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${pasta['qtdTreinos']} treinos',
                                                  style: SafeGoogleFont(
                                                    'Open Sans',
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: PopupMenuButton<String>(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(
                                                        0.7), // Modificado
                                              ),
                                              itemBuilder:
                                                  (BuildContext context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit,
                                                          size: 18),
                                                      SizedBox(width: 8),
                                                      Text('Editar'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          size: 18),
                                                      SizedBox(width: 8),
                                                      Text('Excluir'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (String value) async {
                                                if (value == 'edit') {
                                                  _mostrarDialogEditarPasta(
                                                      pasta);
                                                } else if (value == 'delete') {
                                                  _mostrarDialogConfirmacaoExclusao(
                                                      pasta);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.6), // Modificado
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma pasta encontrada',
              style: SafeGoogleFont(
                'Open Sans',
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7), // Modificado
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
