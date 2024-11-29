import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../../../../../alunos/models/aluno_model.dart';
import '../../../../../alunos/pages/aluno_profile_page.dart';
import '../../../../../utils.dart';

class AlunosRecentesList extends StatefulWidget {
  const AlunosRecentesList({super.key});

  @override
  State<AlunosRecentesList> createState() => _AlunosRecentesListState();
}

class _AlunosRecentesListState extends State<AlunosRecentesList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAlunosBloc, GetAlunosState>(
      builder: (context, state) {
        if (state is GetAlunosLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetAlunosError) {
          return Center(child: Text('Erro: ${state.message}'));
        }

        if (state is GetAlunosDataIsEmpty) {
          return const Center(child: Text('Nenhum aluno encontrado'));
        }

        if (state is GetAlunosLoaded) {
          List<AlunoModel> alunos = state.alunos;
          alunos.sort((a, b) => (b.lastAtt ?? '').compareTo(a.lastAtt ?? ''));
          if (alunos.length > 5) {
            alunos = alunos.take(5).toList();
          }
          return Expanded(
            child: ListView.builder(
              itemCount: alunos.length,
              itemBuilder: (context, index) {
                final aluno = alunos[index];
                return Padding(padding: EdgeInsets.symmetric(vertical: 3), child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlunoProfilePage(aluno: aluno),
                        ),
                      );
                    },
                    child: Container(
                      //margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFF121212),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(aluno.fotoUrl ??
                                'https://i.pravatar.cc/150?img=1'),
                            radius: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aluno.nome,
                                  style: SafeGoogleFont(
                                    'Readex Pro',
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  aluno.email,
                                  style: SafeGoogleFont(
                                    'Readex Pro',
                                    textStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Última atualização:',
                                style: SafeGoogleFont(
                                  'Readex Pro',
                                  textStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                aluno.lastAtt ?? 'Não registrado',
                                style: SafeGoogleFont(
                                  'Readex Pro',
                                  textStyle: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),);
              },
            ),
          );
        }
        return const Center(child: Text('Estado não tratado'));
      },
    );
  }
}
