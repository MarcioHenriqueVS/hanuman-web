import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../../../../../atualizacoes/atts_bloc/qtd_missoes_pendentes_bloc.dart';
import '../../../../../atualizacoes/atts_bloc/qtd_missoes_pendentes_state.dart';
import '../../../../../utils.dart';
import 'att_home_widget.dart';

class DashboardAtts extends StatefulWidget {
  final bool isSamallScreen;
  const DashboardAtts({super.key, required this.isSamallScreen});

  @override
  State<DashboardAtts> createState() => _DashboardAttsState();
}

class _DashboardAttsState extends State<DashboardAtts> {
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).scaffoldBackgroundColor,
      highlightColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Cor um pouco mais clara que a cor de fundo para o shimmer
                color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 60,
                        height: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttsHomeBloc, AttsHomeState>(
      builder: (context, attsState) {
        return BlocBuilder<GetAlunosBloc, GetAlunosState>(
          builder: (context, alunosState) {
            if (attsState is AttsHomeInitial || attsState is AttsHomeLoading) {
              return _buildShimmerEffect();
            } else if (attsState is AttsHomeLoaded &&
                alunosState is GetAlunosLoaded) {
              if (attsState.atts.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        'Nenhuma atualização disponível!',
                        style: SafeGoogleFont(
                          'Open Sans',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: attsState.atts.length,
                itemBuilder: (context, index) {
                  final att = attsState.atts[index];
                  final aluno = alunosState.alunos.firstWhere(
                    (aluno) => aluno.uid == att['alunoUid'],
                    //orElse: () => AlunoModel.empty(),
                  );

                  return AttHomeWidget(
                    key: ValueKey(att['id']),
                    tipo: att['tipo'],
                    titulo: att['titulo'],
                    descricao: att['descricao'],
                    timestamp: att['timestamp'],
                    alunoUid: att['alunoUid'],
                    treinoDocId: att['treinoDocId'],
                    isSmallScreen: widget.isSamallScreen,
                    aluno: aluno, // Passando o aluno diretamente
                  );
                },
              );
            } else if (attsState is AttsHomeError) {
              return const Center(
                child: Text('Erro ao buscar dados, atualize a tela!'),
              );
            } else {
              return const Center(
                child: Text('Erro inesperado, atualize a tela!'),
              );
            }
          },
        );
      },
    );
  }
}
