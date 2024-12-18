import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../alunos/pages/avaliacoes/header_prototipo.dart';
import '../../utils.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../bloc/get_pastas/get_pastas_bloc.dart';
import '../bloc/get_pastas/get_pastas_event.dart';
import '../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../bloc/get_pastas_personal/get_pastas_event.dart';
import '../services/treino_services.dart';
import 'aluno_modal.dart';
import 'models/training_program_model.dart';
import 'models/training_sheet.dart';
import 'personal_modal.dart';
import 'training_to_exercicios.dart';

class TreinoIAScreen extends StatefulWidget {
  final TrainingProgram trainingPlan;
  final String? alunoUid;
  final String? messageId;
  const TreinoIAScreen(
      {super.key, required this.trainingPlan, this.alunoUid, this.messageId});

  @override
  State<TreinoIAScreen> createState() => _TreinoIAScreenState();
}

class _TreinoIAScreenState extends State<TreinoIAScreen> {
  final TextEditingController pastaIdController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<TrainingSheet>? treinos = [];
  final TreinoServices _treinoServices = TreinoServices();

  @override
  void initState() {
    BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
    // Inicializa a lista 'treinos' com todos os itens de 'trainingSheets'
    if (widget.trainingPlan.trainingSheets != null) {
      treinos = List.from(widget.trainingPlan.trainingSheets!);

      // Marca todos os checkboxes como selecionados
      for (var sheet in widget.trainingPlan.trainingSheets!) {
        sheet.check = true; // Inicialmente, todos os treinos estão selecionados
      }
    }

    widget.alunoUid != null
        ? BlocProvider.of<GetPastasBloc>(context)
            .add(BuscarPastas(widget.alunoUid!))
        : BlocProvider.of<GetPastasPersonalBloc>(context)
            .add(BuscarPastasPersonal());

    super.initState();
  }

  @override
  void dispose() {
    pastaIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: false,
      //   title: const Text('',
      //       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      //   actions: [],
      // ),
      body: Column(
        children: [
          HeaderPrototipo(
            title: 'Selecione',
            subtitle: widget.alunoUid != null
                ? 'Os treinos selecionados serão enviados para o aluno'
                : 'Os treinos selecionados serão salvos',
            maxWidth: 1200,
            onSave: () async {
              treinos!.isEmpty
                  ? _showErrorDialog()
                  : widget.alunoUid != null
                      ? alunoModal()
                      : personalModal();
            },
            button: widget.alunoUid != null ? 'Enviar para aluno' : 'Salvar',
            iconData:
                Icon(Icons.send, color: Theme.of(context).colorScheme.surface),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _calculateCrossAxisCount(context),
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: widget.trainingPlan.trainingSheets!.length,
                          itemBuilder: (context, index) {
                            final sheet =
                                widget.trainingPlan.trainingSheets![index];
                            return _buildTrainingCard(sheet, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(TrainingSheet sheet, int index) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToExercicios(sheet, index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sheet.day!,
                      style: SafeGoogleFont(
                        'Open Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: sheet.check,
                      onChanged: (val) => _handleCheckboxChange(sheet, val),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () => _navigateToExercicios(sheet, index),
                child: Text(
                  'Ver Detalhes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _handleCheckboxChange(TrainingSheet sheet, bool? val) {
    setState(() {
      sheet.check = val!;
      if (sheet.check!) {
        if (!treinos!.contains(sheet)) treinos!.add(sheet);
      } else {
        treinos!.remove(sheet);
      }
    });
  }

  void _navigateToExercicios(TrainingSheet sheet, int index) {
    final exercicios = _treinoServices.transformarTrainingProgram(sheet);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingProgramToExerciciosSelecionadosScreen(
          exercicios: exercicios,
          title: sheet.day!,
          index: index,
          messageId: widget.messageId,
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Atenção',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Você precisa selecionar um treino antes de continuar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Ok',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void alunoModal() {
    showDialog(
      context: context,
      builder: (context) => AlunoModal(
        treinos: treinos,
        alunoUid: widget.alunoUid,
      ),
    );
  }

  void personalModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PersonalModal(
        treinos: treinos,
      ),
    );
  }
}
