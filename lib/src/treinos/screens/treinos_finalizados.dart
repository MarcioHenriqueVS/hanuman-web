import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:refresh_loadmore/refresh_loadmore.dart';
import '../../utils.dart';
import '../bloc/get_treinos_finalizados/get_treinos_finalizados_bloc.dart';
import '../bloc/get_treinos_finalizados/get_treinos_finalizados_event.dart';
import '../bloc/get_treinos_finalizados/get_treinos_finalizados_state.dart';
import '../models/treino_model.dart';
import 'treinos_criados/components/treino_finalizado_card.dart';

class TreinosFinalizadosScreen extends StatefulWidget {
  final String alunoUid;
  final String nomeAluno;
  final String fotoUrl;
  const TreinosFinalizadosScreen(
      {super.key,
      required this.alunoUid,
      required this.fotoUrl,
      required this.nomeAluno});

  @override
  State<TreinosFinalizadosScreen> createState() =>
      _TreinosFinalizadosScreenState();
}

class _TreinosFinalizadosScreenState extends State<TreinosFinalizadosScreen> {
  final ScrollController _scrollController = ScrollController();
  List<TreinoFinalizado> treinos = [];
  bool hasMoreData = true;
  bool buscando = false;
  bool buscandoMais = false;
  int page = 1;
  bool erroBuscaInicial = false;
  bool semDados = false;

  @override
  void initState() {
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    debugPrint('chegou aqui');
    context
        .read<GetTreinosFinalizadosBloc>()
        .add(ReiniciarTreinosFinalizados());
    setState(() {
      buscando = true;
      hasMoreData = true;
      erroBuscaInicial = false;
      semDados = false;
    });
    // Disparar o evento do Bloc para buscar dados iniciais
    BlocProvider.of<GetTreinosFinalizadosBloc>(context)
        .add(BuscarTreinosFinalizados(widget.alunoUid, null));
  }

  void _scrollListener() {
    // Verificar se o usuário rolou até o fim da lista
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMoreData &&
          !context.read<GetTreinosFinalizadosBloc>().isFetchingMore) {
        // Disparar evento para carregar mais treinos
        context.read<GetTreinosFinalizadosBloc>().add(
              CarregarMaisTreinosFinalizados(
                  widget.alunoUid, treinos.last.id!, treinos),
            );
      }
    }
  }

  // Future<void> _loadMoreData() async {
  //   if (hasMoreData && !buscandoMais) {
  //     setState(() {
  //       buscandoMais = true;
  //     });

  //     // Disparar evento para carregar mais treinos
  //     context.read<GetTreinosFinalizadosBloc>().add(
  //           CarregarMaisTreinosFinalizados(
  //               widget.alunoUid, treinos.last.id!, treinos),
  //         );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        context
            .read<GetTreinosFinalizadosBloc>()
            .add(ReiniciarTreinosFinalizados());
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Histórico',
                style: SafeGoogleFont('Open Sans'),
              ),
            ),
            body: BlocListener<GetTreinosFinalizadosBloc,
                GetTreinosFinalizadosState>(
              listener: (context, treinosState) {
                if (treinosState is GetTreinosFinalizadosLoaded) {
                  setState(() {
                    treinos = treinosState.treinos;
                    buscando = false;
                    erroBuscaInicial = false;
                    semDados = false;
                  });
                } else if (treinosState is GetTreinosFinalizadosLoadedMore) {
                  setState(() {
                    treinos = treinosState.treinos;
                    buscandoMais = false;
                    erroBuscaInicial = false;
                    semDados = false;
                  });
                } else if (treinosState is GetTreinosFinalizadosNoMoreData) {
                  setState(() {
                    hasMoreData = false;
                    buscandoMais = false;
                  });
                } else if (treinosState is GetTreinosFinalizadosLoading) {
                  setState(() {
                    buscando = true;
                  });
                } else if (treinosState is GetTreinosFinalizadosLoadingMore) {
                  setState(() {
                    buscandoMais = true;
                  });
                } else if (treinosState is GetTreinosFinalizadosError) {
                  setState(() {
                    erroBuscaInicial = true;
                  });
                } else if (treinosState is GetTreinosFinalizadosIsEmpty) {
                  setState(() {
                    semDados = true;
                  });
                }
              },
              child: erroBuscaInicial
                  ? const Center(
                      child: Text('Erro, atualize a tela.'),
                    )
                  : semDados
                      ? const Center(
                          child: Text('Nenhum treino encontrado'),
                        )
                      : buscando
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : RefreshLoadmore(
                              scrollController: _scrollController,
                              onRefresh: _loadInitialData,
                              //onLoadmore: _loadMoreData,
                              isLastPage: !hasMoreData,
                              noMoreWidget: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Você chegou ao fim',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              child: TreinoFinalizadoCard(
                                treinos: treinos,
                                nomeAluno: widget.nomeAluno,
                                buscandoMais: buscandoMais,
                              ),
                            ),
            ),
          ),
        ),
      ),
    );
  }
}
