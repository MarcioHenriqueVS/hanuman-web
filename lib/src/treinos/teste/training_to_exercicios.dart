import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../autenticacao/tratamento/success_snackbar.dart';
import '../../exercicios/bloc/event.dart';
import '../../exercicios/bloc/exercicios_bloc.dart';
import '../../exercicios/bloc/state.dart';
import '../../exercicios/model/exercicio_model.dart';
import '../../exercicios/screens/exercicio_screen.dart';
import '../../exercicios/services/exercicios_services.dart';
import '../../utils.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../models/exercicio_treino_model.dart';
import '../models/serie_model.dart';
import '../models/treino_model.dart';
import '../novo_treino/bloc/selecionar/events.dart';
import '../novo_treino/bloc/selecionar/select_bloc.dart';
import '../novo_treino/bloc/selecionar/states.dart';
import '../pages/galeria/test/components/add_exercicio_button.dart';
import '../pages/galeria/test/components/build_series_input.dart';
import '../pages/galeria/test/components/loading_screen.dart';
import '../pages/galeria/test/criar_treino_personal_services.dart';
import '../services/treino_services.dart';
import 'models/training_sheet.dart';

class TrainingProgramToExerciciosSelecionadosScreen extends StatefulWidget {
  final List<ExercicioSelecionado> exercicios;
  final String title;
  final int? index;
  final String? messageId;
  const TrainingProgramToExerciciosSelecionadosScreen(
      {super.key,
      required this.exercicios,
      required this.title,
      this.index,
      this.messageId});

  @override
  State<TrainingProgramToExerciciosSelecionadosScreen> createState() =>
      _TrainingProgramToExerciciosSelecionadosScreenState();
}

class _TrainingProgramToExerciciosSelecionadosScreenState
    extends State<TrainingProgramToExerciciosSelecionadosScreen> {
  final ExerciciosServices exerciciosServices = ExerciciosServices();
  final TreinoServices _treinoServices = TreinoServices();
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
  final CriarTreinoServices criarTreinoServices = CriarTreinoServices();
  final Map<String, bool> exercicioExpandido = {};

  Map<String, String?> exerciseIntervalMap = {};

  String selectedInterval = "5 seg";

  void getExercicios() {
    final state = context.read<ExercicioSelectionBloc>().state;

    state.selectedExercicios = [];

    final List<ExercicioSelecionado> exerciciosDoTreino = widget.exercicios;
    for (var exercicio in exerciciosDoTreino) {
      debugPrint('debugPrint teste');
      exerciseIntervalMap[exercicio.newId] =
          '${exercicio.intervalo!.valor.toString()} seg';
      state.selectedExercicios.add(exercicio);
    }
  }

  @override
  void initState() {
    debugPrint('tela de edicao de treinos carregada...');
    // Inicializa os controladores de notas com os valores já existentes
    for (var exercicio in widget.exercicios) {
      notasControllers.add(TextEditingController(
        text: exercicio.notas ??
            '', // Use as notas se existirem, senão use uma string vazia
      ));
    }
    titulo =
        TextEditingController(text: widget.title == '' ? null : widget.title);
    BlocProvider.of<ExercicioBloc>(context).add(
      LoadExercicios(),
    );
    getExercicios();
    intervalos = criarTreinoServices.getIntervalos();

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
              BlocProvider.of<ElevatedButtonBloc>(context)
                  .add(ElevatedButtonReset());
            },
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
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                      Text(
                        'Editar treino',
                        style: SafeGoogleFont('Open Sans',
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                        builder: (context, buttonState) {
                          return TextButton(
                            onPressed: buttonState is ElevatedButtonBlocLoading
                                ? null
                                : () async {
                                    BlocProvider.of<ElevatedButtonBloc>(context)
                                        .add(ElevatedButtonPressed());
                                    final currentState = context
                                        .read<ExercicioSelectionBloc>()
                                        .state;

                                    final List<ExercicioSelecionado>
                                        selectedExerciciosList =
                                        currentState.selectedExercicios;

                                    final List<ExercicioTreino> convertedList =
                                        selectedExerciciosList.map((exercicio) {
                                      List<Serie> seriesForExercicio =
                                          criarTreinoServices
                                              .getSeriesForExercicio(exercicio,
                                                  exercicioSeriesMap);
                                      Intervalo intervaloForExercicio =
                                          criarTreinoServices
                                              .getIntervalForExercicio(
                                                  exercicio,
                                                  exerciseIntervalMap);

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
                                        notas: exercicioNotesMap[
                                                exercicio.newId] ??
                                            "",
                                      );
                                    }).toList();

                                    for (var exercicio in convertedList) {
                                      for (var serie in exercicio.series) {
                                        debugPrint(
                                            ' reps ---> ${serie.reps.toString()}');
                                        debugPrint(
                                            ' rep controller ---> ${serie.repsController!.text}');
                                      }
                                    }

                                    Treino newTreino = Treino(
                                        titulo: titulo.text,
                                        exercicios: convertedList);

                                    for (var exercicio
                                        in newTreino.exercicios) {
                                      for (var serie in exercicio.series) {
                                        debugPrint(
                                            ' reps ---> ${serie.reps.toString()}');
                                        debugPrint(
                                            ' rep controller ---> ${serie.repsController!.text}');
                                      }
                                    }

                                    TrainingSheet treinoEditado =
                                        newTreino.toTrainingSheet(newTreino);

                                    debugPrint('editando treino...');

                                    final sucesso =
                                        await _treinoServices.editTreinoMessage(
                                            uid,
                                            widget.messageId!,
                                            widget.index!,
                                            treinoEditado);

                                    if (sucesso) {
                                      MensagemDeSucesso().showSuccessSnackbar(
                                          context,
                                          'Treino editado com sucesso.');
                                      BlocProvider.of<ElevatedButtonBloc>(
                                              context)
                                          .add(ElevatedButtonReset());
                                      Navigator.of(context).pop({
                                        'titulo': newTreino.titulo,
                                        'exercicios': newTreino.exercicios
                                      });
                                      Navigator.of(context).pop();
                                    } else {
                                      BlocProvider.of<ElevatedButtonBloc>(
                                              context)
                                          .add(ElevatedButtonReset());
                                    }
                                  },
                            child: buttonState is ElevatedButtonBlocLoading
                                ? const CircularProgressIndicator()
                                : const Text('Salvar'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Form(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 1000),
                                  child: Form(
                                    child: TextFormField(
                                      controller: titulo,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[900],
                                        labelText: 'Nome do treino',
                                        labelStyle:
                                            const TextStyle(color: Colors.grey),
                                        prefixIcon: const Icon(
                                          Icons.edit,
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              25), // Raio da borda arredondada
                                          borderSide:
                                              BorderSide.none, // Remove a borda
                                        ),
                                      ),
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
                                  notasControllers.add(TextEditingController());
                                }
                                while (notasControllers.length >
                                    state.selectedExercicios.length) {
                                  notasControllers.removeLast().dispose();
                                }
                                if (state.selectedExercicios.isEmpty) {
                                  return Column(
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.dumbbell,
                                        color: Colors.green,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                          child: Text(
                                            'Adicione um exercício e monte o treino',
                                            style: TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ),
                                      ),
                                      AddExercicioButton(exercicios: exercicios)
                                    ],
                                  );
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: state.selectedExercicios.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final exercicio =
                                          state.selectedExercicios[index];

                                      exercicioSeriesMap.putIfAbsent(
                                        exercicio.newId,
                                        () {
                                          List<Serie> series = [];
                                          if (exercicio.series != null) {
                                            debugPrint(
                                                'series lenght = ${series.length.toString()}');
                                            for (var serie
                                                in exercicio.series!) {
                                              debugPrint(
                                                  'add serie <-------------');
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          17),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ExercicioScreen(
                                                                    exercicio: Exercicio(
                                                                        id: exercicio
                                                                            .id,
                                                                        nome: exercicio
                                                                            .nome,
                                                                        grupoMuscular:
                                                                            exercicio
                                                                                .grupoMuscular,
                                                                        agonista:
                                                                            exercicio
                                                                                .agonista,
                                                                        antagonista:
                                                                            exercicio
                                                                                .antagonista,
                                                                        sinergista:
                                                                            exercicio
                                                                                .sinergista,
                                                                        mecanismo:
                                                                            exercicio
                                                                                .mecanismo,
                                                                        fotoUrl:
                                                                            exercicio
                                                                                .fotoUrl,
                                                                        videoUrl:
                                                                            exercicio.videoUrl),
                                                                  ),
                                                                ),
                                                              );
                                                            },
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
                                                              state
                                                                  .selectedExercicios
                                                                  .removeWhere((exercicio) =>
                                                                      exercicio
                                                                          .newId ==
                                                                      state
                                                                          .selectedExercicios[
                                                                              index]
                                                                          .newId);
                                                            },
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                exercicioExpandido[
                                                                        exercicio
                                                                            .newId] =
                                                                    !(exercicioExpandido[
                                                                            exercicio.newId] ??
                                                                        true);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              exercicioExpandido[
                                                                          exercicio
                                                                              .newId] ??
                                                                      true
                                                                  ? Icons
                                                                      .expand_less
                                                                  : Icons
                                                                      .expand_more,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  AnimatedCrossFade(
                                                    firstChild:
                                                        const SizedBox.shrink(),
                                                    secondChild: Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 10),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextField(
                                                                maxLines: 3,
                                                                minLines: 1,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    exercicioNotesMap[
                                                                        exercicio
                                                                            .newId] = value;
                                                                  });
                                                                },
                                                                controller: notasControllers
                                                                        .isNotEmpty
                                                                    ? notasControllers[
                                                                        index]
                                                                    : null,
                                                                decoration:
                                                                    InputDecoration(
                                                                  fillColor:
                                                                      Colors.grey[
                                                                          900],
                                                                  filled: true,
                                                                  labelText:
                                                                      'Notas sobre o exercício',
                                                                  labelStyle:
                                                                      const TextStyle(
                                                                          color:
                                                                              Colors.grey),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                debugPrint(
                                                                    exercicio
                                                                        .newId);
                                                                criarTreinoServices
                                                                    .showIntervalPicker(
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
                                                            height: 10),
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
                                                                children: [],
                                                              ),
                                                              BuildSeriesInput(
                                                                seriesList:
                                                                    exercicioSeriesMap[
                                                                        exercicio
                                                                            .newId]!,
                                                                exercicioSeriesMap:
                                                                    exercicioSeriesMap,
                                                                newId: exercicio
                                                                    .newId,
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    exercicioSeriesMap.putIfAbsent(
                                                                        exercicio
                                                                            .newId,
                                                                        () =>
                                                                            []);
                                                                    exercicioSeriesMap[
                                                                            exercicio.newId]!
                                                                        .add(
                                                                      Serie(
                                                                        reps: 0,
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
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              25),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(Icons
                                                                          .add),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        'Adicionar série',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
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
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                builder: (selectionContext, selectionState) {
                              if (selectionState
                                  .selectedExercicios.isNotEmpty) {
                                return AddExercicioButton(
                                    exercicios: exercicios);
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
