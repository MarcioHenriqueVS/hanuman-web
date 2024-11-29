import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/concluir_serie/concluir_serie_bloc.dart';
import '../bloc/concluir_serie/concluir_serie_event.dart';
import '../bloc/concluir_serie/concluir_serie_state.dart';
import '../models/exercicio_treino_model.dart';
import '../models/treino_model.dart';

class StartTreinoScreen extends StatefulWidget {
  final Treino treino;
  const StartTreinoScreen({super.key, required this.treino});

  @override
  State<StartTreinoScreen> createState() => _StartTreinoScreenState();
}

class _StartTreinoScreenState extends State<StartTreinoScreen> {
  Duration _currentDuration = const Duration();
  Timer? _timer;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Para ter certeza de que não há um timer em execução

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDuration += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_currentDuration.inHours.toString().padLeft(2, '0')}:"
            "${_currentDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:"
            "${_currentDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
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
                              backgroundImage: NetworkImage(exercicio.fotoUrl),
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
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(exercicio.notas),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'Intervalo: ${exercicio.intervalo.valor} '
                                  '${intervaloTipoParaString(exercicio.intervalo.tipo)}',
                                  style:
                                      const TextStyle(color: Colors.blueAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'SÉRIE',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'CARGA',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'REPS',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'TIPO',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(flex: 1, child: Icon(Icons.check)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Dados das séries
                      ...List.generate(
                        exercicio.series.length,
                        (serieIndex) {
                          var serie = exercicio.series[serieIndex];

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${serieIndex + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${serie.kg}kg',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${serie.reps} reps',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  serie.tipo.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 35,
                                  width: 35,
                                  child: BlocBuilder<ConcluirSerieBloc,
                                      SerieMarcada>(
                                    builder: (context, state) {
                                      final isSelected = state
                                              .tempVolumeList[index]
                                              ?.contains(serieIndex) ??
                                          false;
                                      return IconButton(
                                        onPressed: () {
                                          context.read<ConcluirSerieBloc>().add(
                                              MarcarSerie(index, serieIndex,
                                                  serie.kg, serie.reps));
                                        },
                                        icon: Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
