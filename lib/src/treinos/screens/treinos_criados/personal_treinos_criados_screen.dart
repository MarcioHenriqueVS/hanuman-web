import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import '../../../alunos/pages/avaliacoes/header_prototipo.dart';
import '../../bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
import '../../models/exercicio_treino_model.dart';
import '../../models/treino_model.dart';
import '../../services/treino_services.dart';
import '../../services/treinos_personal_service.dart';
import 'selecionar_aluno.dart';

class TreinoCriadoScreen extends StatefulWidget {
  final Treino treino;
  final String pastaId;
  const TreinoCriadoScreen(
      {super.key, required this.treino, required this.pastaId});

  @override
  State<TreinoCriadoScreen> createState() => _TreinoCriadoScreenState();
}

class _TreinoCriadoScreenState extends State<TreinoCriadoScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();
  final TreinoServices _treinoServices = TreinoServices();
  bool _isDeleting = false;

  void deleteTreino(treinoId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _treinosPersonalServices.deleteTreinoCriado(
          uid, widget.pastaId, treinoId);
      if (mounted) {
        GFToast.showToast('Treino deletado com sucesso', context,
            backgroundColor: Colors.green);
        BlocProvider.of<GetTreinosCriadosBloc>(context)
            .add(BuscarTreinosCriados(widget.pastaId));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        GFToast.showToast('Erro ao deletar treino, tente novamente', context,
            backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252525),
          title: const Text(
            'Confirmar exclusão',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Tem certeza que deseja excluir este treino?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteTreino(widget.treino.id);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderPrototipo(
              title: widget.treino.titulo,
              subtitle: 'Detalhes do treino',
              button: 'Enviar para aluno',
              onSave: () {
                showDialog(
                  context: context,
                  builder: (context) => SelecionarAluno(
                    treino: widget.treino,
                    treinoId: widget.treino.id!,
                    pastaId: widget.pastaId,
                  ),
                );
              },
              icon: false,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final result = await context.push(
                                '/personal/:$uid/treinos/:${widget.pastaId}/editar-treino/:${widget.treino.id}',
                                extra: {
                                  'pastaId': widget.pastaId,
                                  'treinoId': widget.treino.id!,
                                  'treino': widget.treino,
                                },
                              );
                              if (result != null) {
                                setState(() {
                                  result as Map<String, dynamic>;
                                  widget.treino.titulo = result['titulo'];
                                  widget.treino.exercicios =
                                      result['exercicios'];
                                });
                              }
                            },
                            child: Text('Editar'),
                          ),
                          TextButton(
                            onPressed: _isDeleting
                                ? null
                                : () async {
                                    _showDeleteConfirmationDialog();
                                  },
                            child: _isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.red),
                                    ),
                                  )
                                : const Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                          ),
                        ],
                      ),
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
                                          color: const Color(
                                              0xFF2A2A2A), // Cor de fundo para quando a imagem falhar
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
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.green,
                                                ),
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
                                            SizedBox(
                                              height: 28,
                                            ),
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
                                // Divisor
                                Container(
                                  height: 1,
                                  color: const Color(0xFF2F2F2F),
                                ),
                                // Corpo do exercício
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Intervalo
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
                                              'Intervalo: ${exercicio.intervalo.valor} ${_treinoServices.intervaloTipoParaString(exercicio.intervalo.tipo)}',
                                              style: TextStyle(
                                                color: Colors.green.shade400,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Observações (se houver)
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

                                      // Tabela de séries
                                      Center(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 1000),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Table(
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(1),
                                              2: FlexColumnWidth(1),
                                              3: FlexColumnWidth(1),
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
                                                ]
                                                    .map((header) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 16),
                                                          child: Text(
                                                            header,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .white38,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                              ...exercicio.series
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                final serie = entry.value;
                                                return TableRow(
                                                  children: [
                                                    '${entry.key + 1}',
                                                    '${serie.kg}kg',
                                                    '${serie.reps} reps',
                                                    serie.tipo.toString(),
                                                  ]
                                                      .map((cell) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16),
                                                            child: Text(
                                                              cell,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
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
}
