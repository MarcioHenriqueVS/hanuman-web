import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_services.dart';
import '../../../screens/components/form_criar_exercicio.dart';
import '../bloc/foto_bloc.dart';
import '../bloc/states_foto.dart';
import '../bloc/states_video.dart';
import '../bloc/video_bloc.dart';

class CriarExercicio extends StatelessWidget {
  final String grupoMuscular;
  final String mecanismo;
  CriarExercicio(
      {super.key, required this.grupoMuscular, required this.mecanismo});

  final TextEditingController nomeDoExercicioController =
      TextEditingController();
  final TextEditingController agonistasController = TextEditingController();
  final TextEditingController antagonistasController = TextEditingController();
  final TextEditingController sinergistasController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AdminServices adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cadastrar Exercício',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (_) => FotoBloc(adminServices: adminServices)),
                    BlocProvider(
                        create: (_) => VideoBloc(adminServices: adminServices)),
                  ],
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<FotoBloc, SelectFotoState>(
                        listener: (context, state) {},
                      ),
                      BlocListener<VideoBloc, SelectVideoState>(
                        listener: (context, state) {},
                      ),
                    ],
                    child: FormCriarExercicio(
                      nomeDoExercicio: nomeDoExercicioController,
                      grupoMuscular: grupoMuscular,
                      mecanismo: mecanismo,
                      formKey: formKey,
                      agonistasController: agonistasController,
                      antagonistasController: antagonistasController,
                      sinergistasController: sinergistasController,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
