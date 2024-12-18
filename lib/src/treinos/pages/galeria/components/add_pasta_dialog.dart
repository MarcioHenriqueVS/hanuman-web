import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../flutter_flow/ff_button_options.dart';
import '../../../../utils.dart';
import '../../../bloc/get_pastas/get_pastas_bloc.dart';
import '../../../bloc/get_pastas/get_pastas_event.dart';
import '../../../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../../../bloc/get_pastas_personal/get_pastas_event.dart';
import '../../../pastas/galeria/services/pastas_galeria_services.dart';
import '../../../services/treino_services.dart';

class AddPastaDialog extends StatefulWidget {
  final bool pastaAluno;
  final String? alunoUid;
  const AddPastaDialog({super.key, required this.pastaAluno, this.alunoUid});

  @override
  State<AddPastaDialog> createState() => _AddPastaDialogState();
}

class _AddPastaDialogState extends State<AddPastaDialog> {
  final PastasGaleriaServices _pastasGaleriaServices = PastasGaleriaServices();
  final TreinoServices _treinoServices = TreinoServices();
  // Adicione estas variáveis de estado para o formulário
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  Color _corSelecionada = Colors.blue;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Lista de cores para seleção
  final List<Color> _coresDisponiveis = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  String _getColorName(Color cor) {
    if (cor == Colors.blue) return 'blue';
    if (cor == Colors.green) return 'green';
    if (cor == Colors.red) return 'red';
    if (cor == Colors.purple) return 'purple';
    if (cor == Colors.orange) return 'orange';
    if (cor == Colors.teal) return 'teal';
    if (cor == Colors.pink) return 'pink';
    if (cor == Colors.indigo) return 'indigo';
    return 'blue'; // cor padrão
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_open,
                      color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    'Nova Pasta de Treinos',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Pasta',
                  labelStyle: SafeGoogleFont(
                    'Open Sans',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  hintText: 'Ex: Treinos de Força',
                  hintStyle: SafeGoogleFont(
                    'Open Sans',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para a pasta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Cor da Etiqueta',
                style: SafeGoogleFont(
                  'Open Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _coresDisponiveis.map((cor) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _corSelecionada = cor);
                      //Navigator.pop(context);
                      //! _mostrarDialogNovaPasta(); // Reabre o diálogo para atualizar a cor
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: cor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _corSelecionada == cor
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: SafeGoogleFont(
                        'Open Sans',
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FFButtonWidget(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Adicionar nova pasta
                        try {
                          widget.pastaAluno
                              ? await _treinoServices.addPasta(
                                  uid,
                                  widget.alunoUid!,
                                  _nomeController.text,
                                  _getColorName(_corSelecionada))
                              : await _pastasGaleriaServices.addPastaPersonal(
                                  uid,
                                  _nomeController.text,
                                  _getColorName(_corSelecionada));

                          widget.pastaAluno
                              ? BlocProvider.of<GetPastasBloc>(context)
                                  .add(BuscarPastas(widget.alunoUid!))
                              : BlocProvider.of<GetPastasPersonalBloc>(context)
                                  .add(BuscarPastasPersonal());
                        } catch (e) {
                          debugPrint('Erro ao criar pasta: $e');
                        }
                        _nomeController.clear();
                        Navigator.pop(context);
                      }
                    },
                    text: 'Criar pasta',
                    options: FFButtonOptions(
                      height: 40,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Theme.of(context).primaryColor,
                      textStyle: SafeGoogleFont(
                        'Open Sans',
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      elevation: 3,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
