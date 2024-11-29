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
import '../../bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
import '../../models/treino_model.dart';
import '../../services/treino_services.dart';
import '../../services/treinos_personal_service.dart';
import 'personal_treinos_criados_screen.dart';

class TreinosCriadosList extends StatefulWidget {
  final String pastaId;
  const TreinosCriadosList({super.key, required this.pastaId});

  @override
  State<TreinosCriadosList> createState() => _TreinosCriadosListState();
}

class _TreinosCriadosListState extends State<TreinosCriadosList> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final TreinoServices _treinoServices = TreinoServices();
  final TreinosPersonalServices _treinosPersonalServices =
      TreinosPersonalServices();
  final MensagemDeSucesso _mensagemDeSucesso = MensagemDeSucesso();
  final TratamentoDeErros _tratamentoDeErros = TratamentoDeErros();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<GetTreinosCriadosBloc>(context)
        .add(BuscarTreinosCriados(widget.pastaId));
  }

  void deleteTreino(treinoId) async {
    BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonPressed());
    try {
      await _treinosPersonalServices.deleteTreinoCriado(uid, widget.pastaId, treinoId);
      _mensagemDeSucesso.showSuccessSnackbar(
          context, 'Treino deletado com sucesso!');
      BlocProvider.of<GetTreinosCriadosBloc>(context)
          .add(BuscarTreinosCriados(widget.pastaId));
      Navigator.of(context).pop();
    } catch (e) {
      _tratamentoDeErros.showErrorSnackbar(
          context, 'Erro ao deletar treino, tente novamente');
      Navigator.of(context).pop();
    }
    BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
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
                      const Text('Treinos'),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      context.push(
                        '/novotreino/treinos-personal/:${widget.pastaId}',
                        extra: widget.pastaId,
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
                          'Adicionar treino',
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
            body: BlocBuilder<GetTreinosCriadosBloc, GetTreinosCriadosState>(
              builder: (context, state) {
                if (state is GetTreinosCriadosInitial) {
                  return const Center(
                      child: Text('Iniciando busca por treinos...'));
                } else if (state is GetTreinosCriadosLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetTreinosCriadosError) {
                  return const Center(
                      child:
                          Text('Erro ao carregar treinos, atualize a tela.'));
                } else if (state is GetTreinosCriadosLoaded) {
                  if (state.treinos.isEmpty) {
                    return const Center(
                      child: Text('Nenhum treino, crie o primeiro'),
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
                          itemCount: state.treinos.length,
                          itemBuilder: (context, index) {
                            Treino treino = state.treinos[index];
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
                                              'Deseja excluir este treino? Esta ação não poderá ser desfeita.',
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
                                                              deleteTreino(state
                                                                  .treinos[
                                                                      index]
                                                                  .id);
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            treino.titulo == ''
                                                ? 'Sem título'
                                                : treino.titulo,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TreinoCriadoScreen(
                                          treino: treino,
                                          pastaId: widget.pastaId,
                                        ),
                                      ),
                                    );
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
