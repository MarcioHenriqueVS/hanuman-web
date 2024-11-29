import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../exercicios/model/exercicio_model.dart';
import '../../../../novo_treino/bloc/selecionar/events.dart';
import '../../../../novo_treino/bloc/selecionar/select_bloc.dart';
import '../../../../novo_treino/bloc/selecionar/states.dart';
import '../../../../novo_treino/screens/components/modal.dart';

class AddExercicioButton extends StatelessWidget {
  final List<Exercicio>? exercicios;
  const AddExercicioButton({super.key, required this.exercicios});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercicioSelectionBloc, ExercicioSelectionState>(
      builder: (selectionContext, selectionState) {
        if (selectionState.selectedExercicios.isNotEmpty) {
          return ElevatedButton(
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
                  Icon(Icons.add),
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
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
