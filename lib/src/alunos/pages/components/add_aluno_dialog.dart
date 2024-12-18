import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validadores/validadores.dart';
import '../../bloc/get_alunos/get_alunos_bloc.dart';
import '../../services/alunos_services.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import 'email_validator.dart';

// Adicione esta classe logo após as importações
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length > 8) {
      return oldValue;
    }

    var newText = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        newText += '/${text[i]}';
      } else {
        newText += text[i];
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AddAlunoDialog extends StatefulWidget {
  const AddAlunoDialog({super.key});

  @override
  State<AddAlunoDialog> createState() => _AddAlunoDialogState();
}

class _AddAlunoDialogState extends State<AddAlunoDialog> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  String? _photoUrl;
  String _selectedSexo = 'Masculino';
  String _selectedObjetivo = 'N/I';
  String _selectedFoco = 'N/I'; // Adicione esta linha
  String _selectedFrequencia = 'N/I'; // Adicione esta linha
  String _selectedNivel = 'N/I'; // Adicionar esta linha
  String? _photoBase64;

  // Adicione os controladores
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _obsController = TextEditingController();
  final _alunosServices = AlunosServices();

  // Adicione o bloc
  final _buttonBloc = ElevatedButtonBloc();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _dataNascController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _cpfController.dispose();
    _obsController.dispose();
    _buttonBloc.close();
    super.dispose();
  }

  // Adicione a função para salvar aluno
  Future<void> _salvarAluno() async {
    try {
      final response = await _alunosServices.addAluno(
        uid, // uid será gerado pelo servidor
        _nomeController.text.trim(),
        _dataNascController.text.trim(),
        _telefoneController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text.trim(),
        _obsController.text.trim(),
        _selectedSexo,
        _cpfController.text.trim(),
        _selectedFrequencia,
        _selectedObjetivo,
        _selectedFoco,
        _selectedNivel,
        fotoUrl: _photoBase64,
      );

      if (response['status'] == 200) {
        _buttonBloc.add(ElevatedButtonReset());
        if (mounted) {
          BlocProvider.of<GetAlunosBloc>(context).add(BuscarAlunos());
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aluno adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      _buttonBloc.add(ElevatedButtonReset());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar aluno: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectImage() async {
    final String? base64Image = await _alunosServices.selectImage();
    if (base64Image != null) {
      setState(() {
        _photoBase64 = base64Image;
        _photoUrl = 'data:image/jpeg;base64,$base64Image';
      });
    }
  }

  // Criar uma função para reutilizar a decoração padrão
  InputDecoration _getInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 900,
          maxWidth: 1000,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_add, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Adicionar Novo Aluno',
                      style: SafeGoogleFont(
                        'Open Sans',
                        textStyle: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Conteúdo com scroll
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna da foto
                          Container(
                            width: 200,
                            child: Column(
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: _selectImage,
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).dividerColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _photoUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(_photoUrl!,
                                                  fit: BoxFit.cover),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo_outlined,
                                                    size: 40,
                                                    color: Colors.grey[400]),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Clique para adicionar foto',
                                                  style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: 180,
                                  child: ElevatedButton.icon(
                                    onPressed: _selectImage,
                                    icon: const Icon(
                                        Icons.add_photo_alternate_outlined),
                                    label: const Text('Carregar Foto'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Coluna dos campos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome completo
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Nome Completo*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _nomeController,
                                            decoration: _getInputDecoration(
                                              hintText:
                                                  'Digite o nome completo',
                                              prefixIcon: Icons.person_outline,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                  30),
                                            ],
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return 'Campo obrigatório';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Email e Data de Nascimento
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Email*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _emailController,
                                            decoration: _getInputDecoration(
                                              hintText: 'Digite o email',
                                              prefixIcon: Icons.email_outlined,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .singleLineFormatter,
                                              EmailInputFormatter(),
                                              LengthLimitingTextInputFormatter(
                                                  60),
                                            ],
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return 'Campo obrigatório';
                                              }
                                              if (!value!.contains('@')) {
                                                return 'Email inválido';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Data de Nascimento',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _dataNascController,
                                            decoration: _getInputDecoration(
                                              hintText: 'DD/MM/AAAA',
                                              prefixIcon: Icons.cake_outlined,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              DateInputFormatter(),
                                            ],
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                // Remove as barras para validação
                                                final digitsOnly =
                                                    value.replaceAll('/', '');

                                                if (digitsOnly.length < 8) {
                                                  return 'Data incompleta';
                                                }

                                                // Extrai o ano
                                                final year =
                                                    digitsOnly.substring(4);
                                                if (year.length != 4) {
                                                  return 'Ano deve ter 4 dígitos';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Telefone e Sexo
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Telefone',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _telefoneController,
                                            decoration: _getInputDecoration(
                                              hintText: '(00) 00000-0000',
                                              prefixIcon: Icons.phone_outlined,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  15),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sexo*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            decoration: _getInputDecoration(
                                              hintText: '',
                                              prefixIcon: Icons.wc_outlined,
                                            ),
                                            value: _selectedSexo,
                                            dropdownColor: Colors.grey[900],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            items: ['Masculino', 'Feminino']
                                                .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white))))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(
                                                  () => _selectedSexo = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Senha e CPF
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Senha de Acesso*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _senhaController,
                                            decoration: _getInputDecoration(
                                              hintText:
                                                  'Digite a senha de acesso ao app do aluno',
                                              prefixIcon: Icons.lock_outline,
                                            ),
                                            obscureText: true,
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return 'Campo obrigatório';
                                              } else if (value!.length < 6) {
                                                return 'Senha deve ter no mínimo 6 caracteres';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'CPF',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _cpfController,
                                            decoration: _getInputDecoration(
                                              hintText: 'Digite o CPF',
                                              prefixIcon: Icons.badge_outlined,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              CpfInputFormatter(),
                                            ],
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                // if (!UtilBrasilFields.isCPFValido(
                                                //     value)) {
                                                //   return 'CPF inválido';
                                                // }
                                                Validador().add(Validar.CPF,
                                                    msg: 'CPF Inválido');
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Objetivo e Foco
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Objetivo',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            decoration: _getInputDecoration(
                                              hintText: '',
                                              prefixIcon:
                                                  Icons.track_changes_outlined,
                                            ),
                                            value: _selectedObjetivo,
                                            dropdownColor: Colors.grey[900],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            items: [
                                              //!
                                              'N/I',
                                              'Hipertrofia',
                                              'Emagrecimento',
                                              'Eutrofia',
                                              'Condicionamento Físico',
                                              'Reabilitação',
                                              'Qualidade de Vida'
                                            ]
                                                .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white))))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() =>
                                                  _selectedObjetivo = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Foco do Treino',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            decoration: _getInputDecoration(
                                              hintText: '',
                                              prefixIcon:
                                                  Icons.fitness_center_outlined,
                                            ),
                                            value: _selectedFoco,
                                            dropdownColor: Colors.grey[900],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            items: [
                                              'N/I',
                                              'Ganho de Força',
                                              'Aumento de Resistência',
                                              'Melhora da Flexibilidade',
                                              'Equilíbrio e Coordenação'
                                            ]
                                                .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white))))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(
                                                  () => _selectedFoco = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Frequência e Nível
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Frequência Semanal',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            decoration: _getInputDecoration(
                                              hintText: '',
                                              prefixIcon:
                                                  Icons.calendar_today_outlined,
                                            ),
                                            value: _selectedFrequencia,
                                            dropdownColor: Colors.grey[900],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            items: [
                                              'N/I',
                                              '1x',
                                              '2x',
                                              '3x',
                                              '4x',
                                              '5x',
                                              '6x',
                                              '7x'
                                            ]
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(
                                                      e != 'N/I'
                                                          ? '$e por semana'
                                                          : e,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() =>
                                                  _selectedFrequencia = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Nível',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            decoration: _getInputDecoration(
                                              hintText: '',
                                              prefixIcon: Icons.stairs_outlined,
                                            ),
                                            value: _selectedNivel,
                                            dropdownColor: Colors.grey[900],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            items: [
                                              'N/I',
                                              'Iniciante',
                                              'Intermediário',
                                              'Avançado'
                                            ]
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(
                                                      e,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() =>
                                                  _selectedNivel = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Observações
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Observações',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _obsController,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(200),
                                      ],
                                      decoration: _getInputDecoration(
                                        hintText:
                                            'Digite observações adicionais',
                                        prefixIcon: Icons.notes_outlined,
                                      ),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                                // Botões de ação
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    // border: Border(
                                    //   top: BorderSide(
                                    //       color: Colors.grey[800]!, width: 1),
                                    // ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 16),
                                          ),
                                          child: Text('Cancelar',
                                              style: TextStyle(
                                                  color: Colors.grey[400])),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      BlocBuilder<ElevatedButtonBloc,
                                          ElevatedButtonBlocState>(
                                        bloc: _buttonBloc,
                                        builder: (context, state) {
                                          return MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: ElevatedButton(
                                              onPressed: state
                                                      is ElevatedButtonBlocLoading
                                                  ? null
                                                  : () async {
                                                      if (_formKey.currentState
                                                              ?.validate() ??
                                                          false) {
                                                        _buttonBloc.add(
                                                            ElevatedButtonPressed());
                                                        await _salvarAluno();
                                                      }
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: state
                                                      is ElevatedButtonBlocLoading
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const Text('Salvar'),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
