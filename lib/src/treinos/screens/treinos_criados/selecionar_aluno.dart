import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../../../alunos/pages/components/alunos_list.dart';
import '../../../alunos/models/aluno_model.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/list_view/infinite_searchable_list_view.dart';
import '../../models/treino_model.dart';

class SelecionarAluno extends StatefulWidget {
  final Treino treino;
  final String pastaId;
  final String treinoId;
  const SelecionarAluno(
      {super.key,
      required this.treino,
      required this.pastaId,
      required this.treinoId});

  @override
  State<SelecionarAluno> createState() => _SelecionarAlunoState();
}

class _SelecionarAlunoState extends State<SelecionarAluno> {
  final TextEditingController _searchController = TextEditingController();
  List<AlunoModel> alunos = [];
  List<AlunoModel> alunosFiltrados = [];
  bool hasMoreData = true;
  bool buscando = false;
  bool buscandoMais = false;
  int page = 1;
  final ScrollController _scrollController = ScrollController();
  bool erroBuscaInicial = false;
  bool semDados = false;

  @override
  void initState() {
    _loadInitialData();
    super.initState();
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void getAlunos() async {
    BlocProvider.of<GetAlunosBloc>(context).add(
      BuscarAlunos(),
    );
  }

  Future<void> _loadInitialData() async {
    debugPrint('chegou aqui');
    context.read<GetAlunosBloc>().add(ReiniciarAlunosBloc());
    setState(() {
      buscando = true;
      hasMoreData = true;
    });
    // Disparar o evento do Bloc para buscar dados iniciais
    BlocProvider.of<GetAlunosBloc>(context).add(BuscarAlunos());
  }

  void _scrollListener() {
    // Verificar se o usuário rolou até o fim da lista
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMoreData && !context.read<GetAlunosBloc>().isFetchingMore) {
        debugPrint('-----------> carregando mais alunos');
        // Disparar evento para carregar mais alunos
        context.read<GetAlunosBloc>().add(
              CarregarMaisAlunos(lastVisibleDocId: alunos.last.uid, alunosJaCarregados: alunos),
            );
      }
    }
  }

  void _searchListener() {
    setState(() {
      String query = _searchController.text.trim().toLowerCase();

      if (query.isEmpty) {
        // Se o campo de pesquisa estiver vazio, mostrar todos os alunos
        alunosFiltrados = List.from(alunos);
      } else {
        // Filtrar a lista de alunos com base na consulta
        alunosFiltrados = alunos.where((aluno) {
          return removeDiacritics(aluno.nome.toLowerCase()).contains(
              removeDiacritics(_searchController.text.trim().toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _loadMoreData() async {
    if (hasMoreData && !buscandoMais) {
      setState(() {
        buscandoMais = true;
      });
      // Disparar evento para carregar mais treinos
      context.read<GetAlunosBloc>().add(
            CarregarMaisAlunos(lastVisibleDocId: alunos.last.uid, alunosJaCarregados: alunos),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      },
      child: Listener(
        onPointerDown: (_) {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Selecione',
                    style: SafeGoogleFont('Open Sans',
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const AddAlunoScreen(),
                  //       ),
                  //     );
                  //   },
                  //   child: const Row(
                  //     children: [
                  //       Icon(
                  //         Icons.add,
                  //         color: Colors.green,
                  //         size: 17,
                  //       ),
                  //       SizedBox(
                  //         width: 3,
                  //       ),
                  //       Text(
                  //         'Adicionar aluno',
                  //         style: TextStyle(
                  //             color: Colors.green,
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          body: BlocListener<GetAlunosBloc, GetAlunosState>(
            listener: (context, treinosState) {
              if (treinosState is GetAlunosLoaded) {
                setState(() {
                  alunos = treinosState.alunos;
                  alunosFiltrados = treinosState.alunos;
                  buscando = false;
                  erroBuscaInicial = false;
                  semDados = false;
                });
              } else if (treinosState is GetAlunosLoadedMore) {
                setState(() {
                  alunos = treinosState.alunos;
                  alunosFiltrados = treinosState.alunos;
                  buscandoMais = false;
                  erroBuscaInicial = false;
                  semDados = false;
                });
              } else if (treinosState is GetAlunosNoMoreData) {
                setState(() {
                  hasMoreData = false;
                  buscandoMais = false;
                });
              } else if (treinosState is GetAlunosLoading) {
                setState(() {
                  buscando = true;
                });
              } else if (treinosState is GetAlunosLoadingMore) {
                setState(() {
                  buscandoMais = true;
                });
              } else if (treinosState is GetAlunosDataIsEmpty) {
                semDados = true;
              } else if (treinosState is GetAlunosError) {
                erroBuscaInicial = true;
              }
            },
            child: InfiniteSearchableListView(
              scrollController: _scrollController,
              hasMoreData: hasMoreData,
              buscandoMais: buscandoMais,
              searchListener: _searchListener,
              //scrollListener: _scrollListener,
              buscando: buscando,
              erroBuscaInicial: erroBuscaInicial,
              semDados: semDados,
              emptyDataMessage: 'Nenhum aluno encontrado',
              labelText: 'Nome do aluno',
              onRefresh: _loadInitialData,
              loadMoreData: _loadMoreData,
              searchController: _searchController,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: alunosFiltrados.length,
                itemBuilder: (context, index) {
                  AlunoModel aluno = alunosFiltrados[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MouseRegion(
                      cursor: WidgetStateMouseCursor.clickable,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.text = aluno.nome;
                          });
                        },
                        child: AlunosCard(
                          aluno: aluno,
                          choose: true,
                          treino: widget.treino,
                          treinoId: widget.treinoId,
                          pastaId: widget.pastaId,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
