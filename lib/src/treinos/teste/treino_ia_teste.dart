import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../flutter_flow/ff_button_options.dart';
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
      appBar: AppBar(
        centerTitle: false,
        title: const Text('',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecione',
                          style: SafeGoogleFont(
                            'Outfit',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.alunoUid != null
                              ? 'Os treinos selecionados serão enviados para o aluno'
                              : 'Os treinos selecionados serão salvos',
                          style: SafeGoogleFont(
                            'Readex Pro',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          treinos!.isEmpty
                              ? _showErrorDialog()
                              : widget.alunoUid != null
                                  ? alunoModal()
                                  : personalModal();
                        },
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: Text(
                          widget.alunoUid != null
                              ? 'Enviar para aluno'
                              : 'Salvar',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // FFButtonWidget(
                    //   onPressed: _mostrarDialogNovaPasta,
                    //   text: 'Nova pasta',
                    //   icon: const Icon(
                    //     Icons.add_rounded,
                    //     size: 15,
                    //   ),
                    //   options: FFButtonOptions(
                    //     height: 40,
                    //     padding: const EdgeInsetsDirectional.fromSTEB(
                    //         16, 0, 16, 0),
                    //     iconPadding: const EdgeInsetsDirectional.fromSTEB(
                    //         0, 0, 0, 0),
                    //     color: Colors.green,
                    //     textStyle: SafeGoogleFont(
                    //       'Readex Pro',
                    //       textStyle: const TextStyle(
                    //         fontSize: 16,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //     elevation: 3,
                    //     borderSide: const BorderSide(
                    //       color: Colors.transparent,
                    //       width: 1,
                    //     ),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: widget.trainingPlan.trainingSheets!.length,
                    itemBuilder: (context, index) {
                      final sheet = widget.trainingPlan.trainingSheets![index];
                      return _buildTrainingCard(sheet, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingCard(TrainingSheet sheet, int index) {
    return Card(
      color: Colors.grey[900],
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
                        'Readex Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () => _navigateToExercicios(sheet, index),
                child: const Text('Ver Detalhes',
                    style: TextStyle(color: Colors.white)),
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
        title: const Text('Atenção'),
        content:
            const Text('Você precisa selecionar um treino antes de continuar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
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
