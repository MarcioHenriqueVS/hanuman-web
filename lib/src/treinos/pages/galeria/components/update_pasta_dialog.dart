import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../../flutter_flow/ff_button_options.dart';
import '../../../../utils.dart';
import '../../../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../../../bloc/get_pastas_personal/get_pastas_event.dart';
import '../../../pastas/aluno/services/pastas_services.dart';
import '../../../pastas/galeria/services/pastas_galeria_services.dart';

class UpdatePastaDialog extends StatefulWidget {
  final Map<String, dynamic> pasta;
  final String? alunoUid;
  const UpdatePastaDialog({super.key, required this.pasta, this.alunoUid});

  @override
  State<UpdatePastaDialog> createState() => _UpdatePastaDialogState();
}

class _UpdatePastaDialogState extends State<UpdatePastaDialog> {
  dynamic _corAtual;
  TextEditingController nomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Color _corSelecionada = Colors.blue;
  final PastasGaleriaServices _pastasGaleriaServices = PastasGaleriaServices();
  final PastasServices _pastasServices = PastasServices();
  final uid = FirebaseAuth.instance.currentUser!.uid;

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
    return 'blue';
  }

  @override
  void initState() {
    _corAtual = widget.pasta['cor'];
    nomeController.text = widget.pasta['nome'];
    _corSelecionada = _corAtual;
    super.initState();
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_open, color: _corSelecionada, size: 28),
                  const SizedBox(width: 16),
                  Text(
                    'Editar Pasta',
                    style: SafeGoogleFont(
                      'Outfit',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Pasta',
                  labelStyle: SafeGoogleFont(
                    'Readex Pro',
                    color: Colors.grey[600],
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
                  'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                        'Readex Pro',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FFButtonWidget(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          context.loaderOverlay.show();
                          // só enviar o nome da pasta se ele for diferente do atual
                          String? nome;
                          if (nomeController.text != widget.pasta['nome']) {
                            nome = nomeController.text;
                          }
                          // só atualizar a cor se ela for diferente da atual
                          String? cor;
                          if (_corSelecionada != _corAtual) {
                            cor = _getColorName(_corSelecionada);
                          }

                          widget.alunoUid != null
                              ? await _pastasServices.updatePasta(
                                  uid, widget.alunoUid!, widget.pasta['id'],
                                  cor: cor, nomePasta: nome)
                              : await _pastasGaleriaServices
                                  .updatePastaPersonal(
                                  uid,
                                  widget.pasta['id'],
                                  cor: cor,
                                  nomePasta: nome,
                                );
                          if (context.mounted) {
                            context
                                .read<GetPastasPersonalBloc>()
                                .add(BuscarPastasPersonal());
                            context.loaderOverlay.hide();
                            Navigator.pop(context);
                            GFToast.showToast(
                              'Pasta atualizada com sucesso',
                              context,
                              backgroundColor: Colors.green,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            context.loaderOverlay.visible
                                ? context.loaderOverlay.hide()
                                : null;
                            GFToast.showToast(
                              'Erro ao atualizar pasta',
                              context,
                              backgroundColor: Colors.red,
                            );
                          }
                        }
                      }
                    },
                    text: 'Salvar',
                    options: FFButtonOptions(
                      height: 40,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Colors.green,
                      textStyle: SafeGoogleFont(
                        'Readex Pro',
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
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
