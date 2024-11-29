import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../exercicios/bloc/event.dart';
import '../../../../exercicios/bloc/exercicios_bloc.dart';
import '../../../../exercicios/bloc/state.dart';
import '../../../../exercicios/model/exercicio_model.dart';
import 'components/loaded_screen.dart';
import 'components/loading_screen.dart';

class NovoTreinoPersonalScreen2 extends StatefulWidget {
  final String pastaId;
  final String funcao;
  final String? alunoUid;
  final String? sexo;
  const NovoTreinoPersonalScreen2({
    super.key,
    required this.pastaId,
    required this.funcao,
    this.alunoUid,
    this.sexo,
  });

  @override
  State<NovoTreinoPersonalScreen2> createState() =>
      _NovoTreinoPersonalScreen2State();
}

class _NovoTreinoPersonalScreen2State extends State<NovoTreinoPersonalScreen2> {
  @override
  void initState() {
    BlocProvider.of<ExercicioBloc>(context).add(
      LoadExercicios(),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercicioBloc, ExercicioState>(
      builder: (context, exercicioState) {
        List<Exercicio>? exercicios;
        if (exercicioState is ExercicioLoading) {
          return LoadingScreen();
        } else if (exercicioState is ExercicioLoaded) {
          exercicios = exercicioState.exercicios;
          return LoadedScreen(
            exercicios: exercicios,
            pastaId: widget.pastaId,
            funcao: widget.funcao,
            alunoUid: widget.alunoUid,
          );
        } else {
          return const Center(
            child: Text('Recarregue a tela'),
          );
        }
      },
    );
  }
}
