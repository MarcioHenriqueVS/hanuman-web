import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../alunos/pages/avaliacoes/header_prototipo.dart';
import '../../../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../../../exercicios/model/exercicio_model.dart';
import '../../../../../exercicios/services/exercicios_services.dart';
import '../../../../../utils.dart';
import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../../bloc/get_pastas/get_pastas_bloc.dart';
import '../../../../bloc/get_pastas/get_pastas_event.dart';
import '../../../../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../../../../bloc/get_pastas_personal/get_pastas_event.dart';
import '../../../../models/exercicio_treino_model.dart';
import '../../../../models/serie_model.dart';
import '../../../../models/treino_model.dart';
import '../../../../novo_treino/bloc/selecionar/events.dart';
import '../../../../novo_treino/bloc/selecionar/select_bloc.dart';
import '../../../../novo_treino/bloc/selecionar/states.dart';
import '../../../../services/treino_services.dart';
import '../../../../services/treinos_personal_service.dart';
import '../criar_treino_personal_services.dart';
import 'add_exercicio_button.dart';
import 'build_series_input.dart';
import 'treino_vazio.dart';

class LoadedScreen extends StatefulWidget {
  final String pastaId;
  final List<Exercicio>? exercicios;
  final String funcao;
  final String? alunoUid;
  final List<String> titulosDosTreinosSalvos;
  const LoadedScreen(
      {super.key,
      required this.pastaId,
      required this.exercicios,
      required this.funcao,
      this.alunoUid,
      required this.titulosDosTreinosSalvos});

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
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();
  final TreinoServices _treinoServices = TreinoServices();
  bool? habilitado;

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

  String getNextAvailableTitle(String baseTitle) {
    // Lista para armazenar os números encontrados
    List<int> numbersUsed = [];

    // Procura por títulos que começam com o baseTitle
    for (String savedTitle in widget.titulosDosTreinosSalvos) {
      if (savedTitle == baseTitle) {
        numbersUsed.add(1); // Considera o título base como número 1
        continue;
      }

      // Verifica se o título salvo segue o padrão "baseTitle (n)"
      if (savedTitle.startsWith('$baseTitle (')) {
        final match = RegExp(r'\((\d+)\)$').firstMatch(savedTitle);
        if (match != null) {
          numbersUsed.add(int.parse(match.group(1)!));
        }
      }
    }

    // Se não houver números usados, retorna o título base
    if (numbersUsed.isEmpty) {
      return baseTitle;
    }

    // Encontra o próximo número disponível
    numbersUsed.sort();
    int nextNumber = numbersUsed.length + 1;

    // Retorna o título com o próximo número
    return '$baseTitle ($nextNumber)';
  }

  Future<void> _salvarTreino() async {
    if (widget.funcao == 'addTreino') {
      // Primeiro, exibe o diálogo de visibilidade
      final resposta = await _treinoServices.showVisibilityDialog(context);
      if (resposta == null) return; // Usuário cancelou o diálogo

      habilitado =
          resposta; // Atualiza o valor de habilitado com base na resposta
    }

    String tituloFinal = titulo.text.trim();

    // Se o título já existe, pega o próximo disponível
    if (widget.titulosDosTreinosSalvos.contains(tituloFinal)) {
      tituloFinal = getNextAvailableTitle(tituloFinal);
    }

    // ...resto do código de _salvarTreino permanece igual, mas use tituloFinal ao invés de titulo.text.trim()...
    final currentState = context.read<ExercicioSelectionBloc>().state;
    final List<ExercicioSelecionado> selectedExerciciosList =
        currentState.selectedExercicios;

    final List<ExercicioTreino> convertedList =
        selectedExerciciosList.map((exercicio) {
      List<Serie> seriesForExercicio = criarTreinoPersonalServices
          .getSeriesForExercicio(exercicio, exercicioSeriesMap);
      Intervalo intervaloForExercicio = criarTreinoPersonalServices
          .getIntervalForExercicio(exercicio, exerciseIntervalMap);

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

    Treino newTreino = Treino(titulo: tituloFinal, exercicios: convertedList);

    bool sucesso = false;

    if (widget.funcao == 'addTreinoPersonal') {
      sucesso = await _treinosPersonalServices.addTreinoCriado(
          uid, widget.pastaId, newTreino);
    } else if (widget.funcao == 'addTreino') {
      sucesso = await _treinoServices.addTreino(
          uid, widget.alunoUid!, widget.pastaId, newTreino, habilitado!);
    }

    if (sucesso) {
      widget.funcao == 'addTreinoPersonal'
          ? BlocProvider.of<GetPastasPersonalBloc>(context)
              .add(BuscarPastasPersonal())
          : BlocProvider.of<GetPastasBloc>(context)
              .add(BuscarPastas(widget.alunoUid!));
      MensagemDeSucesso()
          .showSuccessSnackbar(context, 'Treino criado com sucesso.');
    } else {
      TratamentoDeErros()
          .showErrorSnackbar(context, 'Erro ao criar treino, tente novamente');
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                HeaderPrototipo(
                  title: 'Editar treino',
                  subtitle: 'Adicione, edite ou remova informações',
                  button: 'Salvar',
                  icon: false,
                  maxWidth: 815,
                  onSave: () async {
                    await _salvarTreino();
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Form(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: isEmpty ? 600 : 800),
                                child: TextFormField(
                                  controller: titulo,
                                  decoration: InputDecoration(
                                    labelText: 'Nome do treino',
                                    labelStyle: SafeGoogleFont(
                                      'Open Sans',
                                      textStyle: TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                      borderRadius: BorderRadius.circular(8),
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
                                  constraints: BoxConstraints(maxWidth: 800),
                                  child: ListView.builder(
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
                                                                    labelText:
                                                                        'Notas sobre o exercício',
                                                                    labelStyle:
                                                                        SafeGoogleFont(
                                                                      'Open Sans',
                                                                      textStyle: TextStyle(
                                                                          color: Colors
                                                                              .white70,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white30),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.green),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
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
                                                                seriesList: criarTreinoPersonalServices
                                                                    .getSeriesForExercicio(
                                                                        exercicio,
                                                                        exercicioSeriesMap),
                                                                exercicioSeriesMap:
                                                                    exercicioSeriesMap,
                                                                newId: exercicio
                                                                    .newId,
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
                                                                      exercicioSeriesMap.putIfAbsent(
                                                                          exercicio
                                                                              .newId,
                                                                          () =>
                                                                              []);
                                                                      exercicioSeriesMap[
                                                                              exercicio.newId]!
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
                                                                    },
                                                                  );
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
                          AddExercicioButton(
                            exercicios: widget.exercicios,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
