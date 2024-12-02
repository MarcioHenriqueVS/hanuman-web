import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
          maxHeight: 800,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2ECC71),
                      ),
                    )
                  : Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: Container(
                            color: const Color(0xFF1D1D1D),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMainMetricsCards(newTreino!),
                                    const SizedBox(height: 40),
                                    if (newTreino!.foto != null &&
                                        newTreino!.foto!.isNotEmpty)
                                      _buildImageContainer(newTreino!, width),
                                    const SizedBox(height: 40),
                                    _buildActionButtons(newTreino!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF2ECC71),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detalhes do Treino',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.close, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  Widget _buildMainMetricsCards(TreinoFinalizado treino) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas do Treino',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _buildMetricCard(
                icon: Icons.timer_outlined,
                label: 'DURAÇÃO',
                value: treino.duracao!,
                color: const Color(0xFF2ECC71),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMetricCard(
                icon: Icons.fitness_center,
                label: 'VOLUME',
                value: '${treino.volume!} kg',
                color: const Color(0xFF2ECC71),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMetricCard(
                icon: Icons.repeat,
                label: 'SÉRIES',
                value: treino.series!,
                color: const Color(0xFF2ECC71),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(TreinoFinalizado treino, double width) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registro Visual',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showImage(cachedNetworkImage!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fullscreen,
                              color: Color(0xFF2ECC71), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Expandir',
                            style: TextStyle(
                              color: Color(0xFF2ECC71),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ...existing image widget code...
        ],
      ),
    );
  }

  Widget _buildActionButtons(TreinoFinalizado treino) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: FontAwesomeIcons.heart,
            label: 'Curtir',
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.visibility_outlined,
            label: 'Ver detalhes do treino',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TreinoFinalizadoDetailsScreen(
                    treino: treino,
                  ),
                ),
              );
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary
                ? const Color(0xFF2ECC71).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFF2ECC71).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary ? const Color(0xFF2ECC71) : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? const Color(0xFF2ECC71) : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
