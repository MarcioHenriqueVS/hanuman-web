import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import '../../antropometria/bloc/get_foto_avaliacao/get_foto_avaliacao_bloc.dart';

class ChangeFotoAvaliacaoWidget extends StatefulWidget {
  final int index;
  final GetFotoAvaliacaoState fotoState;
  const ChangeFotoAvaliacaoWidget(
      {super.key, required this.index, required this.fotoState});

  @override
  State<ChangeFotoAvaliacaoWidget> createState() =>
      _ChangeFotoAvaliacaoWidgetState();
}

class _ChangeFotoAvaliacaoWidgetState extends State<ChangeFotoAvaliacaoWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Material(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _showImage(widget.fotoState.fotos[widget.index]!),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(5)),
                  child: Image.memory(
                    widget.fotoState.fotos[widget.index]!,
                    height: 42,
                    width: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Foto ${widget.index + 1}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    BlocProvider.of<GetFotoAvaliacaoBloc>(context)
                        .add(SelecionarFotoEvent(widget.index));
                  },
                  icon: Icon(Icons.edit, size: 18, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImage(Uint8List imageUrl) {
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
              imageProvider: MemoryImage(imageUrl),
            ),
          ),
        );
      },
    );
  }
}
