import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:uuid/uuid.dart';
import 'package:web_test/src/treinos/pages/galeria/test/components/add_exercicio_button.dart';
import '../../alunos/pages/avaliacoes/header_prototipo.dart';
import '../../autenticacao/tratamento/error_snackbar.dart';
import '../../autenticacao/tratamento/success_snackbar.dart';
import '../../exercicios/bloc/event.dart';
import '../../exercicios/bloc/exercicios_bloc.dart';
import '../../exercicios/bloc/state.dart';
import '../../exercicios/model/exercicio_model.dart';
import '../../exercicios/services/exercicios_services.dart';
import '../../utils.dart';
import '../bloc/get_treinos/get_treinos_bloc.dart';
import '../bloc/get_treinos/get_treinos_event.dart';
import '../bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
import '../models/exercicio_treino_model.dart';
import '../models/serie_model.dart';
import '../models/treino_model.dart';
import '../novo_treino/bloc/selecionar/events.dart';
import '../novo_treino/bloc/selecionar/select_bloc.dart';
import '../novo_treino/bloc/selecionar/states.dart';
import '../pages/galeria/test/components/build_series_input.dart';
import '../pages/galeria/test/components/loading_screen.dart';
import '../pages/galeria/test/components/treino_vazio.dart';
import '../pages/galeria/test/criar_treino_personal_services.dart';
import '../services/treino_services.dart';
import '../services/treinos_personal_service.dart';

class NewEditarTreinoScreen extends StatefulWidget {
  final Treino? treino;
  final String? alunoUid;
  final String pastaId;
  final String treinoId;
  const NewEditarTreinoScreen(
      {super.key,
      this.treino,
      this.alunoUid,
      required this.pastaId,
      required this.treinoId});

  @override
  State<NewEditarTreinoScreen> createState() => _NewEditarTreinoScreenState();
}

class _NewEditarTreinoScreenState extends State<NewEditarTreinoScreen> {
  final ExerciciosServices exerciciosServices = ExerciciosServices();
  final TreinoServices treinoServices = TreinoServices();
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final List<Serie> seriesList = [Serie(reps: 0, kg: 0, tipo: 'Normal')];
  final Map<String, List<Serie>> exercicioSeriesMap = {};
  final List<TextEditingController> notasControllers = [];
  final Map<String, String> exercicioNotesMap = {};
  TextEditingController titulo = TextEditingController();
  List<String> intervalos = [];
  //String? alunoUid;
  List<TextEditingController> seriesPesoControllers = [];
  List<TextEditingController> seriesRepsControllers = [];
  final Map<String, bool> exercicioExpandido = {};
  final CriarTreinoServices criarTreinoServices = CriarTreinoServices();
  Map<String, String?> exerciseIntervalMap = {};
  String selectedInterval = "5 seg";
  bool _isDeleting = false;
  bool _isChanging = false;

  void changeVisibility() async {
    try {
      setState(() {
        _isChanging = true;
      });
      await treinoServices.alternarStatusDoTreino(
          uid, widget.alunoUid!, widget.pastaId, widget.treinoId);
      setState(() {
        widget.treino!.habilitado = !widget.treino!.habilitado!;
      });
      if (mounted) {
        GFToast.showToast('Status do treino alterado com sucesso', context,
            backgroundColor: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        GFToast.showToast('Erro ao alterar status do treino', context,
            backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChanging = false;
        });
      }
    }
  }

  _showChangeDialog() {
    final statuString = widget.treino!.habilitado! ? 'desativar' : 'ativar';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252525),
          title: const Text(
            'Confirmar alteração',
            style: TextStyle(),
          ),
          content: Text(
            'Deseja realmente $statuString este treino para o aluno?',
            style: TextStyle(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: _isChanging
                  ? CircularProgressIndicator()
                  : const Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.green),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252525),
          title: const Text(
            'Confirmar exclusão',
            style: TextStyle(),
          ),
          content: const Text(
            'Tem certeza que deseja excluir este treino?',
            style: TextStyle(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTreino(widget.treino!.id!);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTreino(String treinoId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await treinoServices.deleteTreino(
          uid, widget.alunoUid, widget.pastaId, treinoId);
      if (mounted) {
        GFToast.showToast('Treino deletado com sucesso', context,
            backgroundColor: Colors.green);
        BlocProvider.of<GetTreinosCriadosBloc>(context)
            .add(BuscarTreinosCriados(widget.pastaId));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        GFToast.showToast('Erro ao deletar treino, tente novamente', context,
            backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void getExercicios() {
    final state = context.read<ExercicioSelectionBloc>().state;
    state.selectedExercicios = [];

    final List<ExercicioSelecionado> exerciciosDoTreino =
        widget.treino!.exercicios.map((exercicio) {
      return ExercicioSelecionado(
        id: exercicio.id,
        newId: exercicio.newId == '' ? const Uuid().v4() : exercicio.newId,
        nome: exercicio.nome,
        grupoMuscular: exercicio.grupoMuscular,
        agonista: exercicio.agonista,
        antagonista: exercicio.antagonista,
        sinergista: exercicio.sinergista,
        mecanismo: exercicio.mecanismo,
        fotoUrl: exercicio.fotoUrl,
        videoUrl: exercicio.videoUrl,
        series: exercicio.series,
        intervalo: exercicio.intervalo,
        notas: exercicio.notas,
      );
    }).toList();
    for (var exercicio in exerciciosDoTreino) {
      debugPrint('debugPrint teste');
      String tipo = criarTreinoServices
          .verificarTipo(exercicio.intervalo!.tipo.toString());
      exerciseIntervalMap[exercicio.newId] =
          '${exercicio.intervalo!.valor.toString()} $tipo';
      state.selectedExercicios.add(exercicio);
    }
  }

  @override
  void initState() {
    debugPrint('tela de edicao de treinos carregada...');
    titulo = TextEditingController(
        text: widget.treino!.titulo == '' ? null : widget.treino!.titulo);
    BlocProvider.of<ExercicioBloc>(context).add(
      LoadExercicios(),
    );
    getExercicios();
    intervalos = criarTreinoServices.getIntervalos();
    for (var exercicio in widget.treino!.exercicios) {
      exercicioExpandido[exercicio.newId] = true; // Inicialmente expandido
    }
    //alunoUid = widget.alunoUid;
    //initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in notasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercicioBloc, ExercicioState>(
      builder: (context, exercicioState) {
        List<Exercicio>? exercicios;
        if (exercicioState is ExercicioLoading) {
          return LoadingScreen();
        } else if (exercicioState is ExercicioLoaded) {
          exercicios = exercicioState.exercicios;
          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              // BlocProvider.of<ElevatedButtonBloc>(context)
              //     .add(ElevatedButtonReset());
            },
            child: Listener(
              onPointerDown: (_) {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      HeaderPrototipo(
                        title: 'Editar treino',
                        subtitle: 'Adicione, edite ou remova informações',
                        button: 'Salvar',
                        icon: false,
                        maxWidth: 820,
                        onSave: () async {
                          // BlocProvider.of<ElevatedButtonBloc>(context)
                          //     .add(ElevatedButtonPressed());
                          final currentState =
                              context.read<ExercicioSelectionBloc>().state;

                          final List<ExercicioSelecionado>
                              selectedExerciciosList =
                              currentState.selectedExercicios;

                          final List<ExercicioTreino> convertedList =
                              selectedExerciciosList.map((exercicio) {
                            List<Serie> seriesForExercicio =
                                criarTreinoServices.getSeriesForExercicio(
                                    exercicio, exercicioSeriesMap);
                            Intervalo intervaloForExercicio =
                                criarTreinoServices.getIntervalForExercicio(
                                    exercicio, exerciseIntervalMap);

                            return ExercicioTreino(
                              id: exercicio.id,
                              newId: exercicio.newId,
                              nome: exercicio.nome,
                              grupoMuscular: exercicio.grupoMuscular,
                              agonista: exercicio.agonista,
                              antagonista: exercicio.antagonista,
                              sinergista: exercicio.sinergista,
                              mecanismo: exercicio.mecanismo,
                              fotoUrl: exercicio.fotoUrl,
                              videoUrl: exercicio.videoUrl,
                              series: seriesForExercicio,
                              intervalo: intervaloForExercicio,
                              notas: exercicioNotesMap[exercicio.newId] ?? "",
                            );
                          }).toList();

                          Treino newTreino = Treino(
                              titulo: titulo.text, exercicios: convertedList);

                          debugPrint('editando treino...');

                          final sucesso = widget.alunoUid != null
                              ? await treinoServices.editTreino(
                                  uid,
                                  widget.alunoUid,
                                  widget.pastaId,
                                  widget.treinoId,
                                  newTreino)
                              : await _treinosPersonalServices.editTreinoCriado(
                                  uid,
                                  widget.pastaId,
                                  widget.treinoId,
                                  newTreino);

                          if (sucesso) {
                            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            widget.alunoUid != null
                                ? BlocProvider.of<GetTreinosBloc>(context).add(
                                    BuscarTreinos(
                                        widget.alunoUid!, widget.pastaId),
                                  )
                                : BlocProvider.of<GetTreinosCriadosBloc>(
                                        context)
                                    .add(
                                    BuscarTreinosCriados(widget.pastaId),
                                  );
                            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            MensagemDeSucesso().showSuccessSnackbar(
                                context, 'Treino editado com sucesso.');
                            // BlocProvider.of<ElevatedButtonBloc>(context)
                            //     .add(ElevatedButtonReset());
                            Navigator.of(context).pop({
                              'titulo': newTreino.titulo,
                              'exercicios': newTreino.exercicios
                            });
                          } else {
                            TratamentoDeErros().showErrorSnackbar(
                                context, 'Erro ao editar treino');
                            // BlocProvider.of<ElevatedButtonBloc>(context)
                            //     .add(ElevatedButtonReset());
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Column(
                              children: [
                                if (widget.alunoUid != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (widget.alunoUid != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: TextButton(
                                                onPressed: _isChanging
                                                    ? null
                                                    : () async {
                                                        final result =
                                                            await _showChangeDialog();
                                                        if (result == true) {
                                                          changeVisibility();
                                                        }
                                                      },
                                                child: _isChanging
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.green),
                                                        ),
                                                      )
                                                    : Row(
                                                        children: [
                                                          Text(
                                                            widget.treino!
                                                                    .habilitado!
                                                                ? 'Desativar treino'
                                                                : 'Ativar treino',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .color),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (widget.alunoUid != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: TextButton(
                                                onPressed: _isDeleting
                                                    ? null
                                                    : () async {
                                                        _showDeleteConfirmationDialog();
                                                      },
                                                child: _isDeleting
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.red),
                                                        ),
                                                      )
                                                    : Text(
                                                        'Excluir treino',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .color),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Form(
                                    child: TextFormField(
                                      controller: titulo,
                                      decoration: InputDecoration(
                                        labelText: 'Nome do treino',
                                        labelStyle: SafeGoogleFont(
                                          'Open Sans',
                                          textStyle: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white30),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.green),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                BlocBuilder<ExercicioSelectionBloc,
                                    ExercicioSelectionState>(
                                  builder: (BuildContext context, state) {
                                    while (notasControllers.length <
                                        state.selectedExercicios.length) {
                                      notasControllers
                                          .add(TextEditingController());
                                    }
                                    while (notasControllers.length >
                                        state.selectedExercicios.length) {
                                      notasControllers.removeLast().dispose();
                                    }
                                    if (state.selectedExercicios.isEmpty) {
                                      return TreinoVazioWidget(
                                          exercicios: exercicios);
                                    } else {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            state.selectedExercicios.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final exercicio =
                                              state.selectedExercicios[index];

                                          exercicioSeriesMap.putIfAbsent(
                                            exercicio.newId,
                                            () {
                                              List<Serie> series = [];
                                              if (exercicio.series != null) {
                                                for (var serie
                                                    in exercicio.series!) {
                                                  series.add(
                                                    Serie(
                                                      reps: serie.reps,
                                                      kg: serie.kg,
                                                      tipo: serie.tipo,
                                                      pesoController:
                                                          TextEditingController(
                                                              text: serie.kg
                                                                  .toString()),
                                                      repsController:
                                                          TextEditingController(
                                                              text: serie.reps
                                                                  .toString()),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                series.add(
                                                  Serie(
                                                    reps: 0,
                                                    kg: 0,
                                                    tipo: 'Normal',
                                                    pesoController:
                                                        TextEditingController(
                                                            text: '0'),
                                                    repsController:
                                                        TextEditingController(
                                                            text: '0'),
                                                  ),
                                                );
                                              }
                                              return series;
                                            },
                                          );

                                          return Column(
                                            children: [
                                              Container(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 15,
                                                      horizontal: 1),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 20,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        exercicio
                                                                            .fotoUrl),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                  '${exercicio.nome} (${exercicio.mecanismo})',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
                                                                  BlocProvider.of<
                                                                              ExercicioSelectionBloc>(
                                                                          context)
                                                                      .add(
                                                                    (RemoveSingleExercicioSelection(
                                                                      state.selectedExercicios[
                                                                          index],
                                                                    )),
                                                                  );
                                                                  state.selectedExercicios.removeWhere((exercicio) =>
                                                                      exercicio
                                                                          .newId ==
                                                                      state
                                                                          .selectedExercicios[
                                                                              index]
                                                                          .newId);
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    exercicioExpandido[
                                                                        exercicio
                                                                            .newId] = !(exercicioExpandido[exercicio.newId] ??
                                                                        true);
                                                                  });
                                                                },
                                                                icon: Icon(
                                                                  exercicioExpandido[exercicio
                                                                              .newId] ??
                                                                          true
                                                                      ? Icons
                                                                          .expand_less
                                                                      : Icons
                                                                          .expand_more,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      AnimatedCrossFade(
                                                        firstChild:
                                                            const SizedBox
                                                                .shrink(),
                                                        secondChild: Column(
                                                          children: [
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      ConstrainedBox(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                            maxWidth:
                                                                                400),
                                                                    child:
                                                                        TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          exercicioNotesMap[exercicio.newId] =
                                                                              value;
                                                                        });
                                                                      },
                                                                      controller: notasControllers
                                                                              .isNotEmpty
                                                                          ? notasControllers[
                                                                              index]
                                                                          : null,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Notas sobre o exercício',
                                                                        labelStyle:
                                                                            SafeGoogleFont(
                                                                          'Open Sans',
                                                                          textStyle: TextStyle(
                                                                              color: Colors.white70,
                                                                              fontSize: 14),
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.white30),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.green),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              children: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    debugPrint(
                                                                        exercicio
                                                                            .newId);
                                                                    criarTreinoServices.showIntervalPicker(
                                                                        context,
                                                                        intervalos,
                                                                        exercicio
                                                                            .newId,
                                                                        exerciseIntervalMap);
                                                                  },
                                                                  child: Text(
                                                                      'Tempo de descanso: ${exerciseIntervalMap[exercicio.newId] ?? '0 seg'}'),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          0),
                                                              child: Column(
                                                                children: [
                                                                  const Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      //Text('SÉRIE'),
                                                                    ],
                                                                  ),
                                                                  BuildSeriesInput(
                                                                      seriesList:
                                                                          exercicioSeriesMap[exercicio
                                                                              .newId]!,
                                                                      exercicioSeriesMap:
                                                                          exercicioSeriesMap,
                                                                      newId: exercicio
                                                                          .newId),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      debugPrint(
                                                                          'exercicio.newId = ${exercicio.newId}');
                                                                      setState(
                                                                          () {
                                                                        exercicioSeriesMap.putIfAbsent(
                                                                            exercicio
                                                                                .newId,
                                                                            () =>
                                                                                []);
                                                                        exercicioSeriesMap[exercicio.newId]!
                                                                            .add(
                                                                          Serie(
                                                                            reps:
                                                                                0,
                                                                            kg: 0,
                                                                            tipo:
                                                                                'Normal',
                                                                            pesoController:
                                                                                TextEditingController(text: '0'),
                                                                            repsController:
                                                                                TextEditingController(text: '0'),
                                                                          ),
                                                                        );
                                                                      });
                                                                    },
                                                                    style:
                                                                        ButtonStyle(
                                                                      backgroundColor:
                                                                          WidgetStatePropertyAll(
                                                                        Colors.grey[
                                                                            700],
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              25),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(Icons
                                                                              .add),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            'Adicionar série',
                                                                            style:
                                                                                TextStyle(fontSize: 16),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // const SizedBox(
                                                            //   height: 10,
                                                            // ),
                                                          ],
                                                        ),
                                                        crossFadeState:
                                                            exercicioExpandido[
                                                                        exercicio
                                                                            .newId] ??
                                                                    true
                                                                ? CrossFadeState
                                                                    .showSecond
                                                                : CrossFadeState
                                                                    .showFirst,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Divider(
                                                height: 2,
                                                color: Colors.grey[800],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                                BlocBuilder<ExercicioSelectionBloc,
                                        ExercicioSelectionState>(
                                    builder:
                                        (selectionContext, selectionState) {
                                  if (selectionState
                                      .selectedExercicios.isNotEmpty) {
                                    return AddExercicioButton(
                                      exercicios: exercicios,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                })
                              ],
                            ),
                          ),
                        ),
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Recarregue a tela'),
          );
        }
      },
    );
  }
}
