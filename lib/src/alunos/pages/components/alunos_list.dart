import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import '../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_bloc.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_event.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_state.dart';
import '../../../treinos/models/treino_model.dart';
import '../../../treinos/services/treino_services.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';

class SelecionarPasta extends StatefulWidget {
  final Treino treino;
  final String treinoId;
  final String alunoUid;
  final String sexo;
  const SelecionarPasta(
      {super.key,
      required this.treino,
      required this.treinoId,
      required this.alunoUid,
      required this.sexo});

  @override
  State<SelecionarPasta> createState() => _SelecionarPastaState();
}

class _SelecionarPastaState extends State<SelecionarPasta> {
  @override
  void initState() {
    BlocProvider.of<GetPastasBloc>(context).add(BuscarPastas(widget.alunoUid));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPastasBloc, GetPastasState>(
      builder: (context, pastasState) {
        if (pastasState is GetPastasInitial) {
          return const Center(child: Text('Iniciando busca das pastas'));
        } else if (pastasState is GetPastasLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (pastasState is GetPastasError) {
          return const Center(
            child: Text('Erro ao tentar buscar pastas, recarregue a tela'),
          );
        } else if (pastasState is GetPastasLoaded) {
          final pastasIds = pastasState.pastasIds;
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Garante tamanho mínimo necessário
              children: [
                // Indicador de arraste
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Cabeçalho
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.folder_copy_outlined, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'Selecione uma pasta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de pastas
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A),
                    ),
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                        minHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: pastasIds.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EnviarTreino(
                                  pastaId: pastasIds[index]['id'],
                                  treino: widget.treino,
                                  treinoId: widget.treinoId,
                                  alunoUid: widget.alunoUid,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color(0xFF252525),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      pastasIds[index]['nome'],
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class EnviarTreino extends StatefulWidget {
  final Treino treino;
  final String pastaId;
  final String treinoId;
  final String alunoUid;
  const EnviarTreino(
      {super.key,
      required this.pastaId,
      required this.treino,
      required this.treinoId,
      required this.alunoUid});

  @override
  State<EnviarTreino> createState() => _EnviarTreinoState();
}

class _EnviarTreinoState extends State<EnviarTreino> {
  final TreinoServices _treinoServices = TreinoServices();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void enviarTreino() async {
    try {
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonPressed());
      await _treinoServices.addTreino(
          uid, widget.alunoUid, widget.pastaId, widget.treino);
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      Navigator.of(context).pop();
      MensagemDeSucesso()
          .showSuccessSnackbar(context, 'Treino enviado com sucesso');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      TratamentoDeErros()
          .showErrorSnackbar(context, 'Erro ao enviar treino, tente novamente');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      },
      child: AlertDialog(
        
        title: Text(
          'Atenção',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Deseja enviar este treino para o aluno?',
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Voltar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
            builder: (context, buttonState) {
              return TextButton(
                onPressed: buttonState is ElevatedButtonBlocLoading
                    ? null
                    : () {
                        enviarTreino();
                      },
                child: buttonState is ElevatedButtonBlocLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Enviar',
                        style: TextStyle(color: Colors.green),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
