import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../exercicios/model/exercicio_model.dart';
import '../../../../novo_treino/bloc/selecionar/events.dart';
import '../../../../novo_treino/bloc/selecionar/select_bloc.dart';
import '../../../../novo_treino/screens/components/modal.dart';
import '../../../../teste/dialog_treino_ia.dart';

class TreinoVazioWidget extends StatelessWidget {
  final List<Exercicio>? exercicios;
  final String? alunoUid;
  final String? sexo;
  const TreinoVazioWidget({super.key, required this.exercicios, this.alunoUid, this.sexo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FaIcon(
          FontAwesomeIcons.dumbbell,
          color: Colors.green,
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Adicione um exercício e comece a montar o seu treino',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: ElevatedButton(
            onPressed: () async {
              ExerciciosDialog(exercicios: exercicios!);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return ExerciciosDialog(exercicios: exercicios!);
                },
              );
              context
                  .read<ExercicioSelectionBloc>()
                  .add(ConfirmExercicioSelection());
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Adicionar exercício',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
        kIsWeb
            ? const SizedBox(
                height: 10,
              )
            : const SizedBox.shrink(),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DialogTreinoIa(
                    sexo: sexo,
                    uid: alunoUid,
                  ),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Criar treino com IA',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
