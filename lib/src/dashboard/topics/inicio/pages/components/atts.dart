import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttsHomeBloc, AttsHomeState>(
      builder: (context, attsState) {
        if (attsState is AttsHomeInitial) {
          return const Center(
            child: Text('Buscando atualizações...'),
          );
        } else if (attsState is AttsHomeLoading) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: SpinKitThreeBounce(
                color: Colors.green,
              ),
            ),
          );
        } else if (attsState is AttsHomeError) {
          return const Center(
            child: Text('Erro ao buscar dados, atualize a tela!'),
          );
        } else if (attsState is AttsHomeLoaded) {
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
                      textStyle: const TextStyle(
                        fontSize: 16,
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
              return AttHomeWidget(
                key: ValueKey(att['id']), // Usar a chave única para o widget
                tipo: att['tipo'],
                titulo: att['titulo'],
                descricao: att['descricao'],
                timestamp: att['timestamp'],
                alunoUid: att['alunoUid'],
                treinoDocId: att['treinoDocId'],
                isSmallScreen: widget.isSamallScreen,
              );
            },
          );
        } else {
          return const Center(
            child: Text('Erro inesperado, atualize a tela!'),
          );
        }
      },
    );
  }
}
