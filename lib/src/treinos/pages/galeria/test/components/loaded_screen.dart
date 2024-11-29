import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../exercicios/model/exercicio_model.dart';
import '../../../../../exercicios/services/exercicios_services.dart';
import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../../models/serie_model.dart';
import '../../../../novo_treino/bloc/selecionar/events.dart';
import '../../../../novo_treino/bloc/selecionar/select_bloc.dart';
import '../../../../novo_treino/bloc/selecionar/states.dart';
import '../criar_treino_personal_services.dart';
import 'add_exercicio_button.dart';
import 'app_bar.dart';
import 'build_series_input.dart';
import 'treino_vazio.dart';

class LoadedScreen extends StatefulWidget {
  final String pastaId;
  final List<Exercicio>? exercicios;
  final String funcao;
  final String? alunoUid;
  const LoadedScreen(
      {super.key,
      required this.pastaId,
      required this.exercicios,
      required this.funcao,
      this.alunoUid});

  @override
  State<LoadedScreen> createState() => _LoadedScreenState();
}

class _LoadedScreenState extends State<LoadedScreen> {
  final ExerciciosServices exerciciosServices = ExerciciosServices();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final List<Serie> seriesList = [Serie(reps: 0, kg: 0, tipo: 'Normal')];
  final Map<String, List<Serie>> exercicioSeriesMap = {};
  final List<TextEditingController> notasControllers = [];
  final Map<String, String> exercicioNotesMap = {};
  final TextEditingController titulo = TextEditingController();
  List<String> intervalos = [];
  bool isEmpty = true;
  final Map<String, bool> exercicioExpandido = {};
  CriarTreinoServices criarTreinoPersonalServices = CriarTreinoServices();
  Map<String, String?> exerciseIntervalMap = {};
  String selectedInterval = "5 seg";

  String dataFormatada =
      DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.now());

  @override
  void initState() {
    final state = context.read<ExercicioSelectionBloc>().state;
    state.selectedExercicios = [];
    intervalos = criarTreinoPersonalServices.getIntervalos();

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
            automaticallyImplyLeading: false,
            title: TreinoAppBar(
              pastaId: widget.pastaId,
              exerciseIntervalMap: exerciseIntervalMap,
              exercicioSeriesMap: exercicioSeriesMap,
              titulo: titulo.text,
              uid: uid,
              exercicioNotesMap: exercicioNotesMap,
              funcao: widget.funcao,
              alunoUid: widget.alunoUid,
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
                            constraints:
                                BoxConstraints(maxWidth: isEmpty ? 600 : 1000),
                            child: TextFormField(
                              controller: titulo,
                              decoration: InputDecoration(
                                fillColor: Colors.grey[900],
                                filled: true,
                                labelText: 'Nome do treino',
                                labelStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(
                                  Icons.edit,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none, // Remove a borda
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
                            return TreinoVazioWidget(
                                exercicios: widget.exercicios!);
                          } else {
                            isEmpty = false;
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 1200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.selectedExercicios.length,
                                itemBuilder: (BuildContext context, int index) {
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 1),
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
                                                                  fontSize: 17),
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
                                                                        exercicio
                                                                            .newId] ??
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
                                                          color: Colors.grey,
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
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    maxWidth:
                                                                        400),
                                                            child: TextField(
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
                                                                //icon: Icon(Icons.edit),
                                                                labelStyle:
                                                                    const TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                labelText:
                                                                    'Notas sobre o exercício',
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
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
                                                            debugPrint(exercicio
                                                                .newId);
                                                            criarTreinoPersonalServices
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
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 0),
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
                                                            seriesList: criarTreinoPersonalServices
                                                                .getSeriesForExercicio(
                                                                    exercicio,
                                                                    exercicioSeriesMap),
                                                            exercicioSeriesMap:
                                                                exercicioSeriesMap,
                                                            newId:
                                                                exercicio.newId,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              debugPrint(
                                                                  'exercicio.newId = ${exercicio.newId}');
                                                              setState(
                                                                () {
                                                                  exercicioSeriesMap
                                                                      .putIfAbsent(
                                                                          exercicio
                                                                              .newId,
                                                                          () =>
                                                                              []);
                                                                  exercicioSeriesMap[
                                                                          exercicio
                                                                              .newId]!
                                                                      .add(
                                                                    Serie(
                                                                      reps: 0,
                                                                      kg: 0,
                                                                      tipo:
                                                                          'Normal',
                                                                      pesoController:
                                                                          TextEditingController(
                                                                              text: '0'),
                                                                      repsController:
                                                                          TextEditingController(
                                                                              text: '0'),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStatePropertyAll(
                                                                Colors
                                                                    .grey[700],
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
                                                                    width: 5,
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
                                                  ],
                                                ),
                                                crossFadeState:
                                                    exercicioExpandido[exercicio
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
                      AddExercicioButton(
                        exercicios: widget.exercicios,
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
