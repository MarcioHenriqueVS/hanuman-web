import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;
import '../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../exercicios/bloc/event.dart';
import '../../../exercicios/bloc/exercicios_bloc.dart';
import '../../../exercicios/bloc/state.dart';
import '../../../exercicios/model/exercicio_model.dart';
import '../../../exercicios/services/exercicios_services.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../../bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
import '../../models/exercicio_treino_model.dart';
import '../../models/serie_model.dart';
import '../../models/treino_model.dart';
import '../../novo_treino/bloc/selecionar/events.dart';
import '../../novo_treino/bloc/selecionar/select_bloc.dart';
import '../../novo_treino/bloc/selecionar/states.dart';
import '../../novo_treino/screens/components/modal.dart';
import '../../services/treino_services.dart';
import '../../services/treinos_personal_service.dart';
import '../../teste/dialog_treino_ia.dart';

class NovoTreinoPersonalScreen extends StatefulWidget {
  //final List<Exercicio> exercicios;

  final String pastaId;

  const NovoTreinoPersonalScreen({
    super.key,
    required this.pastaId,
  });

  @override
  State<NovoTreinoPersonalScreen> createState() =>
      _NovoTreinoPersonalScreenState();
}

class _NovoTreinoPersonalScreenState extends State<NovoTreinoPersonalScreen> {
  final ExerciciosServices exerciciosServices = ExerciciosServices();
  final TreinoServices _treinoServices = TreinoServices();
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final List<Serie> seriesList = [Serie(reps: 0, kg: 0, tipo: 'Normal')];
  final Map<String, List<Serie>> exercicioSeriesMap = {};
  final List<TextEditingController> notasControllers = [];
  final Map<String, String> exercicioNotesMap = {};
  final TextEditingController titulo = TextEditingController();
  List<String> intervalos = [];
  bool isEmpty = true;
  final Map<String, bool> exercicioExpandido = {};
  //String? alunoUid;
  bool habilitado = false;

  String dataFormatada =
      intl.DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.now());

  List<String> getIntervalos() {
    List<String> intervalos = [];
    for (int i = 5; i <= 3 * 60 + 55; i += 5) {
      // De 5 em 5 segundos até 3 minutos e 55 segundos
      if (i < 60) {
        intervalos.add("$i seg");
      } else {
        final minutos = i ~/ 60;
        final segundos = i % 60;
        intervalos.add("$minutos:${segundos.toString().padLeft(2, '0')} min");
      }
    }
    for (int i = 4; i <= 7; i++) {
      // De 1 em 1 minuto de 4 até 7 minutos
      intervalos.add("$i:00 min");
    }
    return intervalos;
  }

  Map<String, String?> exerciseIntervalMap = {};

  String selectedInterval = "5 seg";

  void addNewExercicio() {
    notasControllers.add(TextEditingController());
  }

  @override
  void initState() {
    BlocProvider.of<ExercicioBloc>(context).add(
      LoadExercicios(),
    );
    final state = context.read<ExercicioSelectionBloc>().state;
    state.selectedExercicios = [];

    intervalos = getIntervalos();

    titulo.text = dataFormatada;
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
          return Scaffold(
            appBar: AppBar(),
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
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
                        child: const SizedBox(
                          width: 57,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Cancelar'),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Criar treino',
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
                                          getSeriesForExercicio(exercicio);
                                      Intervalo intervaloForExercicio =
                                          getIntervalForExercicio(exercicio);

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

                                    Treino newTreino = Treino(
                                        titulo: titulo.text,
                                        exercicios: convertedList
                                        );

                                    final sucesso =
                                        await _treinosPersonalServices
                                            .addTreinoCriado(
                                                uid, widget.pastaId, newTreino);

                                    if (sucesso) {
                                      BlocProvider.of<GetTreinosCriadosBloc>(
                                              context)
                                          .add(
                                        BuscarTreinosCriados(widget.pastaId),
                                      );
                                      MensagemDeSucesso().showSuccessSnackbar(
                                          context,
                                          'Treino criado com sucesso.');
                                      BlocProvider.of<ElevatedButtonBloc>(
                                              context)
                                          .add(ElevatedButtonReset());
                                    } else {
                                      BlocProvider.of<ElevatedButtonBloc>(
                                              context)
                                          .add(ElevatedButtonReset());
                                    }
                                  },
                            child: buttonState is ElevatedButtonBlocLoading
                                ? const CircularProgressIndicator()
                                : const SizedBox(
                                    width: 57,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Salvar'),
                                      ],
                                    ),
                                  ),
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
                                  constraints: BoxConstraints(
                                      maxWidth: isEmpty ? 600 : 1000),
                                  child: TextFormField(
                                    controller: titulo,
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey[900],
                                      filled: true,
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
                                      // enabledBorder: OutlineInputBorder(
                                      //   borderSide:
                                      //       BorderSide(color: Colors.grey),
                                      // ),
                                      // focusedBorder: OutlineInputBorder(
                                      //   borderSide:
                                      //       BorderSide(color: Colors.blue),
                                      // ),
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
                                            'Adicione um exercício e comece a montar o seu treino',
                                            style: TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxWidth: 400),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            ExerciciosDialog(
                                                exercicios: exercicios!);
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext context) {
                                                return ExerciciosDialog(
                                                    exercicios: exercicios!);
                                              },
                                            );
                                            context
                                                .read<ExercicioSelectionBloc>()
                                                .add(
                                                    ConfirmExercicioSelection());
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Adicionar exercício',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      kIsWeb
                                          ? const SizedBox(
                                              height: 10,
                                            )
                                          : const SizedBox.shrink(),
                                      ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxWidth: 400),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const DialogTreinoIa(),
                                              ),
                                            );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25, vertical: 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Criar treino com IA',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  isEmpty = false;
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 1200),
                                    child: ListView.builder(
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
                                            () => [
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
                                                  )
                                                ]);
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
                                                            onPressed: () {},
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
                                                                      exercicioNotesMap[
                                                                              exercicio.newId] =
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
                                                                    fillColor:
                                                                        Colors.grey[
                                                                            900],
                                                                    filled:
                                                                        true,
                                                                    //icon: Icon(Icons.edit),
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                            color:
                                                                                Colors.grey),
                                                                    labelText:
                                                                        'Notas sobre o exercício',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25), // Raio da borda arredondada
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none, // Remove a borda
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
                                                              onPressed: () {
                                                                debugPrint(
                                                                    exercicio
                                                                        .newId);
                                                                _showIntervalPicker(
                                                                    context,
                                                                    intervalos,
                                                                    exercicio
                                                                        .newId);
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
                                                              buildSeriesInput(
                                                                  exercicioSeriesMap[
                                                                      exercicio
                                                                          .newId]!,
                                                                  exercicio
                                                                      .newId),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  debugPrint(
                                                                      'exercicio.newId = ${exercicio.newId}');
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
                                                                            5,
                                                                      ),
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
                                                    duration: const Duration(
                                                        milliseconds: 300),
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
                                            color: Colors.grey[900],
                                          ),
                                        ],
                                      );
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                            BlocBuilder<ExercicioSelectionBloc,
                                    ExercicioSelectionState>(
                                builder: (selectionContext, selectionState) {
                              if (selectionState
                                  .selectedExercicios.isNotEmpty) {
                                return ElevatedButton(
                                  onPressed: () async {
                                    ExerciciosDialog(exercicios: exercicios!);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return ExerciciosDialog(
                                            exercicios: exercicios!);
                                      },
                                    );
                                    context
                                        .read<ExercicioSelectionBloc>()
                                        .add(ConfirmExercicioSelection());
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Adicionar exercício',
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            })
                          ],
                        ),
                      ),
                    ),
                    //),
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

  Widget buildSeriesInput(List<Serie> seriesList, String newId) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 850),
      child: Column(
        children: seriesList.asMap().entries.map(
          (entry) {
            int index = entry.key;
            Serie serie = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'SÉRIE',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            //width: 80,
                            height: 40,
                            child: InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    "${index + 1}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'PESO(kg)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(
                              () {
                                serie.kg = int.tryParse(value) ?? 0;
                              },
                            );
                          },
                          controller: serie.pesoController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'REPS',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              serie.reps = int.tryParse(value) ?? 0;
                            });
                          },
                          controller: serie.repsController, // Preserva o valor
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'TIPO',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: buildSeriesButton(
                                serie, index, seriesIcons, context),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 60,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            ' ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          index != 0
                              ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(
                                        () {
                                          // Remove a série na posição do índice
                                          exercicioSeriesMap[newId]
                                              ?.removeAt(index);

                                          // Atualiza a lista depois da remoção
                                          exercicioSeriesMap[newId] = List.from(
                                            exercicioSeriesMap[newId] ?? [],
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 17,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 16.5,
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, intervalos, nome) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Confirmar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  diameterRatio: 1.5,
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      exerciseIntervalMap[nome] = intervalos[index];
                    });
                  },
                  children: intervalos
                      .map<Widget>(
                          (intervalo) => Center(child: Text(intervalo)))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Serie> getSeriesForExercicio(ExercicioSelecionado exercicio) {
    // Obter a lista de séries para o id do exercício
    return exercicioSeriesMap[exercicio.newId] ?? [];
  }

  Intervalo getIntervalForExercicio(ExercicioSelecionado exercicio) {
    // Obter o valor do intervalo como uma string
    String? intervalString = exerciseIntervalMap[exercicio.newId];
    if (intervalString == null) {
      return Intervalo(valor: 0, tipo: IntervaloTipo.segundos);
    }

    if (intervalString.contains("min")) {
      int? mins = int.tryParse(intervalString.split(" ")[0]);
      return Intervalo(valor: mins ?? 0, tipo: IntervaloTipo.minutos);
    } else {
      int? secs = int.tryParse(intervalString.split(" ")[0]);
      return Intervalo(valor: secs ?? 0, tipo: IntervaloTipo.segundos);
    }
  }

  final Map<String, IconData> seriesIcons = {
    'Série de aquecimento': Icons.local_fire_department,
    'Série normal': Icons.fitness_center,
    'Série de falha': Icons.sports_gymnastics,
    'Série de drop': Icons.trending_down,
  };

  Widget buildSeriesButton(Serie serie, int index,
      Map<String, IconData> seriesIcons, BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green[800],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tipo de Série',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...[
                        'Série de aquecimento',
                        'Série normal',
                        'Série de falha',
                        'Série de drop'
                      ]
                          .map((tipo) => Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      serie.tipo = tipo;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  hoverColor: Colors.grey[800],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            seriesIcons[tipo],
                                            color: Colors.green[700],
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          tipo,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              seriesIcons[serie.tipo] ?? Icons.fitness_center,
              size: 20.0,
              color: Colors.green[700],
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.green[700]),
          ],
        ),
      ),
    );
  }
}
