import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../alunos/models/aluno_model.dart';
import '../../../../../alunos/services/alunos_services.dart';
import '../../../../../treinos/screens/treino_finalizado_screen.dart';
import '../../../../../utils.dart';

class AttHomeWidget extends StatefulWidget {
  final String tipo;
  final String titulo;
  final String? descricao;
  final Timestamp timestamp;
  final String alunoUid;
  final String treinoDocId;
  final bool isSmallScreen;
  final AlunoModel aluno; // Novo parâmetro

  const AttHomeWidget({
    super.key,
    required this.tipo,
    required this.titulo,
    this.descricao,
    required this.timestamp,
    required this.alunoUid,
    required this.treinoDocId,
    required this.isSmallScreen,
    required this.aluno, // Novo parâmetro
  });

  @override
  State<AttHomeWidget> createState() => _AttHomeWidgetState();
}

class _AttHomeWidgetState extends State<AttHomeWidget> {
  String? friendlyDate;

  @override
  void initState() {
    formatarTimestamp();
    super.initState();
  }

  void formatarTimestamp() {
    // Formatar a data de forma personalizada
    String day = DateFormat.d('pt_BR').format(widget.timestamp.toDate());
    String month = DateFormat.M('pt_BR').format(widget.timestamp.toDate());
    String time = DateFormat.Hm('pt_BR').format(widget.timestamp.toDate());
    setState(() {
      // Formatar a data de forma amigável
      friendlyDate = "$day/$month às ${time}h";
    });
  }

  @override
  Widget build(BuildContext context) {
    return friendlyDate == null
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => TreinoFinalizadoScreen(
                      alunoUid: widget.alunoUid,
                      treinoId: widget.treinoDocId,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    // Cor um pouco mais clara que a cor de fundo
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.aluno.fotoUrl ??
                            'https://i.pravatar.cc/150?img=1'),
                        radius: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.aluno.nome} ${widget.titulo}',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              'Clique para visualizar',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Em:',
                            style: SafeGoogleFont(
                              'Open Sans',
                              textStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            friendlyDate ?? 'Não registrado',
                            style: SafeGoogleFont(
                              'Open Sans',
                              textStyle: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
