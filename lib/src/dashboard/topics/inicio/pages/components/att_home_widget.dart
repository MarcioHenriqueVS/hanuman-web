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
  const AttHomeWidget(
      {super.key,
      required this.tipo,
      required this.titulo,
      this.descricao,
      required this.timestamp,
      required this.alunoUid,
      required this.treinoDocId,
      required this.isSmallScreen});

  @override
  State<AttHomeWidget> createState() => _AttHomeWidgetState();
}

class _AttHomeWidgetState extends State<AttHomeWidget> {
  AlunoModel? aluno;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final AlunosServices _alunosServices = AlunosServices();
  String? friendlyDate;

  @override
  void initState() {
    getAluno();
    formatarTimestamp();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAluno() async {
    debugPrint(widget.alunoUid);
    debugPrint(uid);
    final newAluno = await _alunosServices.getAluno(uid, widget.alunoUid);
    setState(() {
      aluno = newAluno;
    });
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
    return aluno == null || friendlyDate == null
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
                  //margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFF121212),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(aluno!.fotoUrl ??
                            'https://i.pravatar.cc/150?img=1'),
                        radius: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${aluno!.nome} ${widget.titulo}',
                              style: SafeGoogleFont(
                                'Open Sans',
                                textStyle: const TextStyle(
                                  color: Colors.white,
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
                                  color: Colors.grey[400],
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
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            friendlyDate ?? 'Não registrado',
                            style: SafeGoogleFont(
                              'Open Sans',
                              textStyle: const TextStyle(
                                color: Colors.green,
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
