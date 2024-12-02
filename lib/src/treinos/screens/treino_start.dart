import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../alunos/pages/avaliacoes/header_prototipo.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back,
                    size: 20, color: Colors.white70),
              ),
            ),
            // const SizedBox(width: 16),
            // Text(
            //   'Detalhes do treino',
            //   style: const TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.w600,
            //     color: Colors.white,
            //   ),
            // )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HeaderPrototipo(
            //   title: widget.treino.titulo.isEmpty
            //                 ? 'Sem título'
            //                 : widget.treino.titulo,
            //   subtitle: 'Detalhes do treino',
            // ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.treino.titulo.isEmpty
                            ? 'Sem título'
                            : widget.treino.titulo,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Estatísticas do treino
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildStatItem('Duração', widget.treino.duracao!),
                            const SizedBox(width: 48),
                            _buildStatItem(
                                'Volume', '${widget.treino.volume!}kg'),
                            const SizedBox(width: 48),
                            _buildStatItem('Séries', widget.treino.series!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.treino.exercicios.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          ExercicioTreino exercicio =
                              widget.treino.exercicios[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF252525),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cabeçalho do exercício
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color(0xFF2A2A2A),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            exercicio.fotoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/logoTeste.png',
                                                fit: BoxFit.contain,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exercicio.nome,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              exercicio.mecanismo,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 1, color: const Color(0xFF2F2F2F)),
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A2A2A),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.timer_outlined,
                                                size: 14,
                                                color: Colors.green.shade400),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Intervalo: ${exercicio.intervalo.valor} ${intervaloTipoParaString(exercicio.intervalo.tipo)}',
                                              style: TextStyle(
                                                color: Colors.green.shade400,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (exercicio.notas.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A2A2A),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Observações',
                                                style: TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                exercicio.notas,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 32),
                                      _buildSeriesTable(exercicio),
                                    ],
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white38,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeriesTable(ExercicioTreino exercicio) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF2F2F2F),
                    width: 1,
                  ),
                ),
              ),
              children: [
                'SÉRIE',
                'CARGA',
                'REPS',
                'TIPO',
                'STATUS',
              ]
                  .map((header) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          header,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white38,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            ...exercicio.series.asMap().entries.map((entry) {
              final serie = entry.value;
              return TableRow(
                children: [
                  '${entry.key + 1}',
                  '${serie.kg}kg',
                  '${serie.reps} reps',
                  serie.tipo.toString(),
                  serie.check! ? 'Concluído' : 'Não realizado',
                ]
                    .map((cell) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            cell,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: cell == 'Concluído'
                                  ? Colors.green
                                  : cell == 'Não realizado'
                                      ? Colors.red
                                      : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              );
            }).toList(),
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
