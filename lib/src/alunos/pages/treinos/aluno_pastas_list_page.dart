import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../flutter_flow/ff_button_options.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_bloc.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_event.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_state.dart';
import '../../../treinos/pages/galeria/components/add_pasta_dialog.dart';
import '../../../treinos/pages/galeria/components/update_pasta_dialog.dart';
import '../../../treinos/pastas/aluno/services/pastas_services.dart';
import '../../../utils.dart';
import '../components/pasta_detalhes.dart';

class AlunoPastasListPage extends StatefulWidget {
  final String alunoUid;
  final String sexo;
  const AlunoPastasListPage(
      {super.key, required this.alunoUid, required this.sexo});

  @override
  State<AlunoPastasListPage> createState() => _AlunoPastasListPageState();
}

class _AlunoPastasListPageState extends State<AlunoPastasListPage> {
  final PastasServices _pastasServices = PastasServices();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    context.read<GetPastasBloc>().add(BuscarPastas(widget.alunoUid));
  }

  void _mostrarDetalhesPasta(BuildContext context, Map<String, dynamic> pasta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PastaDetalhes(
          pasta: pasta,
          alunoUid: widget.alunoUid,
          sexo: widget.sexo,
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
              alunoUid: widget.alunoUid,
            );
          },
        );
      },
    );
  }

  void _mostrarDialogNovaPasta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPastaDialog(
          pastaAluno: true,
          alunoUid: widget.alunoUid,
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
                  await _pastasServices.deletePasta(
                    uid,
                    widget.alunoUid,
                    pasta['id'],
                  );
                  if (context.mounted) {
                    context.loaderOverlay.hide();
                    GFToast.showToast(
                      'Pasta excluída com sucesso',
                      context,
                      backgroundColor: Colors.green,
                    );
                    BlocProvider.of<GetPastasBloc>(context)
                        .add(BuscarPastas(widget.alunoUid));
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma pasta encontrada',
            style: SafeGoogleFont(
              'Open Sans',
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayWidgetBuilder: (_) => SpinKitCubeGrid(
        color: Colors.green,
        size: 50.0,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pastas de Treinos',
                                  style: SafeGoogleFont(
                                    'Open Sans',
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Organize seus treinos em pastas',
                                  style: SafeGoogleFont(
                                    'Open Sans',
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
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
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
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
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        BlocBuilder<GetPastasBloc, GetPastasState>(
                          builder: (context, state) {
                            if (state is GetPastasLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is GetPastasError) {
                              return Center(child: Text(state.message));
                            }
                            if (state is GetPastasLoaded) {
                              final pastas = state.pastasIds
                                  .map((pasta) => {
                                        'id': pasta['id'],
                                        'nome': pasta['nome'],
                                        'qtdTreinos': pasta['qtdTreinos']
                                            as int, // Garantir que é int
                                        'cor': _pastasServices
                                            .getColorFromString(pasta['cor']),
                                      })
                                  .toList();

                              if (pastas.isEmpty) {
                                return _buildEmptyState();
                              }

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          constraints.maxWidth > 1200
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
                                          onTap: () => _mostrarDetalhesPasta(
                                              context, pasta),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              maxHeight:
                                                  120, // Altura máxima definida
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey[800]!),
                                            ),
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: pasta[
                                                                      'cor']
                                                                  .withOpacity(
                                                                      0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Icon(
                                                              Icons.folder,
                                                              color:
                                                                  pasta['cor'],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Text(
                                                              pasta['nome'],
                                                              style:
                                                                  SafeGoogleFont(
                                                                'Open Sans',
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                                  child:
                                                      PopupMenuButton<String>(
                                                    icon: const Icon(
                                                        Icons.more_vert,
                                                        color: Colors.grey),
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        [
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
                                                    onSelected:
                                                        (String value) async {
                                                      if (value == 'edit') {
                                                        _mostrarDialogEditarPasta(
                                                            pasta);
                                                      } else if (value ==
                                                          'delete') {
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
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
