import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils.dart';
import '../../../antropometria/bloc/get_foto_avaliacao/get_foto_avaliacao_bloc.dart';
import '../../components/add_foto_widget.dart';
import '../../components/change_foto_avaliacao.dart';

class SelectPhotosContainer extends StatelessWidget {
  final Uint8List? foto1;
  final Uint8List? foto2;
  final Uint8List? foto3;
  final Uint8List? foto4;
  final Function(Uint8List?, int) onFotoChanged; // Novo callback

  const SelectPhotosContainer({
    super.key,
    this.foto1,
    this.foto2,
    this.foto3,
    this.foto4,
    required this.onFotoChanged, // Adicionar no construtor
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('SelectPhotosContainer');
    debugPrint('foto1: $foto1');
    debugPrint('foto2: $foto2');
    debugPrint('foto3: $foto3');
    debugPrint('foto4: $foto4');
    
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;
    return Container(
      width: isSmallScreen ? MediaQuery.of(context).size.width * 0.55 : 600,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fotos',
              style: SafeGoogleFont(
                'Open Sans',
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            BlocConsumer<GetFotoAvaliacaoBloc, GetFotoAvaliacaoState>(
              listener: (context, fotoState) {
                if (fotoState is GetFotoAvaliacaoLoaded) {
                  // Chamar callback quando as fotos forem carregadas
                  onFotoChanged(fotoState.fotos[0], 0);
                  onFotoChanged(fotoState.fotos[1], 1);
                  onFotoChanged(fotoState.fotos[2], 2);
                  onFotoChanged(fotoState.fotos[3], 3);
                } else if (fotoState is GetFotoAvaliacaoInitial) {
                  // Limpar fotos
                  onFotoChanged(null, 0);
                  onFotoChanged(null, 1);
                  onFotoChanged(null, 2);
                  onFotoChanged(null, 3);
                }
              },
              builder: (context, fotoState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: foto1 != null
                                  ? ChangeFotoAvaliacaoWidget(
                                      index: 0, fotoState: fotoState)
                                  : const AddFotoAvaliacaoWidget(index: 0)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: foto2 != null
                                  ? ChangeFotoAvaliacaoWidget(
                                      index: 1, fotoState: fotoState)
                                  : const AddFotoAvaliacaoWidget(index: 1)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: foto3 != null
                                  ? ChangeFotoAvaliacaoWidget(
                                      index: 2, fotoState: fotoState)
                                  : const AddFotoAvaliacaoWidget(index: 2)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: foto4 != null
                                  ? ChangeFotoAvaliacaoWidget(
                                      index: 3, fotoState: fotoState)
                                  : const AddFotoAvaliacaoWidget(index: 3)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
