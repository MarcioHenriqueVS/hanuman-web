import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils.dart';
import '../../models/exercicio_treino_model.dart';
import '../../models/treino_model.dart';

class TreinoCriadoDetails extends StatefulWidget {
  final Treino treino;
  final String pastaId;
  const TreinoCriadoDetails(
      {super.key, required this.treino, required this.pastaId});

  @override
  State<TreinoCriadoDetails> createState() => _TreinoCriadoDetailsState();
}

class _TreinoCriadoDetailsState extends State<TreinoCriadoDetails> {
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
                    // final result =
                    //     await context.push(
                    //         '/aluno/:${widget.alunoUid}/treinos/:${widget.pastaId}/editarTreino/:${widget.treino.id}',
                    //         pathParameters: {
                    //           'alunoUid': widget.alunoUid,
                    //           'pastaId': widget.pastaId,
                    //           'treinoId': widget.treino.id!
                    //         },
                    //         extra: widget.treino);

                    // if (result != null) {
                    //   setState(() {
                    //     result as Map<String, dynamic>;
                    //     widget.treino.titulo = result['titulo'];
                    //     widget.treino.exercicios = result['exercicios'];
                    //   });
                    // }
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
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
