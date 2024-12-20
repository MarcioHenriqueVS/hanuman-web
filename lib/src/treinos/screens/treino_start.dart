import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../alunos/pages/avaliacoes/header_prototipo.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderPrototipo(
              title: widget.treino.titulo.isEmpty
                  ? 'Sem título'
                  : widget.treino.titulo,
              subtitle: 'Detalhes do treino',
              maxWidth: 1150,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
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
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor),
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
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              exercicio.mecanismo,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.54),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 1,
                                    color: Theme.of(context).dividerColor),
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
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .dividerColor),
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
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            color: Theme.of(context).colorScheme.onSurface,
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
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.38),
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
                                  ? Theme.of(context).primaryColor
                                  : cell == 'Não realizado'
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.onSurface,
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
