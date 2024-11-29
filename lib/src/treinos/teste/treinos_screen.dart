import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import '../../autenticacao/tratamento/error_snackbar.dart';
import '../../autenticacao/tratamento/success_snackbar.dart';
import '../../utils.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../bloc/get_treinos/get_treinos_bloc.dart';
import '../bloc/get_treinos/get_treinos_event.dart';
import '../bloc/get_treinos/get_treinos_state.dart';
import '../models/exercicio_treino_model.dart';
import '../models/treino_model.dart';
import '../services/treino_services.dart';
import 'package:diacritic/diacritic.dart';

class TreinosScreen extends StatefulWidget {
  final String alunoUid;
  final String pastaId;
  final String sexo;
  final String? idade;
  const TreinosScreen(
      {super.key,
      required this.alunoUid,
      required this.pastaId,
      required this.sexo,
      this.idade});

  @override
  State<TreinosScreen> createState() => _TreinosScreenState();
}

class _TreinosScreenState extends State<TreinosScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final TreinoServices _treinoServices = TreinoServices();
  final MensagemDeSucesso _mensagemDeSucesso = MensagemDeSucesso();
  final TratamentoDeErros _tratamentoDeErros = TratamentoDeErros();
  final TextEditingController _searchController = TextEditingController();
  List<Treino> treinos = [];
  List<Treino> treinosFiltrados = [];
  bool loading = false;
  bool erro = false;

  @override
  void initState() {
    _searchController.addListener(_searchListener);
    BlocProvider.of<GetTreinosBloc>(context)
        .add(BuscarTreinos(widget.alunoUid, widget.pastaId));
    super.initState();
  }

  void deleteTreino(treinoId) async {
    BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonPressed());
    try {
      await _treinoServices.deleteTreino(
          uid, widget.alunoUid, widget.pastaId, treinoId);
      _mensagemDeSucesso.showSuccessSnackbar(
          context, 'Treino deletado com sucesso!');
      BlocProvider.of<GetTreinosBloc>(context)
          .add(BuscarTreinos(widget.alunoUid, widget.pastaId));
      Navigator.of(context).pop();
    } catch (e) {
      _tratamentoDeErros.showErrorSnackbar(
          context, 'Erro ao deletar treino, tente novamente');
      Navigator.of(context).pop();
    }
    BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
  }

  void _searchListener() {
    setState(() {
      String query = _searchController.text.trim().toLowerCase();

      if (query.isEmpty) {
        // Se o campo de pesquisa estiver vazio, mostrar todos os alunos
        treinosFiltrados = List.from(treinos);
      } else {
        // Filtrar a lista de alunos com base na consulta
        treinosFiltrados = treinos.where((treino) {
          return removeDiacritics(treino.titulo.toLowerCase())
              .contains(removeDiacritics(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Listener(
            onPointerDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Text('Treinos'),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(
                          '/novotreino/:${widget.alunoUid}/:${widget.pastaId}',
                          extra: {
                            'alunoUid': widget.alunoUid,
                            'pastaId': widget.pastaId,
                            'sexo': widget.sexo,
                          },
                        );
                      },
                      icon: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            'Adicionar treino',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: BlocListener<GetTreinosBloc, GetTreinosState>(
                listener: (context, treinosState) {
                  if (treinosState is GetTreinosInitial) {
                    setState(() {
                      loading = true;
                    });
                  } else if (treinosState is GetTreinosLoading) {
                    setState(() {
                      loading = true;
                    });
                  } else if (treinosState is GetTreinosError) {
                    setState(() {
                      loading = false;
                      erro = true;
                    });
                  } else if (treinosState is GetTreinosLoaded) {
                    setState(() {
                      loading = false;
                      erro = false;
                      treinos = treinosState.treinos;
                      treinosFiltrados = treinosState.treinos;
                    });
                  }
                },
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : erro
                        ? const Center(
                            child: Text('Erro, atualize a tela'),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                    width: width * 0.9,
                                    height: 0.5,
                                    color: Colors.grey),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: TextFormField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              labelText: 'Título do treino',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey[600]),
                                              suffixIcon: Icon(
                                                Icons.search_outlined,
                                                color: Colors.grey[600]!,
                                              ),
                                              fillColor: Colors.grey[900],
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(
                                                    25), // Raio da borda arredondada
                                                borderSide: BorderSide
                                                    .none, // Remove a borda
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.filter_list_outlined,
                                          size: 35,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: treinosFiltrados.length,
                                  itemBuilder: (context, index) {
                                    Treino treino = treinosFiltrados[index];
                                    return Slidable(
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) async {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    GFFloatingWidget(
                                                  verticalPosition:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.3,
                                                  child: GFAlert(
                                                    backgroundColor:
                                                        Colors.grey[900],
                                                    titleTextStyle:
                                                        const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 18,
                                                            decoration:
                                                                TextDecoration
                                                                    .none),
                                                    title: 'Atenção!',
                                                    content: const Text(
                                                      'Deseja excluir este treino? Esta ação não poderá ser desfeita.',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                    bottomBar: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: GFButton(
                                                            color: Colors.grey,
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            shape: GFButtonShape
                                                                .pills,
                                                            child: const Text(
                                                              'Voltar',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ),
                                                        BlocBuilder<
                                                            ElevatedButtonBloc,
                                                            ElevatedButtonBlocState>(
                                                          builder: (context,
                                                              buttonState) {
                                                            return GFButton(
                                                              onPressed:
                                                                  buttonState
                                                                          is ElevatedButtonBlocLoading
                                                                      ? null
                                                                      : () {
                                                                          deleteTreino(
                                                                              treinosFiltrados[index].id);
                                                                        },
                                                              shape:
                                                                  GFButtonShape
                                                                      .pills,
                                                              color: Colors.red,
                                                              icon: buttonState
                                                                      is ElevatedButtonBlocLoading
                                                                  ? const CircularProgressIndicator()
                                                                  : const Icon(
                                                                      Icons
                                                                          .keyboard_arrow_right,
                                                                      color: GFColors
                                                                          .WHITE),
                                                              position:
                                                                  GFPosition
                                                                      .end,
                                                              text: 'Excluir',
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Excluir',
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  treino.titulo == ''
                                                      ? 'Sem título'
                                                      : treino.titulo,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TreinoDetailsScreen(
                                                  treino: treino,
                                                  alunoUid: widget.alunoUid,
                                                  pastaId: widget.pastaId,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TreinoDetailsScreen extends StatefulWidget {
  final Treino treino;
  final String alunoUid;
  final String pastaId;

  const TreinoDetailsScreen(
      {super.key,
      required this.treino,
      required this.alunoUid,
      required this.pastaId});

  @override
  State<TreinoDetailsScreen> createState() => _TreinoDetailsScreenState();
}

class _TreinoDetailsScreenState extends State<TreinoDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                //Text(treino.titulo == '' ? 'Sem título' : treino.titulo),
                IconButton(
                  onPressed: () async {
                    debugPrint('editar treino <----------------------');
                    final result =
                        // await Navigator.push(context,
                        //     '/aluno/:uid/treinos/:pastaId/editarTreino/:treinoId',
                        //     arguments: {
                        //       'treino': widget.treino,
                        //       'alunoUid': widget.alunoUid,
                        //       'pastaId': widget.pastaId,
                        //       'treinoId': widget.treino.id
                        //     }) as Map<String, dynamic>?;
                        await context.push(
                      '/aluno/:${widget.alunoUid}/treinos/:${widget.pastaId}/editarTreino/:${widget.treino.id}',
                      extra: {
                        'alunoUid': widget.alunoUid,
                        'pastaId': widget.pastaId,
                        'treinoId': widget.treino.id,
                        'treino': widget.treino,
                      },
                    );

                    if (result != null) {
                      setState(() {
                        result as Map<String, dynamic>;
                        widget.treino.titulo = result['titulo'];
                        widget.treino.exercicios = result['exercicios'];
                      });
                    }
                  },
                  icon: const Text(
                    'Editar treino',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          widget.treino.titulo == ''
                              ? 'Sem título'
                              : widget.treino.titulo,
                          style: SafeGoogleFont('Open Sans',
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: width * 0.9, height: 0.5, color: Colors.grey),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Padding(
                //   padding: const EdgeInsets.all(10),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => StartTreinoScreen(
                //             treino: treino,
                //           ),
                //         ),
                //       );
                //     },
                //     child: const Text('Começar treino'),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       //const Text('Exercícios'),
                //       TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           'Editar treino',
                //           style: TextStyle(color: Colors.green),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.treino.exercicios.length,
                  itemBuilder: (context, index) {
                    ExercicioTreino exercicio = widget.treino.exercicios[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(exercicio.fotoUrl),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  child: Text(
                                    '${exercicio.nome} (${exercicio.mecanismo})',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          //const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                exercicio.notas == ''
                                    ? const SizedBox(
                                        height: 10,
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                exercicio.notas == '' ? 0 : 10),
                                        child: Row(
                                          children: [
                                            Text('obs: ${exercicio.notas}'),
                                          ],
                                        ),
                                      ),
                                //const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      'Intervalo: ${exercicio.intervalo.valor} '
                                      '${intervaloTipoParaString(exercicio.intervalo.tipo)}',
                                      style: const TextStyle(
                                          color: Colors.blueAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(1.5),
                              },
                              //border: TableBorder.all(),
                              children: [
                                // Cabeçalho da Tabela
                                const TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text('SÉRIE',
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text('CARGA',
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text('REPS',
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text('TIPO',
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),

                                // Dados das séries
                                ...List.generate(
                                  exercicio.series.length,
                                  (serieIndex) {
                                    var serie = exercicio.series[serieIndex];

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            '${serieIndex + 1}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            '${serie.kg}kg',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            '${serie.reps} reps',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            // ignore: unnecessary_string_interpolations
                                            '${serie.tipo.toString()}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String intervaloTipoParaString(IntervaloTipo tipo) {
    switch (tipo) {
      case IntervaloTipo.segundos:
        return 'segundos';
      case IntervaloTipo.minutos:
        return 'minutos';
      default:
        return '';
    }
  }
}
