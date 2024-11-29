import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../bloc/get_pastas_personal/get_pastas_state.dart';
import '../pages/galeria/components/add_pasta_dialog.dart';
import 'models/training_sheet.dart';
import 'salvar_treino_dialog.dart';

class PersonalModal extends StatefulWidget {
  final List<TrainingSheet>? treinos;
  const PersonalModal({super.key, this.treinos});

  @override
  State<PersonalModal> createState() => _PersonalModalState();
}

class _PersonalModalState extends State<PersonalModal> {
  final TextEditingController pastaIdController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  void salvarTreinoDialog(String pastaId, List<TrainingSheet> trainingSheets) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => SalvarTreinoDialog(
        pastaId: pastaId,
        trainingSheets: trainingSheets,
        uid: uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPastasPersonalBloc, GetPastasPersonalState>(
      builder: (context, pastasState) {
        if (pastasState is GetPastasPersonalInitial) {
          return const Center(
            child: Text('Iniciando busca das pastas'),
          );
        } else if (pastasState is GetPastasPersonalLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (pastasState is GetPastasPersonalError) {
          return const Center(
            child: Text(
              'Erro ao tentar buscar pastas, recarregue a tela',
              textAlign: TextAlign.center,
            ),
          );
        } else if (pastasState is GetPastasPersonalLoaded) {
          final pastasIds = pastasState.pastasIds;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.folder_copy_outlined,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(
                        child: Container(
                          width: 50,
                          height: 2,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AddPastaDialog(pastaAluno: false),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pastasIds.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              salvarTreinoDialog(
                                  pastasIds[index]['id'], widget.treinos!);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[900]!.withOpacity(0.4),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(pastasIds[index]['nome']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('Erro inesperado, tente novamente'),
          );
        }
      },
    );
  }
}
