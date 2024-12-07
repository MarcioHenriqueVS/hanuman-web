// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../../autenticacao/tratamento/success_snackbar.dart';
// import '../../../../../exercicios/model/exercicio_model.dart';
// import '../../../../../utils.dart';
// import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
// import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
// import '../../../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
// import '../../../../bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
// import '../../../../models/exercicio_treino_model.dart';
// import '../../../../models/serie_model.dart';
// import '../../../../models/treino_model.dart';
// import '../../../../novo_treino/bloc/selecionar/select_bloc.dart';
// import '../../../../services/treino_services.dart';
// import '../../../../services/treinos_personal_service.dart';
// import '../criar_treino_personal_services.dart';

// class TreinoAppBar extends StatelessWidget {
//   final String pastaId;
//   final Map<String, String?> exerciseIntervalMap;
//   final Map<String, List<Serie>> exercicioSeriesMap;
//   final String titulo;
//   final Map<String, String> exercicioNotesMap;
//   final String uid;
//   final String funcao;
//   final String? alunoUid;
//   TreinoAppBar({
//     super.key,
//     required this.pastaId,
//     required this.exerciseIntervalMap,
//     required this.exercicioSeriesMap,
//     required this.titulo,
//     required this.uid,
//     required this.exercicioNotesMap,
//     required this.funcao,
//     this.alunoUid,
//   });

//   final TreinosPersonalServices _treinosPersonalServices =
//       TreinosPersonalServices();
//   final TreinoServices _treinoServices = TreinoServices();
//   final CriarTreinoServices criarTreinoPersonalServices = CriarTreinoServices();

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const SizedBox(
//             width: 57,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text('Cancelar'),
//               ],
//             ),
//           ),
//         ),
//         Text(
//           'Criar treino',
//           style: SafeGoogleFont('Open Sans',
//               fontSize: 25, fontWeight: FontWeight.bold),
//         ),
//         BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
//           builder: (context, buttonState) {
//             return TextButton(
//               onPressed: buttonState is ElevatedButtonBlocLoading
//                   ? null
//                   : () async {
//                       BlocProvider.of<ElevatedButtonBloc>(context)
//                           .add(ElevatedButtonPressed());
//                       final currentState =
//                           context.read<ExercicioSelectionBloc>().state;
//                       final List<ExercicioSelecionado> selectedExerciciosList =
//                           currentState.selectedExercicios;

//                       final List<ExercicioTreino> convertedList =
//                           selectedExerciciosList.map((exercicio) {
//                         List<Serie> seriesForExercicio =
//                             criarTreinoPersonalServices.getSeriesForExercicio(
//                                 exercicio, exercicioSeriesMap);
//                         Intervalo intervaloForExercicio =
//                             criarTreinoPersonalServices.getIntervalForExercicio(
//                                 exercicio, exerciseIntervalMap);

//                         return ExercicioTreino(
//                           id: exercicio.id,
//                           newId: exercicio.newId,
//                           nome: exercicio.nome,
//                           grupoMuscular: exercicio.grupoMuscular,
//                           agonista: exercicio.agonista,
//                           antagonista: exercicio.antagonista,
//                           sinergista: exercicio.sinergista,
//                           mecanismo: exercicio.mecanismo,
//                           fotoUrl: exercicio.fotoUrl,
//                           videoUrl: exercicio.videoUrl,
//                           series: seriesForExercicio,
//                           intervalo: intervaloForExercicio,
//                           notas: exercicioNotesMap[exercicio.newId] ?? "",
//                         );
//                       }).toList();

//                       Treino newTreino =
//                           Treino(titulo: titulo, exercicios: convertedList);

//                       bool sucesso = false;

//                       if (funcao == 'addTreinoPersonal') {
//                         sucesso = await _treinosPersonalServices
//                             .addTreinoCriado(uid, pastaId, newTreino);
//                       } else if(funcao == 'addTreino') {
//                         sucesso = await _treinoServices
//                             .addTreino(uid, alunoUid!, pastaId, newTreino);
//                       }

//                       if (sucesso) {
//                         BlocProvider.of<GetTreinosCriadosBloc>(context).add(
//                           BuscarTreinosCriados(pastaId),
//                         );
//                         MensagemDeSucesso().showSuccessSnackbar(
//                             context, 'Treino criado com sucesso.');
//                         BlocProvider.of<ElevatedButtonBloc>(context)
//                             .add(ElevatedButtonReset());
//                       } else {
//                         BlocProvider.of<ElevatedButtonBloc>(context)
//                             .add(ElevatedButtonReset());
//                       }
//                     },
//               child: buttonState is ElevatedButtonBlocLoading
//                   ? const CircularProgressIndicator()
//                   : const SizedBox(
//                       width: 57,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text('Salvar'),
//                         ],
//                       ),
//                     ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
