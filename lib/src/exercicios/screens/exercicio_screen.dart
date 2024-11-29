import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../utils.dart';
import '../model/exercicio_model.dart';

class ExercicioScreen extends StatefulWidget {
  final Exercicio exercicio;
  const ExercicioScreen({super.key, required this.exercicio});

  @override
  State<ExercicioScreen> createState() => _ExercicioScreenState();
}

class _ExercicioScreenState extends State<ExercicioScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.exercicio.videoUrl),
    )..initialize().then((_) {
        _controller
          ..setLooping(true) // Configura o vídeo para loop
          ..play(); // Inicia o vídeo automaticamente

        // Atualiza o estado para refletir o vídeo carregado
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.exercicio.nome,
                        style: SafeGoogleFont('Open Sans',
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${widget.exercicio.mecanismo})',
                        style: SafeGoogleFont('Open Sans',
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Primário: ',
                        style: SafeGoogleFont('Open Sans',
                            fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        widget.exercicio.grupoMuscular,
                        style: SafeGoogleFont('Open Sans',
                            fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Secundário: ',
                        style: SafeGoogleFont('Open Sans',
                            fontSize: 16, color: Colors.grey),
                      ),
                      ...List.generate(
                        widget.exercicio.sinergista.length,
                        (index) {
                          var gm = widget.exercicio.sinergista[index];
                          bool isLast =
                              index == widget.exercicio.sinergista.length - 1;
                          return Text(
                            isLast ? gm : '$gm, ',
                            style: SafeGoogleFont('Open Sans',
                                fontSize: 16, color: Colors.grey),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
