import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../exercicios/ criar_exercicio/bloc/events_foto.dart';
import '../../exercicios/ criar_exercicio/bloc/events_video.dart';
import '../../exercicios/ criar_exercicio/bloc/foto_bloc.dart';
import '../../exercicios/ criar_exercicio/bloc/states_foto.dart';
import '../../exercicios/ criar_exercicio/bloc/states_video.dart';
import '../../exercicios/ criar_exercicio/bloc/video_bloc.dart';
import '../../exercicios/services/admin_services.dart';

class FormCriarExercicio extends StatelessWidget {
  final String grupoMuscular;
  final String mecanismo;
  final TextEditingController nomeDoExercicio;
  final TextEditingController agonistasController;
  final TextEditingController antagonistasController;
  final TextEditingController sinergistasController;
  final GlobalKey<FormState> formKey;

  FormCriarExercicio({
    Key? key,
    required this.grupoMuscular,
    required this.mecanismo,
    required this.nomeDoExercicio,
    required this.agonistasController,
    required this.antagonistasController,
    required this.sinergistasController,
    required this.formKey,
  }) : super(key: key);

  final AdminServices adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nomeDoExercicio,
                decoration: const InputDecoration(
                  labelText: 'Nome do exercício',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: agonistasController,
                decoration: const InputDecoration(
                  labelText: 'Agonistas (separados por vírgula)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira os músculos agonistas';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: antagonistasController,
                decoration: const InputDecoration(
                  labelText: 'Antagonistas (separados por vírgula)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira os músculos antagonistas';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: sinergistasController,
                decoration: const InputDecoration(
                  labelText: 'Sinergistas (separados por vírgula)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira os músculos sinergistas';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final fotoBloc = context.read<FotoBloc>();
                  // Chamada para o evento que seleciona a foto
                  fotoBloc.add(FotoSelected());

                  // Esperar pelo carregamento da foto
                  String? selectedImage;
                  await for (var state in fotoBloc.stream) {
                    if (state is SelectFotoLoaded) {
                      selectedImage = state.foto;
                      debugPrint(selectedImage);
                      break;
                    }
                  }
                },
                child: const Text('Selecionar Imagem'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final videoBloc = context.read<VideoBloc>();

                  videoBloc.add(VideoSelected());

                  String? selectedVideo;
                  await for (var state in videoBloc.stream) {
                    if (state is SelectVideoLoaded) {
                      selectedVideo = state.video;
                      debugPrint(selectedVideo);
                      break;
                    }
                  }
                },
                child: const Text('Selecionar Vídeo'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    List<String> agonistas = agonistasController.text
                        .split(',')
                        .map((s) => s.trim())
                        .toList();
                    List<String> antagonistas = antagonistasController.text
                        .split(',')
                        .map((s) => s.trim())
                        .toList();
                    List<String> sinergistas = sinergistasController.text
                        .split(',')
                        .map((s) => s.trim())
                        .toList();

                    var fotoState = context.read<FotoBloc>().state;
                    var videoState = context.read<VideoBloc>().state;
                    String? selectedImage, selectedVideo;

                    if (fotoState is SelectFotoLoaded) {
                      selectedImage = fotoState.foto;
                    }
                    if (videoState is SelectVideoLoaded) {
                      selectedVideo = videoState.video;
                    }

                    // Chama a função criarExercicio com todos os parâmetros necessários
                    bool success = await adminServices.criarExercicio(
                      nomeDoExercicio.text,
                      grupoMuscular,
                      mecanismo,
                      agonistas,
                      antagonistas,
                      sinergistas,
                      selectedImage,
                      selectedVideo,
                    );

                    if (success) {
                      // Fazer algo em caso de sucesso (ex: mostrar uma mensagem ou navegar para outra página)
                    } else {
                      // Fazer algo em caso de falha (ex: mostrar uma mensagem de erro)
                    }
                  }
                },
                child: const Text('Criar Exercício'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
