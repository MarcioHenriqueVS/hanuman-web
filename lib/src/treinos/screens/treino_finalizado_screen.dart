import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import '../bloc/get_treino_finalizado/get_treino_finalizado_bloc.dart';
import '../bloc/get_treino_finalizado/get_treino_finalizado_event.dart';
import '../bloc/get_treino_finalizado/get_treino_finalizado_state.dart';
import '../models/exercicio_treino_model.dart';
import '../models/treino_model.dart';
import 'treino_start.dart';

class TreinoFinalizadoScreen extends StatefulWidget {
  final TreinoFinalizado? treino;
  final String? treinoId;
  final String alunoUid;

  const TreinoFinalizadoScreen({
    super.key,
    this.treino,
    this.treinoId,
    required this.alunoUid,
  });

  @override
  State<TreinoFinalizadoScreen> createState() => _TreinoFinalizadoScreenState();
}

class _TreinoFinalizadoScreenState extends State<TreinoFinalizadoScreen> {
  TreinoFinalizado? newTreino;
  CachedNetworkImageProvider? cachedNetworkImage;

  @override
  void initState() {
    verificarTreino();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void verificarTreino() async {
    if (widget.treino == null) {
      BlocProvider.of<GetTreinoFinalizadoBloc>(context).add(
        BuscarTreinoFinalizado(widget.alunoUid, widget.treinoId!),
      );
    } else {
      setState(() {
        newTreino = widget.treino;
        newTreino!.foto != null
            ? cachedNetworkImage = CachedNetworkImageProvider(
                newTreino!.foto!,
              )
            : null;
      });
    }
  }

  void verificarFoto() {}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
        ),
        child: IntrinsicHeight(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                BlocConsumer<GetTreinoFinalizadoBloc, GetTreinoFinalizadoState>(
              listener: (context, treinoState) {
                if (treinoState is GetTreinoFinalizadoLoaded) {
                  setState(
                    () {
                      newTreino = treinoState.treino;
                      newTreino!.foto != null
                          ? cachedNetworkImage = CachedNetworkImageProvider(
                              newTreino!.foto!,
                            )
                          : null;
                    },
                  );
                }
              },
              builder: (context, state) {
                return newTreino == null
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.green,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMainMetricsCards(newTreino!),
                                  const SizedBox(height: 24),
                                  if (newTreino!.foto != null &&
                                      newTreino!.foto!.isNotEmpty)
                                    _buildImageContainer(newTreino!, width),
                                  const SizedBox(height: 24),
                                  _buildActionButtons(newTreino!),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Detalhes do Treino',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetricsCards(TreinoFinalizado treino) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Duração',
            value: treino.duracao!,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            label: 'Volume',
            value: '${treino.volume!} kg',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            label: 'Séries',
            value: treino.series!,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(TreinoFinalizado treino, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registro Visual',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            children: [
              Image(image: cachedNetworkImage!),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => _showImage(cachedNetworkImage!),
                  icon: const Icon(Icons.fullscreen),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TreinoFinalizado treino) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TreinoFinalizadoDetailsScreen(
                  treino: treino,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Ver detalhes'),
        ),
      ],
    );
  }

  String intervaloTipoParaString(IntervaloTipo tipo) {
    switch (tipo) {
      case IntervaloTipo.segundos:
        return 'segundos';
      case IntervaloTipo.minutos:
        return 'minutos';
      default:
        return '';
    }
  }

  void _showImage(CachedNetworkImageProvider cachedNetworkImageProvider) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.9,
            child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 2,
              imageProvider: cachedNetworkImageProvider,
            ),
          ),
        );
      },
    );
  }
}
