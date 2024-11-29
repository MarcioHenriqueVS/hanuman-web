import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../services/treino_services.dart';
import '../services/treinos_personal_service.dart';
import 'models/training_sheet.dart';

class SalvarTreinoDialog extends StatefulWidget {
  final String pastaId;
  final List<TrainingSheet> trainingSheets;
  final String uid;
  const SalvarTreinoDialog(
      {super.key, required this.pastaId, required this.trainingSheets, required this.uid});

  @override
  State<SalvarTreinoDialog> createState() => _SalvarTreinoDialogState();
}

class _SalvarTreinoDialogState extends State<SalvarTreinoDialog> {
  final TreinoServices _treinoServices = TreinoServices();
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();

  @override
  Widget build(BuildContext context) {
    return GFFloatingWidget(
      verticalPosition: MediaQuery.of(context).size.height * 0.3,
      child: GFAlert(
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(
            color: Colors.red, fontSize: 18, decoration: TextDecoration.none),
        title: 'Atenção',
        content: const Text(
          'Deseja salvar o treino?',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
        bottomBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GFButton(
                color: Colors.grey,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                shape: GFButtonShape.pills,
                child: const Text(
                  'Voltar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
              builder: (context, buttonState) {
                return GFButton(
                  onPressed: buttonState is ElevatedButtonBlocLoading
                      ? null
                      : () async {
                          for (var treino in widget.trainingSheets) {
                            final newTreino =
                                _treinoServices.trainingSheetToTreino(treino);
                            await _treinosPersonalServices.addTreinoCriado(
                                widget.uid, widget.pastaId, newTreino);
                          }
                        },
                  shape: GFButtonShape.pills,
                  color: Colors.green,
                  icon: buttonState is ElevatedButtonBlocLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Icon(Icons.keyboard_arrow_right,
                          color: GFColors.WHITE),
                  position: GFPosition.end,
                  text: 'Salvar',
                  textStyle: const TextStyle(fontSize: 16),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
