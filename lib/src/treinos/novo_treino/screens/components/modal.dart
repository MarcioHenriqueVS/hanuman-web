import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../exercicios/model/exercicio_model.dart';
import '../../../models/serie_model.dart';
import '../../bloc/busca/busca_bloc.dart';
import '../../bloc/busca/events.dart';
import '../../bloc/busca/states.dart';
import '../../bloc/selecionar/events.dart';
import '../../bloc/selecionar/select_bloc.dart';
import '../../bloc/selecionar/states.dart';

class ExerciciosDialog extends StatelessWidget {
  final List<Exercicio> exercicios;
  final TextEditingController _searchController = TextEditingController();

  ExerciciosDialog({super.key, required this.exercicios});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BuscarExercicioBloc(exercicios)),
      ],
      child: BlocBuilder<BuscarExercicioBloc, ExercicioFilterState>(
        builder: (context, state) {
          _searchController.addListener(() {
            context
                .read<BuscarExercicioBloc>()
                .add(UpdateSearchTerm(_searchController.text));
          });

          return _buildDialog(context, state);
        },
      ),
    );
  }

  Widget _buildDialog(BuildContext context, ExercicioFilterState state) {
    List<Exercicio> exerciciosFiltrados = state.filteredExercicios;
    return Stack(
      children: [
        Listener(
          onPointerDown: (_) {
            FocusScope.of(context).unfocus();
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.maxFinite,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.read<ExercicioSelectionBloc>().add(
                                  ClearTempList(),
                                );
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancelar',
                          ),
                        ),
                        const Text(
                          "Exercícios",
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Criar',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[900],
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      hintText: "Procurar exercício",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            25), // Raio da borda arredondada
                        borderSide: BorderSide.none, // Remove a borda
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Filtros:')],
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        state.currentFilter.mecanismo != null
                                            ? Colors.blue
                                            : Colors.green)),
                                onPressed: () {
                                  _showMecanismoOptions(context);
                                },
                                child: Text(
                                  state.currentFilter.mecanismo ??
                                      "Equipamento",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (state.currentFilter.mecanismo != null)
                              IconButton(
                                onPressed: () {
                                  context
                                      .read<BuscarExercicioBloc>()
                                      .add(ClearSpecificFilter('mecanismo'));
                                },
                                icon: const Icon(Icons.clear, size: 20),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        state.currentFilter.grupoMuscular !=
                                                null
                                            ? Colors.blue
                                            : Colors.green)),
                                onPressed: () {
                                  _showGruposMuscularesOptions(context);
                                },
                                child: Text(
                                  state.currentFilter.grupoMuscular ??
                                      "Músculo",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (state.currentFilter.grupoMuscular != null)
                              IconButton(
                                onPressed: () {
                                  context.read<BuscarExercicioBloc>().add(
                                      ClearSpecificFilter('grupoMuscular'));
                                },
                                icon: const Icon(Icons.clear, size: 20),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: exerciciosFiltrados.isNotEmpty
                        ? 2 * exerciciosFiltrados.length - 1
                        : 0,
                    itemBuilder: (BuildContext context, int index) {
                      if (index.isEven) {
                        final itemIndex = index ~/ 2;
                        String nome = exerciciosFiltrados[itemIndex].nome;
                        String fotoUrl = exerciciosFiltrados[itemIndex].fotoUrl;
                        String mecanismo =
                            exerciciosFiltrados[itemIndex].mecanismo;
                        String grupoMuscular =
                            exerciciosFiltrados[itemIndex].grupoMuscular;
                        // String videoUrl =
                        //     exerciciosFiltrados[itemIndex].videoUrl;
                        // List<String> agonistas =
                        //     exerciciosFiltrados[itemIndex].agonista;
                        // List<String> antagonistas =
                        //     exerciciosFiltrados[itemIndex].antagonista;
                        // List<String> sinergistas =
                        //     exerciciosFiltrados[itemIndex].sinergista;

                        return BlocBuilder<ExercicioSelectionBloc,
                            ExercicioSelectionState>(
                          builder: (selectionContext, selectionState) {
                            String currentExercicioName =
                                exerciciosFiltrados[itemIndex].nome;
                            final isSelected = selectionState
                                .tempSelectedExercicios
                                .any((exercicio) =>
                                    exercicio.nome == currentExercicioName);

                            return ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? const Border(
                                          left: BorderSide(
                                              width: 8,
                                              color: Colors.blueAccent))
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(fotoUrl),
                                    radius: 25,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: nome,
                                        ),
                                        TextSpan(
                                          text: ' ($mecanismo)',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    grupoMuscular,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                final String novoId = const Uuid().v4();
                                ExercicioSelecionado exercicioSelecionado =
                                    ExercicioSelecionado(
                                  id: exerciciosFiltrados[itemIndex].id,
                                  newId: novoId,
                                  nome: exerciciosFiltrados[itemIndex].nome,
                                  fotoUrl:
                                      exerciciosFiltrados[itemIndex].fotoUrl,
                                  mecanismo:
                                      exerciciosFiltrados[itemIndex].mecanismo,
                                  grupoMuscular: exerciciosFiltrados[itemIndex]
                                      .grupoMuscular,
                                  videoUrl:
                                      exerciciosFiltrados[itemIndex].videoUrl,
                                  agonista:
                                      exerciciosFiltrados[itemIndex].agonista,
                                  antagonista: exerciciosFiltrados[itemIndex]
                                      .antagonista,
                                  sinergista:
                                      exerciciosFiltrados[itemIndex].sinergista,
                                  series: [
                                    Serie(reps: 0, kg: 0, tipo: 'Normal')
                                  ],
                                );
                                if (isSelected) {
                                  debugPrint('já selecionado');
                                  selectionContext
                                      .read<ExercicioSelectionBloc>()
                                      .add(RemoveExercicioSelection(
                                          exercicioSelecionado));
                                } else {
                                  selectionContext
                                      .read<ExercicioSelectionBloc>()
                                      .add(AddToTempList(exercicioSelecionado));
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return const Divider();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: BlocBuilder<ExercicioSelectionBloc, ExercicioSelectionState>(
            builder: (selectionContext, selectionState) {
              if (selectionState.tempSelectedExercicios.isEmpty) {
                return Container();
              }

              return ElevatedButton(
                onPressed: () {
                  selectionContext
                      .read<ExercicioSelectionBloc>()
                      .add(ConfirmExercicioSelection());
                  Navigator.pop(context, selectionState.selectedExercicios);
                },
                child: Text(
                  'Adicionar ${selectionState.tempSelectedExercicios.length} exercício(s)',
                  style: const TextStyle(fontSize: 17),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMecanismoOptions(BuildContext context) {
    final Map<String, String> mecanismos = {
      'Barra': 'assets/images/hanumanIcon.png',
      'Haltere': 'assets/images/hanumanIcon.png',
      'Máquina': 'assets/images/hanumanIcon.png',
      'Livre': 'assets/images/hanumanIcon.png',
      'Faixa de Resistência': 'assets/images/hanumanIcon.png',
      'Faixa de Suspensão': 'assets/images/hanumanIcon.png',
      'Anilha': 'assets/images/hanumanIcon.png',
      'Kettlebell': 'assets/images/hanumanIcon.png',
      'Bola Suíça': 'assets/images/hanumanIcon.png',
      'Rolo de Espuma': 'assets/images/hanumanIcon.png'
    };

    final bloc = BlocProvider.of<BuscarExercicioBloc>(context);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: bloc,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Selecione o mecanismo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: mecanismos.keys.length,
                  itemBuilder: (context, index) {
                    final mecanismo = mecanismos.keys.elementAt(index);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(mecanismos[mecanismo]!),
                          ),
                          title: Text(
                            mecanismo,
                            style: const TextStyle(fontSize: 17),
                          ),
                          onTap: () {
                            context
                                .read<BuscarExercicioBloc>()
                                .add(FilterByMecanismo(mecanismo));
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGruposMuscularesOptions(BuildContext context) {
    final Map<String, String> gruposMusculares = {
      'Peito': 'assets/images/hanumanIcon.png',
      'Costas': 'assets/images/hanumanIcon.png',
      'Bíceps': 'assets/images/hanumanIcon.png',
      'Tríceps': 'assets/images/hanumanIcon.png',
      'Ombros': 'assets/images/hanumanIcon.png',
      'Abdômen': 'assets/images/hanumanIcon.png',
      'Quadríceps': 'assets/images/hanumanIcon.png',
      'Isquiotibiais': 'assets/images/hanumanIcon.png',
      'Glúteos': 'assets/images/hanumanIcon.png',
      'Panturrilhas': 'assets/images/hanumanIcon.png'
    };

    final bloc = BlocProvider.of<BuscarExercicioBloc>(context);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: bloc,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Selecione um Grupo Muscular",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: gruposMusculares.keys.length,
                  itemBuilder: (context, index) {
                    final grupoMuscular =
                        gruposMusculares.keys.elementAt(index);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage(gruposMusculares[grupoMuscular]!),
                          ),
                          title: Text(
                            grupoMuscular,
                            style: const TextStyle(fontSize: 17),
                          ),
                          onTap: () {
                            context
                                .read<BuscarExercicioBloc>()
                                .add(FilterByGrupoMuscular(grupoMuscular));
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
