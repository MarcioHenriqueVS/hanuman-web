import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final Map<String, bool> hoveredItems = {}; // Substitui o isHovered

  @override
  void initState() {
    super.initState();
    alunosFiltrados = [];
  }

  bool shouldShowExtraColumns(double width) {
    return width < 710 || width > 1460;
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

  String formatarData(String? dataString) {
    if (dataString == null) return '30, Jan. 2023';

    try {
      // Converte a string da data para DateTime
      DateTime data =
          DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').parse(dataString);

      // Lista de meses abreviados em português
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

      // Formata a data no padrão desejado
      return '${data.day}, ${meses[data.month - 1]}. ${data.year}';
    } catch (e) {
      return '30, Jan. 2023'; // Retorna o valor padrão em caso de erro
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showExtraColumns = shouldShowExtraColumns(screenWidth);

    return BlocBuilder<GetAlunosBloc, GetAlunosState>(
      builder: (context, state) {
        if (state is GetAlunosLoading) {
          return const Center(child: CircularProgressIndicator());
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
                                'Outfit',
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
                                'Readex Pro',
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
                        color: Colors.green,
                        textStyle: SafeGoogleFont(
                          'Readex Pro',
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
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    'Nenhum aluno encontrado',
                    style: SafeGoogleFont(
                      'Readex Pro',
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
          List<AlunoModel> alunos = state.alunos;
          alunos.sort((a, b) => (b.lastAtt ?? '').compareTo(a.lastAtt ?? ''));
          if (alunos.length > 5) {
            alunos = alunos.take(5).toList();
          }

          // Inicializa a lista filtrada com todos os alunos apenas se o campo de busca estiver vazio
          if (searchController.text.trim().isEmpty) {
            alunosFiltrados = alunos;
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
                                'Outfit',
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
                                'Readex Pro',
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
                    //             'Readex Pro',
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
                    //           'Readex Pro',
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
                        color: Colors.green,
                        textStyle: SafeGoogleFont(
                          'Readex Pro',
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
                //                 'Readex Pro',
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
                //                   'Readex Pro',
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
                //                   'Readex Pro',
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
                //                 'Readex Pro',
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

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 0,
                                color: Colors.grey[900]!,
                                offset: const Offset(
                                  0,
                                  1,
                                ),
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 8, 12, 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 0, 8, 0),
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: aluno.fotoUrl !=
                                                    null
                                                ? NetworkImage(aluno.fotoUrl!)
                                                : null,
                                            child: aluno.fotoUrl == null
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(4, 0, 0, 0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  onEnter: (_) => setState(() =>
                                                      hoveredItems[aluno.uid] =
                                                          true),
                                                  onExit: (_) => setState(() =>
                                                      hoveredItems[aluno.uid] =
                                                          false),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            PreviaAlunoDialog(
                                                          aluno: aluno,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      aluno.nome,
                                                      style: SafeGoogleFont(
                                                        'Readex Pro',
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
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(0, 4, 0, 0),
                                                  child: Text(
                                                    aluno.email,
                                                    style: SafeGoogleFont(
                                                      'Readex Pro',
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.green),
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
                                        'Readex Pro',
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
                                              const AlignmentDirectional(0, 0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(12, 0, 12, 0),
                                            child: Text(
                                              ativo ? 'Ativo' : 'Inativo',
                                              style: SafeGoogleFont(
                                                'Readex Pro',
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (responsiveVisibility(
                                        context: context,
                                        phone: false,
                                      ))
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'visualizar',
                                              child: Row(
                                                children: [
                                                  Icon(Icons
                                                      .account_circle_outlined),
                                                  SizedBox(width: 8),
                                                  Text('Ver perfil'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'editar',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined),
                                                  SizedBox(width: 8),
                                                  Text('Editar'),
                                                ],
                                              ),
                                            ),
                                            // const PopupMenuItem(
                                            //   value: 'excluir',
                                            //   child: Row(
                                            //     children: [
                                            //       Icon(Icons.delete_outline,
                                            //           color: Colors.red),
                                            //       SizedBox(width: 8),
                                            //       Text('Excluir',
                                            //           style: TextStyle(
                                            //               color: Colors.red)),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'visualizar':
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AlunoProfilePage(
                                                            aluno: aluno),
                                                  ),
                                                );
                                                break;
                                              case 'editar':
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      EditAlunoDialog(
                                                          aluno: aluno),
                                                );
                                                break;
                                              case 'excluir':
                                                //_confirmarExclusao(context, aluno);
                                                break;
                                            }
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
}
