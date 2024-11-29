import 'package:flutter/material.dart';
import '../../../utils.dart';
import '../../models/aluno_model.dart';
import '../avaliacoes/add_ava_prototipo.dart';
import '../avaliacoes/avaliacoes_list_page.dart';
import '../treinos/aluno_pastas_list_page.dart';

class PreviaAlunoDialog extends StatefulWidget {
  final AlunoModel aluno;
  const PreviaAlunoDialog({super.key, required this.aluno});

  @override
  State<PreviaAlunoDialog> createState() => _PreviaAlunoDialogState();
}

class _PreviaAlunoDialogState extends State<PreviaAlunoDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prévia do Aluno',
                  style: SafeGoogleFont(
                    'Outfit',
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: widget.aluno.fotoUrl != null
                      ? NetworkImage(widget.aluno.fotoUrl!)
                      : null,
                  child: widget.aluno.fotoUrl == null
                      ? const Icon(Icons.person, size: 45)
                      : null,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nome', widget.aluno.nome),
                      const SizedBox(height: 12),
                      _buildInfoRow('Email', widget.aluno.email),
                      const SizedBox(height: 12),
                      _buildInfoRow('Status',
                          widget.aluno.status == true ? 'Ativo' : 'Inativo',
                          isStatus: true,
                          isActive: widget.aluno.status ?? false),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  'Adicionar Treino',
                  Icons.fitness_center,
                  Colors.green,
                  () {
                    // Implementar ação de adicionar treino
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlunoPastasListPage(
                          alunoUid: widget.aluno.uid,
                          sexo: widget.aluno.sexo,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  'Adicionar Antropometria',
                  Icons.straighten,
                  Colors.blue,
                  () {
                    // Implementar ação de adicionar antropometria
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                           // AvaliacoesListPage(aluno: widget.aluno),
                           AddAvaPrototipo(aluno: widget.aluno,)
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isStatus = false, bool isActive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: SafeGoogleFont(
              'Readex Pro',
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: isStatus
              ?
              // Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: isActive ? Colors.green : Colors.red,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child:
              Text(
                  value,
                  style: SafeGoogleFont(
                    'Readex Pro',
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  //),
                )
              : Text(
                  value,
                  style: SafeGoogleFont(
                    'Readex Pro',
                    textStyle: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          hoverColor: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: SafeGoogleFont(
                    'Readex Pro',
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
