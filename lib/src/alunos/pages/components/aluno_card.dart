import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../treinos/models/treino_model.dart';
import '../../models/aluno_model.dart';
import 'alunos_list.dart';

class AlunosCard extends StatefulWidget {
  final AlunoModel aluno;
  final bool choose;
  final Treino? treino;
  final String? pastaId;
  final String? treinoId;
  const AlunosCard(
      {super.key,
      required this.aluno,
      required this.choose,
      this.pastaId,
      this.treino,
      this.treinoId});

  @override
  State<AlunosCard> createState() => _AlunosCardState();
}

class _AlunosCardState extends State<AlunosCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF333333)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withOpacity(0.05),
        onTap: () => !widget.choose
            ? context.push('/aluno/:${widget.aluno.uid}', extra: widget.aluno)
            : showModalBottomSheet(
                context: context,
                builder: (context) => SelecionarPasta(
                  treinoId: widget.treinoId!,
                  treino: widget.treino!,
                  alunoUid: widget.aluno.uid,
                  sexo: widget.aluno.sexo,
                ),
              ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: (widget.aluno.fotoUrl != null &&
                            widget.aluno.fotoUrl!.isNotEmpty)
                        ? NetworkImage(widget.aluno.fotoUrl!)
                        : AssetImage('assets/images/fotoDePerfilNull.jpg')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.aluno.nome,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.aluno.email,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
