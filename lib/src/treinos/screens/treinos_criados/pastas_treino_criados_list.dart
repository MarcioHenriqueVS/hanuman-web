import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import '../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../../bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../../bloc/get_pastas_personal/get_pastas_event.dart';
import '../../bloc/get_pastas_personal/get_pastas_state.dart';
import '../../pastas/galeria/services/pastas_galeria_services.dart';
import '../../services/treino_services.dart';
import '../../services/treinos_personal_service.dart';

class PastasTreinosCriadosList extends StatefulWidget {
  const PastasTreinosCriadosList({super.key});

  @override
  State<PastasTreinosCriadosList> createState() =>
      _PastasTreinosCriadosListState();
}

class _PastasTreinosCriadosListState extends State<PastasTreinosCriadosList> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final TreinoServices _treinoServices = TreinoServices();
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();
  final PastasGaleriaServices _pastasGaleriaServices =
      PastasGaleriaServices();
  final MensagemDeSucesso _mensagemDeSucesso = MensagemDeSucesso();
  final TratamentoDeErros _tratamentoDeErros = TratamentoDeErros();
  final TextEditingController pastaIdController = TextEditingController();

  @override
  void initState() {
    //BlocProvider.of<GetPastasPersonalBloc>(context).add(BuscarPastasPersonal());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void deletePasta(pastaId) async {
    BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonPressed());
    try {
      await _pastasGaleriaServices.deletePastaPersonal(uid, pastaId);
      if (mounted) {
        _mensagemDeSucesso.showSuccessSnackbar(
            context, 'Treino deletado com sucesso!');
        BlocProvider.of<GetPastasPersonalBloc>(context)
            .add(BuscarPastasPersonal());
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _tratamentoDeErros.showErrorSnackbar(
            context, 'Erro ao deletar treino, tente novamente');
        Navigator.of(context).pop();
      }
    }
    if (mounted) {
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text('Pastas'),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CRIAR PASTA',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          content: SizedBox(
                            height: 70,
                            width: width * 0.9,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextFormField(
                                    controller: pastaIdController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome da pasta',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 2.0),
                                        // borderRadius:
                                        //     BorderRadius.circular(
                                        //         10.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1.0),
                                        // borderRadius:
                                        //     BorderRadius.circular(
                                        //         10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: BlocBuilder<ElevatedButtonBloc,
                                  ElevatedButtonBlocState>(
                                builder: (context, buttonState) {
                                  return ElevatedButton(
                                    onPressed: buttonState
                                            is ElevatedButtonBlocLoading
                                        ? null
                                        : () async {
                                            BlocProvider.of<ElevatedButtonBloc>(
                                                    context)
                                                .add(ElevatedButtonPressed());
                                            try {
                                              await _pastasGaleriaServices
                                                  .addPastaPersonal(
                                                      uid,
                                                      pastaIdController.text
                                                          .trim(),
                                                      'blue');
                                              BlocProvider.of<
                                                          ElevatedButtonBloc>(
                                                      context)
                                                  .add(ElevatedButtonReset());
                                              FocusScope.of(context).unfocus();
                                              BlocProvider.of<
                                                          GetPastasPersonalBloc>(
                                                      context)
                                                  .add(
                                                BuscarPastasPersonal(),
                                              );
                                              pastaIdController.clear();
                                              MensagemDeSucesso()
                                                  .showSuccessSnackbar(context,
                                                      'Pasta criada com sucesso');
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              BlocProvider.of<
                                                          ElevatedButtonBloc>(
                                                      context)
                                                  .add(ElevatedButtonReset());
                                              debugPrint(e.toString());
                                              TratamentoDeErros()
                                                  .showErrorSnackbar(context,
                                                      'Erro, tente novamente!');
                                            }
                                          },
                                    child:
                                        buttonState is ElevatedButtonBlocLoading
                                            ? const CircularProgressIndicator()
                                            : const Text('Criar'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          'Adicionar pasta',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: BlocBuilder<GetPastasPersonalBloc, GetPastasPersonalState>(
              builder: (context, state) {
                if (state is GetPastasPersonalInitial) {
                  return const Center(
                      child: Text('Iniciando busca pelas pastas...'));
                } else if (state is GetPastasPersonalLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetPastasPersonalError) {
                  return const Center(
                      child: Text('Erro ao carregar pastas, atualize a tela.'));
                } else if (state is GetPastasPersonalLoaded) {
                  if (state.pastasIds.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma pasta, crie a primeira'),
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                            width: width * 0.9,
                            height: 0.5,
                            color: Colors.grey),
                        const SizedBox(
                          height: 20,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.pastasIds.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> pasta = state.pastasIds[index];
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) async {
                                      showDialog(
                                        context: context,
                                        builder: (context) => GFFloatingWidget(
                                          verticalPosition:
                                              MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                          child: GFAlert(
                                            backgroundColor: Colors.grey[900],
                                            titleTextStyle: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 18,
                                                decoration:
                                                    TextDecoration.none),
                                            title: 'Atenção!',
                                            content: const Text(
                                              'Deseja excluir esta pasta? Esta ação não poderá ser desfeita.',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            bottomBar: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: GFButton(
                                                    color: Colors.grey,
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    shape: GFButtonShape.pills,
                                                    child: const Text(
                                                      'Voltar',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                                BlocBuilder<ElevatedButtonBloc,
                                                    ElevatedButtonBlocState>(
                                                  builder:
                                                      (context, buttonState) {
                                                    return GFButton(
                                                      onPressed: buttonState
                                                              is ElevatedButtonBlocLoading
                                                          ? null
                                                          : () {
                                                              deletePasta(
                                                                  pasta);
                                                            },
                                                      shape:
                                                          GFButtonShape.pills,
                                                      color: Colors.red,
                                                      icon: buttonState
                                                              is ElevatedButtonBlocLoading
                                                          ? const CircularProgressIndicator()
                                                          : const Icon(
                                                              Icons
                                                                  .keyboard_arrow_right,
                                                              color: GFColors
                                                                  .WHITE),
                                                      position: GFPosition.end,
                                                      text: 'Excluir',
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 16),
                                                    );
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Excluir',
                                  ),
                                ],
                              ),
                              child: Card(
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          pasta['nome'] == ''
                                              ? 'Sem título'
                                              : pasta['nome'],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    await context.push(
                                        '/pastas-personal/:$pasta',
                                        extra: pasta);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                } else {
                  return const Center(
                      child: Text('Erro inesperado, atualize a tela.'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
