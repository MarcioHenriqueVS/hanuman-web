import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../antropometria/bloc/get_avaliacao_recente/get_avaliacao_recente_bloc.dart';
import '../antropometria/bloc/get_avaliacao_recente/get_avaliacao_recente_event.dart';
import '../antropometria/bloc/get_avaliacao_recente/get_avaliacao_recente_state.dart';
import '../antropometria/models/avaliacao_model.dart';
import '../models/aluno_model.dart';
import '../../utils.dart';
import 'avaliacoes/avaliacoes_list_page.dart';
import 'treinos/aluno_pastas_list_page.dart';

class AlunoProfilePage extends StatefulWidget {
  final AlunoModel aluno;
  const AlunoProfilePage({super.key, required this.aluno});

  @override
  State<AlunoProfilePage> createState() => _AlunoProfilePageState();
}

class _AlunoProfilePageState extends State<AlunoProfilePage> {
  @override
  void initState() {
    BlocProvider.of<GetAvaliacaoMaisRecenteBloc>(context).add(
      BuscarAvaliacaoMaisRecente(widget.aluno.uid),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perfil do Aluno',
                            style: SafeGoogleFont(
                              'Outfit',
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Veja os dados do aluno',
                            style: SafeGoogleFont(
                              'Readex Pro',
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: widget.aluno.status != null
                                      ? widget.aluno.status!
                                          ? Colors.green
                                          : Colors.red
                                      : Colors.red,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  widget.aluno.status != null
                                      ? widget.aluno.status!
                                          ? 'ATIVO'
                                          : 'INATIVO'
                                      : 'INATIVO',
                                  style: SafeGoogleFont('Outfit'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey[800]!, width: 4),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          NetworkImage(widget.aluno.fotoUrl!),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.aluno.nome,
                                          style: SafeGoogleFont(
                                            'Outfit',
                                            textStyle: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.email_outlined,
                                                size: 20,
                                                color: Colors.green[400]),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.aluno.email,
                                              style: SafeGoogleFont(
                                                'Readex Pro',
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green[400],
                                                ),
                                              ),
                                            ),
                                          ],
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
                      const SizedBox(height: 24),
                      // Grid de Informações
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  'Informações Pessoais',
                                  Icons.person_outline,
                                  [
                                    _buildInfoItem(
                                        'ID', '#${widget.aluno.uid}'),
                                    _buildInfoItem('CPF',
                                        widget.aluno.cpf ?? 'Não informado'),
                                    _buildInfoItem(
                                        'Data de Nascimento',
                                        widget.aluno.dataDeNascimento ??
                                            'Não informado'),
                                    _buildInfoItem(
                                        'Telefone',
                                        widget.aluno.telefone ??
                                            'Não informado'),
                                    _buildInfoItem(
                                        'Objetivo',
                                        widget.aluno.objetivo ??
                                            'Não informado'),
                                    _buildInfoItem(
                                        'Frequência',
                                        widget.aluno.frequencia != null
                                            ? '${widget.aluno.frequencia} por semana'
                                            : 'Não informado'),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                BlocBuilder<GetAvaliacaoMaisRecenteBloc,
                                    GetAvaliacaoMaisRecenteState>(
                                  builder: (context, state) {
                                    if (state
                                            is GetAvaliacaoMaisRecenteLoading ||
                                        state
                                            is GetAvaliacaoMaisRecenteInitial) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state
                                        is GetAvaliacaoMaisRecenteError) {
                                      return Center(
                                        child: Text(
                                          state.message,
                                          style: SafeGoogleFont(
                                            'Readex Pro',
                                            textStyle: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (state
                                        is GetAvaliacaoMaisRecenteEmpty) {
                                      return
                                          // const Center(
                                          //   child: Text('Nenhuma avaliação encontrada'),
                                          // );
                                          _buildInfoCard(
                                        'Dados Físicos',
                                        Icons.fitness_center,
                                        [
                                          Center(
                                            child: Text(
                                              'Nenhuma avaliação encontrada',
                                              style: SafeGoogleFont(
                                                'Readex Pro',
                                                textStyle: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else if (state
                                        is GetAvaliacaoMaisRecenteLoaded) {
                                      AvaliacaoModel avaliacao =
                                          state.avaliacao;
                                      return _buildInfoCard(
                                        'Dados Físicos',
                                        Icons.fitness_center,
                                        [
                                          _buildInfoItem(
                                              'Altura',
                                              avaliacao.altura != null
                                                  ? '${avaliacao.altura!.toStringAsFixed(2)} m'
                                                  : 'Não informado'),
                                          _buildInfoItem(
                                              'Peso Atual',
                                              avaliacao.peso != null
                                                  ? '${avaliacao.peso!.toStringAsFixed(2)} kg'
                                                  : 'Não informado'),
                                          _buildInfoItem(
                                              'Gordura Corporal',
                                              avaliacao.bf != null
                                                  ? '${avaliacao.bf!.toStringAsFixed(2)}%'
                                                  : 'Não informado'),
                                          _buildInfoItem(
                                              'Massa Magra',
                                              avaliacao.mm != null
                                                  ? '${avaliacao.mm!.toStringAsFixed(2)} kg'
                                                  : 'Não informado'),
                                          _buildInfoItem(
                                              'IMC',
                                              avaliacao.imc != null
                                                  ? avaliacao.imc!
                                                      .toStringAsFixed(2)
                                                  : 'Não informado'),
                                        ],
                                      );
                                    } else {
                                      return const Center(
                                        child: Text('Falha ao carregar dados'),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  'Status do Treino',
                                  Icons.sports_gymnastics,
                                  [
                                    _buildActivityItem(
                                      'Último Treino',
                                      'Hoje, 14:30',
                                      Icons.calendar_today,
                                    ),
                                    _buildActivityItem(
                                      'Próximo Treino',
                                      'Em desenvolvimento',
                                      Icons.calendar_today,
                                    ),
                                    _buildActivityItem(
                                      'Série Atual',
                                      'Em desenvolvimento',
                                      Icons.assignment,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildInfoCard(
                                  'Ações',
                                  Icons.admin_panel_settings_outlined,
                                  [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _buildActionButton(
                                            'Avaliações Físicas',
                                            Icons.straighten,
                                            Colors.blue,
                                            () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AvaliacoesListPage(
                                                    aluno: widget.aluno,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _buildActionButton(
                                            'Painel de Treinos',
                                            Icons.assignment_outlined,
                                            Colors.green,
                                            () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AlunoPastasListPage(
                                                    alunoUid: widget.aluno.uid,
                                                    sexo: widget.aluno.sexo,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _buildActionButton(
                                            'Excluir Aluno',
                                            Icons.delete_outline,
                                            Colors.red,
                                            () {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: SafeGoogleFont(
                    'Outfit',
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SafeGoogleFont(
              'Readex Pro',
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
          Text(
            value,
            style: SafeGoogleFont(
              'Readex Pro',
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: SafeGoogleFont(
                    'Readex Pro',
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Text(
                  value,
                  style: SafeGoogleFont(
                    'Readex Pro',
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: SafeGoogleFont(
          'Readex Pro',
          textStyle: const TextStyle(color: Colors.white),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
