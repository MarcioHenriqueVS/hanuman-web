import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../antropometria/bloc/get_avaliacoes_data/get_avaliacoes_data_bloc.dart';
import '../../antropometria/bloc/get_avaliacoes_data/get_avaliacoes_data_event.dart';
import '../../antropometria/bloc/get_avaliacoes_data/get_avaliacoes_data_state.dart';
import '../../antropometria/models/avaliacao_model.dart';
import '../../../utils.dart';
import '../../models/aluno_model.dart';
import 'add_ava_prototipo.dart';
import 'avaliacao_page.dart';
import '../../../flutter_flow/ff_button_options.dart';

class AvaliacoesListPage extends StatefulWidget {
  final AlunoModel aluno;
  const AvaliacoesListPage({super.key, required this.aluno});

  @override
  State<AvaliacoesListPage> createState() => _AvaliacoesListPageState();
}

class _AvaliacoesListPageState extends State<AvaliacoesListPage> {
  Map<int, bool> hoveredItems = {};

  @override
  void initState() {
    BlocProvider.of<GetAvaliacoesDataBloc>(context).add(
      BuscarAvaliacoesData(widget.aluno.uid),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocBuilder<GetAvaliacoesDataBloc,
                      GetAvaliacoesDataState>(
                    builder: (context, state) {
                      if (state is GetAvaliacoesDataLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is GetAvaliacoesDataLoaded) {
                        return _buildAvaliacoesList(state.avaliacoes);
                      } else if (state is GetAvaliacoesDataEmpty) {
                        return _buildEmptyState();
                      } else if (state is GetAvaliacoesDataError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                        'Avaliações Antropométricas',
                        style: SafeGoogleFont(
                          'Open Sans',
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acompanhamento do progresso físico',
                        style: SafeGoogleFont(
                          'Open Sans',
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
              FFButtonWidget(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddAvaPrototipo(
                                aluno: widget.aluno,
                              )));
                },
                text: 'Nova avaliação',
                icon: const Icon(
                  Icons.add_rounded,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: Colors.green,
                  textStyle: SafeGoogleFont(
                    'Open Sans',
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
        ),
      ),
    );
  }

  Widget _buildAvaliacoesList(List<AvaliacaoModel> avaliacoes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: avaliacoes.length,
      itemBuilder: (context, index) {
        return _buildAvaliacaoCard(avaliacoes[index], index);
      },
    );
  }

  Widget _buildAvaliacaoCard(AvaliacaoModel avaliacao, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hoveredItems[index] = true),
        onExit: (_) => setState(() => hoveredItems[index] = false),
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvaliacaoPage(
                  avaliacao: avaliacao,
                  aluno: widget.aluno,
                ),
              ),
            );
            if (result != null && result is AvaliacaoModel) {
              BlocProvider.of<GetAvaliacoesDataBloc>(context).add(
                AtualizarAvaliacaoData(result),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: hoveredItems[index] == true
                    ? Theme.of(context).dividerColor
                    : Colors.transparent,
              ),
            ),
            child: AnimatedScale(
              scale: hoveredItems[index] == true ? 1.005 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          avaliacao.titulo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          avaliacao.timestamp,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _buildDataItem('Altura',
                            '${avaliacao.altura?.toStringAsFixed(2) ?? "-"} m'),
                        _buildDataItem('Peso',
                            '${avaliacao.peso?.toStringAsFixed(2) ?? "-"} kg'),
                        _buildDataItem('Gordura Corporal',
                            '${avaliacao.bf?.toStringAsFixed(2) ?? "-"}%'),
                        _buildDataItem('Massa Magra',
                            '${avaliacao.mm?.toStringAsFixed(2) ?? "-"} kg'),
                        _buildDataItem(
                            'IMC', avaliacao.imc?.toStringAsFixed(2) ?? "-"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(
                duration: const Duration(milliseconds: 300),
              ),
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma avaliação encontrada',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
