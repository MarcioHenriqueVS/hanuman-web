import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../antropometria/bloc/get_foto_avaliacao/get_foto_avaliacao_bloc.dart';

class AddFotoAvaliacaoWidget extends StatefulWidget {
  final int index;
  const AddFotoAvaliacaoWidget({super.key, required this.index});

  @override
  State<AddFotoAvaliacaoWidget> createState() => _AddFotoAvaliacaoWidgetState();
}

class _AddFotoAvaliacaoWidgetState extends State<AddFotoAvaliacaoWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ElevatedButton(
        onPressed: () {
          BlocProvider.of<GetFotoAvaliacaoBloc>(context)
              .add(SelecionarFotoEvent(widget.index));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.grey[400],
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.grey[700]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'Adicionar foto',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
