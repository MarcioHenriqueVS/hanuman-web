import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../flutter_flow/ff_button_options.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/flutter_flow/flutter_flow_helpers.dart';
import '../../bloc/get_alunos/get_alunos_bloc.dart';
import '../../models/aluno_model.dart';
import '../aluno_profile_page.dart';
import 'add_aluno_dialog.dart';
import 'edit_aluno_dialog.dart';
import 'previa_aluno_dialog.dart';

class AlunosTable extends StatefulWidget {
  const AlunosTable({super.key});

  @override
  State<AlunosTable> createState() => _AlunosTableState();
}

class _AlunosTableState extends State<AlunosTable> {
  final TextEditingController searchController = TextEditingController();
  List<AlunoModel> alunosFiltrados = [];
  final Map<String, bool> hoveredItems = {};
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    hoveredItems.clear(); // Limpar o estado inicial
  }

  List<AlunoModel> filtrarAlunos(List<AlunoModel> alunos, String searchText) {
    if (searchText.trim().isEmpty) return alunos;

    searchText = removeDiacritics(searchText.toLowerCase().trim());
    var resultados = alunos.where((aluno) {
      final nomeNormalizado = removeDiacritics(aluno.nome.toLowerCase());
      final emailNormalizado = removeDiacritics(aluno.email.toLowerCase());
      return nomeNormalizado.contains(searchText) ||
          emailNormalizado.contains(searchText);
    }).toList();

    return resultados;
  }

  String formatarData(Timestamp? data) {
    if (data == null) return '30, Jan. 2023';

    try {
      DateTime dateTime = data.toDate();
      List<String> meses = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez'
      ];
      return '${dateTime.day}, ${meses[dateTime.month - 1]}. ${dateTime.year}';
    } catch (e) {
      return '30, Jan. 2023';
    }
  }

  void _showPopupMenu(
      BuildContext context, AlunoModel aluno, RelativeRect position) {
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'visualizar',
          child: Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 8),
              Text('Ver perfil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'visualizar':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlunoProfilePage(aluno: aluno),
            ),
          );
          break;
        case 'editar':
          showDialog(
            context: context,
            builder: (context) => EditAlunoDialog(aluno: aluno),
          );
          break;
      }
    });
  }

  bool shouldShowExtraColumns(double width) {
    return width < 710 || width > 1460;
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).scaffoldBackgroundColor,
        highlightColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                        child: Text(
                          'Alunos',
                          style: SafeGoogleFont(
                            'Open Sans',
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 4, 12, 0),
                        child: Text(
                          'Alunos atualizados recentemente',
                          style: SafeGoogleFont(
                            'Open Sans',
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão desabilitado durante loading
                Opacity(
                  opacity: 0.5,
                  child: FFButtonWidget(
                    onPressed: null,
                    text: 'Adicionar aluno',
                    icon: const Icon(Icons.add_rounded, size: 15),
                    options: FFButtonOptions(
                      height: 40,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      color: Colors.green,
                      textStyle: SafeGoogleFont(
                        'Open Sans',
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Lista de shimmer
            Shimmer.fromColors(
              baseColor: Theme.of(context).scaffoldBackgroundColor,
              highlightColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 100,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: 80,
                              height: 12,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 60,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showExtraColumns = shouldShowExtraColumns(screenWidth);

    return BlocBuilder<GetAlunosBloc, GetAlunosState>(
      builder: (context, state) {
        if (state is GetAlunosLoading || state is GetAlunosInitial) {
          return _buildShimmerEffect();
        }

        if (state is GetAlunosError) {
          debugPrint('Erro ao buscar alunos: ${state.message}');
          return Center(child: Text('Erro ao buscar alunos'));
        }

        if (state is GetAlunosDataIsEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //if (showExtraColumns)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 12, 0),
                            child: Text(
                              'Alunos',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 4, 12, 0),
                            child: Text(
                              'Alunos atualizados recentemente',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddAlunoDialog(),
                        );
                      },
                      text: 'Adicionar aluno',
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
                        color: Theme.of(context).primaryColor,
                        textStyle: SafeGoogleFont(
                          'Open Sans',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
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
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    'Nenhum aluno encontrado',
                    style: SafeGoogleFont(
                      'Open Sans',
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is GetAlunosLoaded) {
          final List<AlunoModel> alunos = state.alunos;
          // Ordenar alunos por data
          alunos.sort((a, b) {
            if (a.lastAtt == null) return 1;
            if (b.lastAtt == null) return -1;
            return b.lastAtt!.compareTo(a.lastAtt!);
          });

          // Pegar os 5 primeiros
          final exibicaoAlunos = alunos.take(5).toList();

          // Atualizar lista filtrada apenas quando necessário
          if (searchController.text.trim().isEmpty && alunosFiltrados.isEmpty) {
            alunosFiltrados = exibicaoAlunos;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //if (showExtraColumns)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 12, 0),
                            child: Text(
                              'Alunos',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 4, 12, 0),
                            child: Text(
                              'Alunos atualizados recentemente',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // if (responsiveVisibility(
                    //   context: context,
                    //   phone: false,
                    //   tablet: false,
                    // ))
                    //   Padding(
                    //     padding:
                    //         const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                    //     child: SizedBox(
                    //       width: 270,
                    //       child: TextFormField(
                    //         controller: searchController,
                    //         autofocus: false,
                    //         textCapitalization: TextCapitalization.sentences,
                    //         obscureText: false,
                    //         decoration: InputDecoration(
                    //           isDense: true,
                    //           hintText: 'Procurar aluno...',
                    //           hintStyle: SafeGoogleFont(
                    //             'Open Sans',
                    //             textStyle: const TextStyle(
                    //               fontSize: 12,
                    //             ),
                    //           ),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //               color: Colors.grey[800]!,
                    //               width: 2,
                    //             ),
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderSide: const BorderSide(
                    //               color: Colors.green,
                    //               width: 2,
                    //             ),
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           errorBorder: OutlineInputBorder(
                    //             borderSide: const BorderSide(
                    //               color: Color(0x00000000),
                    //               width: 2,
                    //             ),
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           focusedErrorBorder: OutlineInputBorder(
                    //             borderSide: const BorderSide(
                    //               color: Color(0x00000000),
                    //               width: 2,
                    //             ),
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           prefixIcon: const Icon(
                    //             Icons.search_rounded,
                    //             color: Color(0xFF57636C),
                    //             size: 20,
                    //           ),
                    //         ),
                    //         onChanged: (value) {
                    //           setState(() {
                    //             alunosFiltrados = filtrarAlunos(alunos, value);
                    //           });
                    //         },
                    //         style: SafeGoogleFont(
                    //           'Open Sans',
                    //           textStyle: const TextStyle(
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    FFButtonWidget(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddAlunoDialog(),
                        );
                      },
                      text: 'Adicionar aluno',
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
                        color: Theme.of(context).primaryColor,
                        textStyle: SafeGoogleFont(
                          'Open Sans',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
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
                // Padding(
                //   padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                //   child: Container(
                //     width: double.infinity,
                //     height: 40,
                //     decoration: BoxDecoration(
                //       color: Colors.grey[800],
                //       borderRadius: const BorderRadius.only(
                //         bottomLeft: Radius.circular(0),
                //         bottomRight: Radius.circular(0),
                //         topLeft: Radius.circular(8),
                //         topRight: Radius.circular(8),
                //       ),
                //     ),
                //     child: Padding(
                //       padding:
                //           const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.max,
                //         children: [
                //           Expanded(
                //             flex: 4,
                //             child: Text(
                //               'Dados do aluno',
                //               style: SafeGoogleFont(
                //                 'Open Sans',
                //                 textStyle: const TextStyle(
                //                   fontSize: 12,
                //                 ),
                //               ),
                //             ),
                //           ),
                //           if (responsiveVisibility(
                //             context: context,
                //             phone: false,
                //           ))
                //             Expanded(
                //               flex: 2,
                //               child: Text(
                //                 'Última atualização',
                //                 style: SafeGoogleFont(
                //                   'Open Sans',
                //                   textStyle: const TextStyle(
                //                     fontSize: 12,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           if (showExtraColumns)
                //             Expanded(
                //               child: Text(
                //                 'Status',
                //                 style: SafeGoogleFont(
                //                   'Open Sans',
                //                   textStyle: const TextStyle(
                //                     fontSize: 12,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           Expanded(
                //             child: Text(
                //               'Ações',
                //               textAlign: TextAlign.end,
                //               style: SafeGoogleFont(
                //                 'Open Sans',
                //                 textStyle: const TextStyle(
                //                   fontSize: 12,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 15),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: alunosFiltrados.length, // Usar lista filtrada
                  itemBuilder: (context, index) {
                    final aluno = alunosFiltrados[index]; // Usar lista filtrada
                    final ativo = aluno.status ?? false;
                    final hoverKey = '${aluno.uid}_$index'; // Criar chave única

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) =>
                            setState(() => hoveredItems[aluno.uid] = true),
                        onExit: (_) =>
                            setState(() => hoveredItems[aluno.uid] = false),
                        child: GestureDetector(
                          onTapUp: (TapUpDetails details) {
                            final RenderBox overlay = Overlay.of(context)
                                .context
                                .findRenderObject() as RenderBox;
                            final position = RelativeRect.fromRect(
                              details.globalPosition & const Size(40, 40),
                              Offset.zero & overlay.size,
                            );
                            _showPopupMenu(context, aluno, position);
                          },
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 5, 0, 5),
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 0,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 8, 12, 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 8, 0),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage:
                                                    aluno.fotoUrl != null
                                                        ? NetworkImage(
                                                            aluno.fotoUrl!)
                                                        : null,
                                                child: aluno.fotoUrl == null
                                                    ? const Icon(Icons.person)
                                                    : null,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(4, 0, 0, 0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      aluno.nome,
                                                      style: SafeGoogleFont(
                                                        'Open Sans',
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration: hoveredItems[
                                                                      aluno
                                                                          .uid] ==
                                                                  true
                                                              ? TextDecoration
                                                                  .underline
                                                              : TextDecoration
                                                                  .none,
                                                          decorationThickness:
                                                              2,
                                                          decorationStyle:
                                                              TextDecorationStyle
                                                                  .solid,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              0, 4, 0, 0),
                                                      child: Text(
                                                        aluno.email,
                                                        style: SafeGoogleFont(
                                                          'Open Sans',
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.green,
                                                            decoration: hoveredItems[
                                                                        aluno
                                                                            .uid] ==
                                                                    true
                                                                ? TextDecoration
                                                                    .underline
                                                                : TextDecoration
                                                                    .none,
                                                            decorationThickness:
                                                                2,
                                                            decorationStyle:
                                                                TextDecorationStyle
                                                                    .solid,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                    ))
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          formatarData(aluno.lastAtt),
                                          style: SafeGoogleFont(
                                            'Open Sans',
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (showExtraColumns)
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: ativo
                                                    ? Colors.green
                                                    : Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0, 0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(12, 0, 12, 0),
                                                child: Text(
                                                  ativo ? 'Ativo' : 'Inativo',
                                                  style: SafeGoogleFont(
                                                    'Open Sans',
                                                    textStyle: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (responsiveVisibility(
                                            context: context,
                                            phone: false,
                                          ))
                                            IconButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      PreviaAlunoDialog(
                                                    aluno: aluno,
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('Erro desconhecido'));
        }
      },
    );
  }

  @override
  void dispose() {
    hoveredItems.clear();
    super.dispose();
  }
}
