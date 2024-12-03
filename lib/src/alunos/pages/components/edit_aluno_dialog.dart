import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/aluno_model.dart';
import '../../services/alunos_services.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';

class EditAlunoDialog extends StatefulWidget {
  final AlunoModel aluno;

  const EditAlunoDialog({
    super.key,
    required this.aluno,
  });

  @override
  State<EditAlunoDialog> createState() => _EditAlunoDialogState();
}

class _EditAlunoDialogState extends State<EditAlunoDialog> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  String? _photoUrl;
  String _selectedSexo = 'Masculino';
  String _selectedObjetivo = 'Hipertrofia';
  String _selectedFoco = 'Ganho de Força';
  String _selectedFrequencia = '3x';
  String _selectedNivel = 'Iniciante';
  String? _photoBase64;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _obsController = TextEditingController();
  final _alunosServices = AlunosServices();
  final _buttonBloc = ElevatedButtonBloc();

  @override
  void initState() {
    super.initState();
    // Preencher os campos com os dados do aluno usando os nomes corretos
    _nomeController.text = widget.aluno.nome;
    _emailController.text = widget.aluno.email;
    _dataNascController.text = widget.aluno.dataDeNascimento ?? '';
    _telefoneController.text = widget.aluno.telefone ?? '';
    // Corrigir a inicialização do CPF para verificar se é nulo
    _cpfController.text = widget.aluno.cpf ?? '';
    _obsController.text = widget.aluno.obs ?? '';
    _selectedSexo = widget.aluno.sexo;
    _selectedFrequencia = widget.aluno.frequencia ?? '3x';
    _selectedObjetivo = widget.aluno.objetivo ?? 'Hipertrofia';
    _selectedFoco = widget.aluno.foco ?? 'Ganho de Força';
    _selectedNivel = widget.aluno.nivel ?? 'Iniciante';
    _photoUrl = widget.aluno.fotoUrl;
    // Não preenchemos a senha para manter a segurança
  }

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

  Future<void> _atualizarAluno() async {
    try {
      DateTime timestamp = DateTime.now();
      String dataFormatada =
          DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(timestamp);

      // Cria um mapa com apenas os campos que foram modificados
      Map<String, dynamic> changedFields = {};

      if (_nomeController.text != widget.aluno.nome) {
        changedFields['nome'] = _nomeController.text;
      }
      if (_emailController.text != widget.aluno.email) {
        changedFields['email'] = _emailController.text;
      }
      if (_dataNascController.text != widget.aluno.dataDeNascimento) {
        changedFields['dataDeNascimento'] = _dataNascController.text;
      }
      if (_telefoneController.text != widget.aluno.telefone) {
        changedFields['telefone'] = _telefoneController.text;
      }
      if (_selectedSexo != widget.aluno.sexo) {
        changedFields['sexo'] = _selectedSexo;
      }
      if (_cpfController.text != widget.aluno.cpf) {
        changedFields['cpf'] = _cpfController.text;
      }
      if (_selectedFrequencia != widget.aluno.frequencia) {
        changedFields['frequencia'] = _selectedFrequencia;
      }
      if (_selectedObjetivo != widget.aluno.objetivo) {
        changedFields['objetivo'] = _selectedObjetivo;
      }
      if (_selectedFoco != widget.aluno.foco) {
        changedFields['foco'] = _selectedFoco;
      }
      if (_selectedNivel != widget.aluno.nivel) {
        changedFields['nivel'] = _selectedNivel;
      }
      if (_obsController.text != widget.aluno.obs) {
        changedFields['obs'] = _obsController.text;
      }
      if (_photoBase64 != null) {
        changedFields['fotoUrl'] = 'data:image/jpeg;base64,$_photoBase64';
      }

      // Sempre incluir status e lastAtt
      changedFields['status'] = widget.aluno.status;
      changedFields['lastAtt'] = dataFormatada;

      final response = await _alunosServices.editAluno(
        uid,
        widget.aluno.uid,
        nome: changedFields['nome'],
        email: changedFields['email'],
        dataDeNascimento: changedFields['dataDeNascimento'],
        telefone: changedFields['telefone'],
        sexo: changedFields['sexo'],
        cpf: changedFields['cpf'],
        frequencia: changedFields['frequencia'],
        objetivo: changedFields['objetivo'],
        foco: changedFields['foco'],
        nivel: changedFields['nivel'],
        obs: changedFields['obs'],
        fotoUrl: changedFields['fotoUrl'],
        status: changedFields['status'],
        lastAtt: changedFields['lastAtt'],
      );

      if (response['status'] == 200) {
        _buttonBloc.add(ElevatedButtonActionCompleted());
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aluno atualizado com sucesso!'),
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
            content: Text('Erro ao atualizar aluno: ${e.toString()}'),
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

  // Reutilizar a mesma função de decoração do add_aluno_dialog
  InputDecoration _getInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 1200),
        decoration: BoxDecoration(
          color: Colors.grey[900],
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    'Editar Aluno',
                    style: SafeGoogleFont(
                      'Open Sans',
                      textStyle: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    hoverColor: Colors.grey[800],
                  ),
                ],
              ),
            ),
            // Conteúdo com scroll
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
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
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _photoUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              _photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.grey[400],
                                                );
                                              },
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo_outlined,
                                                size: 40,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Clique para alterar foto',
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Coluna dos campos - Igual ao add_aluno_dialog
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
                                            hintText: 'Digite o nome completo',
                                            prefixIcon: Icons.person_outline,
                                          ),
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
                                          validator: (value) {
                                            if (value?.isEmpty ?? true)
                                              return 'Campo obrigatório';
                                            if (!value!.contains('@'))
                                              return 'Email inválido';
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
                                          'Data de Nascimento*',
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
                                          'Telefone*',
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
                              // CPF
                              Row(
                                children: [
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
                                                    '$e por semana',
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
                                            setState(
                                                () => _selectedNivel = value!);
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
                                    decoration: _getInputDecoration(
                                      hintText: 'Digite observações adicionais',
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
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.grey[800]!, width: 1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: Text(
                                          'Cancelar',
                                          style: TextStyle(
                                              color: Colors.grey[400]),
                                        ),
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
                                                : () {
                                                    if (_formKey.currentState
                                                            ?.validate() ??
                                                        false) {
                                                      _buttonBloc.add(
                                                          ElevatedButtonPressed());
                                                      _atualizarAluno();
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 16,
                                              ),
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
                                                        Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : const Text('Atualizar'),
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
    );
  }
}
