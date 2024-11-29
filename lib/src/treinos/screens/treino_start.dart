import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils.dart';
import '../models/exercicio_treino_model.dart';
import '../models/treino_model.dart';

class TreinoFinalizadoDetailsScreen extends StatefulWidget {
  final TreinoFinalizado treino;
  const TreinoFinalizadoDetailsScreen({super.key, required this.treino});

  @override
  State<TreinoFinalizadoDetailsScreen> createState() =>
      _TreinoFinalizadoDetailsScreenState();
}

class _TreinoFinalizadoDetailsScreenState
    extends State<TreinoFinalizadoDetailsScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.treino.titulo.isEmpty
                    ? 'Exercícios'
                    : widget.treino.titulo),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duração',
                            style: SafeGoogleFont('Open Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            widget.treino.duracao!,
                            style: SafeGoogleFont('Open Sans',
                                fontSize: 17, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 80,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Volume',
                            style: SafeGoogleFont('Open Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            '${widget.treino.volume!}kg',
                            style: SafeGoogleFont('Open Sans', fontSize: 17),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 80,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Séries',
                            style: SafeGoogleFont('Open Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            widget.treino.series!,
                            style: SafeGoogleFont('Open Sans', fontSize: 17),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: width * 0.99, height: 0.5, color: Colors.grey),
                const SizedBox(
                  height: 20,
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
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    exercicio.notas.isNotEmpty
                                        ? Text('Nota: ${exercicio.notas}')
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                                exercicio.notas.isNotEmpty
                                    ? const SizedBox(height: 10)
                                    : const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined),
                                    const SizedBox(
                                      width: 4,
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

                              return Container(
                                color: serie.check != null
                                    ? serie.check!
                                        ? Colors.green
                                        : Colors.transparent
                                    : Colors.transparent,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                serie.check!
                                                    ? Icons.check
                                                    : Icons.clear,
                                                size: 20,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 25,
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
