import 'package:diacritic/diacritic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/get_alunos/get_alunos_bloc.dart';
import '../models/aluno_model.dart';
import 'aluno_profile_page.dart';
import '../services/alunos_services.dart';
import '../../flutter_flow/ff_button_options.dart';
import '../../utils.dart';
import '../../widgets_comuns/flutter_flow/flutter_flow_helpers.dart';
import 'components/add_aluno_dialog.dart';
import '../bloc/delete_aluno/delete_aluno_bloc.dart';
import 'components/edit_aluno_dialog.dart';

class AlunosListPage extends StatefulWidget {
  const AlunosListPage({super.key});

  @override
  State<AlunosListPage> createState() => _AlunosListPageState();
}

class _AlunosListPageState extends State<AlunosListPage> {
  final int _itemsPorPagina = 10;
  int _paginaAtual = 1;
  List<AlunoModel> alunos = [];
  List<AlunoModel> alunosFiltrados = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  final AlunosServices _alunosServices = AlunosServices();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<AlunoModel> filtrarAlunos(List<AlunoModel> alunos, String searchText) {
    if (searchText.isEmpty) return alunos;

    searchText = removeDiacritics(searchText.toLowerCase());
    return alunos.where((aluno) {
      final nomeNormalizado = removeDiacritics(aluno.nome.toLowerCase());
      return nomeNormalizado.contains(searchText);
    }).toList();
  }

  Future<void> _confirmarExclusao(
      BuildContext context, AlunoModel aluno) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (context) => DeleteAlunoBloc(_alunosServices),
          child: BlocConsumer<DeleteAlunoBloc, DeleteAlunoState>(
            listener: (context, state) {
              if (state is DeleteAlunoSuccess) {
                Navigator.of(dialogContext).pop();
                context.read<GetAlunosBloc>().add(BuscarAlunos());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aluno excluído com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state is DeleteAlunoError) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir aluno: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text(
                  'Confirmar exclusão',
                  style: TextStyle(color: Colors.white),
                ),
                content:
                    Text('Deseja realmente excluir o aluno ${aluno.nome}?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: state is DeleteAlunoLoading
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  state is DeleteAlunoLoading
                      ? const ElevatedButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : TextButton(
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            context.read<DeleteAlunoBloc>().add(
                                  DeleteAlunoStarted(aluno.uid, uid),
                                );
                          },
                        ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //context.read<GetAlunosBloc>().add(BuscarAlunos());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          return _buildEmptyState();
        }

        if (state is GetAlunosLoaded) {
          alunos = state.alunos;
          alunosFiltrados = filtrarAlunos(alunos, searchController.text);
        }

        if (state is GetAlunosLoadedMore) {
          alunos = state.alunos;
          alunosFiltrados = filtrarAlunos(alunos, searchController.text);
        }

        alunosFiltrados.sort(
          (a, b) => (removeDiacritics(a.nome).toLowerCase()).trim().compareTo(
                removeDiacritics(b.nome).toLowerCase().trim(),
              ),
        );

        final totalPaginas = (alunosFiltrados.length / _itemsPorPagina).ceil();
        final startIndex = (_paginaAtual - 1) * _itemsPorPagina;
        final endIndex = startIndex + _itemsPorPagina;
        final alunosPaginados = alunosFiltrados.sublist(
            startIndex,
            endIndex > alunosFiltrados.length
                ? alunosFiltrados.length
                : endIndex);

        return SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return Padding(
                padding: maxWidth > 1200
                    ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20)
                    : const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: 1500,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(
                          0,
                          1,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                        const EdgeInsetsDirectional.fromSTEB(
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 12, 0),
                                    child: Text(
                                      'Gerencie seus alunos cadastrados.',
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
                            if (responsiveVisibility(
                              context: context,
                              phone: false,
                              tablet: false,
                            ))
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 16, 0),
                                child: SizedBox(
                                  width: 270,
                                  child: TextFormField(
                                    controller: searchController,
                                    autofocus: false,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Procurar aluno...',
                                      hintStyle: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[800]!,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.green,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFF57636C),
                                        size: 20,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        alunosFiltrados =
                                            filtrarAlunos(alunos, value);
                                        _paginaAtual =
                                            1; // Reset para primeira página ao pesquisar
                                      });
                                    },
                                    style: SafeGoogleFont(
                                      'Open Sans',
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
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
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 16, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (responsiveVisibility(
                                    context: context,
                                    phone: false,
                                    tablet: false,
                                  ))
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ID',
                                        style: SafeGoogleFont(
                                          'Open Sans',
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Dados do aluno',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
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
                                        'Última atualização',
                                        style: SafeGoogleFont(
                                          'Open Sans',
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Ações',
                                      textAlign: TextAlign.end,
                                      style: SafeGoogleFont(
                                        'Open Sans',
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alunosPaginados.length,
                          itemBuilder: (context, index) {
                            final aluno = alunosPaginados[index];
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 1),
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 16, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '#${aluno.uid.substring(0, 8)}',
                                              style: SafeGoogleFont(
                                                'Open Sans',
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
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
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                    child: aluno.fotoUrl != null
                                                        ? Image.network(
                                                            aluno.fotoUrl!,
                                                            width: 32,
                                                            height: 32,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return Container(
                                                                width: 32,
                                                                height: 32,
                                                                color:
                                                                    Colors.grey,
                                                                child: const Icon(
                                                                    Icons
                                                                        .person),
                                                              );
                                                            },
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width: 32,
                                                                height: 32,
                                                                color:
                                                                    Colors.grey,
                                                                child: const Icon(
                                                                    Icons
                                                                        .person),
                                                              );
                                                            },
                                                          )
                                                        : Container(
                                                            width: 32,
                                                            height: 32,
                                                            color: Colors.grey,
                                                            child: const Icon(
                                                                Icons.person),
                                                          ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            4, 0, 0, 0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          aluno.nome,
                                                          style: SafeGoogleFont(
                                                            'Open Sans',
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                            style:
                                                                SafeGoogleFont(
                                                              'Open Sans',
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .green),
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
                                                          .fromSTEB(
                                                          12, 0, 12, 0),
                                                  child: Text(
                                                    ativo ? 'Ativo' : 'Inativo',
                                                    style: SafeGoogleFont(
                                                      'Open Sans',
                                                      textStyle:
                                                          const TextStyle(
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
                                                          Icon(Icons
                                                              .edit_outlined),
                                                          SizedBox(width: 8),
                                                          Text('Editar'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'excluir',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color:
                                                                  Colors.red),
                                                          SizedBox(width: 8),
                                                          Text('Excluir',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 'visualizar':
                                                        debugPrint(
                                                            'Visualizar aluno ${aluno.uid}');
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AlunoProfilePage(
                                                                    aluno:
                                                                        aluno),
                                                          ),
                                                        );
                                                        break;
                                                      case 'editar':
                                                        debugPrint(
                                                            'Editar aluno ${aluno.uid}');
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              EditAlunoDialog(
                                                                  aluno: aluno),
                                                        );
                                                        break;
                                                      case 'excluir':
                                                        _confirmarExclusao(
                                                            context, aluno);
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Página $_paginaAtual de $totalPaginas',
                                style: SafeGoogleFont(
                                  'Open Sans',
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _paginaAtual > 1
                                    ? () => setState(() => _paginaAtual--)
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _paginaAtual < totalPaginas
                                    ? () => setState(() => _paginaAtual++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
          Icon(Icons.person_outlined, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Nenhum aluno encontrado',
            style: SafeGoogleFont(
              'Open Sans',
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
    );
  }
}
