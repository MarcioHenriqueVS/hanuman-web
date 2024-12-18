import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import '../../autenticacao/tratamento/error_snackbar.dart';
import '../../autenticacao/tratamento/success_snackbar.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../services/treino_services.dart';
import 'models/training_sheet.dart';

class EnviarTreinoDialog extends StatefulWidget {
  final String pastaId;
  final List<TrainingSheet> trainingSheets;
  final String? alunoUid;
  final String uid;
  const EnviarTreinoDialog(
      {super.key,
      required this.pastaId,
      required this.trainingSheets,
      this.alunoUid,
      required this.uid});

  @override
  State<EnviarTreinoDialog> createState() => _EnviarTreinoDialogState();
}

class _EnviarTreinoDialogState extends State<EnviarTreinoDialog> {
  final TreinoServices _treinoServices = TreinoServices();
  bool? habilitado;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Atenção',
        style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 18,
            decoration: TextDecoration.none),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Text(
              'Deseja enviar o(s) treino(s) para o aluno?',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  decoration: TextDecoration.none),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GFButton(
                  color: Theme.of(context).colorScheme.surface,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: GFButtonShape.pills,
                  child: Text(
                    'Voltar',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16),
                  ),
                ),
              ),
              BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                builder: (context, buttonState) {
                  return GFButton(
                    onPressed: buttonState is ElevatedButtonBlocLoading
                        ? null
                        : () async {
                            // Primeiro, exibe o diálogo de visibilidade
                            final resposta = await _treinoServices
                                .showVisibilityDialog(context);
                            if (resposta == null)
                              return; // Usuário cancelou o diálogo

                            habilitado =
                                resposta; // Atualiza o valor de habilitado com base na resposta

                            BlocProvider.of<ElevatedButtonBloc>(context)
                                .add(ElevatedButtonPressed());
                            for (var treino in widget.trainingSheets) {
                              final newTreino =
                                  _treinoServices.trainingSheetToTreino(treino);
                              final sucesso = await _treinoServices.addTreino(
                                  widget.uid,
                                  widget.alunoUid!,
                                  widget.pastaId,
                                  newTreino,
                                  habilitado!);
                              if (sucesso) {
                                BlocProvider.of<ElevatedButtonBloc>(context)
                                    .add(ElevatedButtonReset());
                                MensagemDeSucesso().showSuccessSnackbar(
                                    context, 'Enviado com sucesso!');
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } else {
                                BlocProvider.of<ElevatedButtonBloc>(context)
                                    .add(ElevatedButtonReset());
                                TratamentoDeErros().showErrorSnackbar(
                                    context, 'Erro, tente novamente');
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                            }
                          },
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: GFButtonShape.pills,
                    color: Theme.of(context).primaryColor,
                    icon: buttonState is ElevatedButtonBlocLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : Icon(Icons.keyboard_arrow_right,
                            color: Theme.of(context).colorScheme.onPrimary),
                    position: GFPosition.end,
                    text: 'Enviar',
                    textStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
