import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import '../../../autenticacao/tratamento/error_snackbar.dart';
import '../../../autenticacao/tratamento/success_snackbar.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_bloc.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_event.dart';
import '../../../treinos/bloc/get_pastas/get_pastas_state.dart';
import '../../../treinos/models/treino_model.dart';
import '../../../treinos/services/treino_services.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/button_bloc/elevated_button_bloc_state.dart';
import '../../models/aluno_model.dart';

class AlunosCard extends StatefulWidget {
  final AlunoModel aluno;
  final bool choose;
  final Treino? treino;
  final String? pastaId;
  final String? treinoId;
  const AlunosCard(
      {super.key,
      required this.aluno,
      required this.choose,
      this.pastaId,
      this.treino,
      this.treinoId});

  @override
  State<AlunosCard> createState() => _AlunosCardState();
}

class _AlunosCardState extends State<AlunosCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: GFListTile(
        avatar: GFAvatar(
          backgroundColor: Colors.grey,
          backgroundImage:
              (widget.aluno.fotoUrl != null && widget.aluno.fotoUrl!.isNotEmpty)
                  ? NetworkImage(widget.aluno.fotoUrl!) as ImageProvider<Object>
                  : const AssetImage('assets/images/fotoDePerfilNull.jpg')
                      as ImageProvider<Object>,
        ),
        onTap: () => !widget.choose
            ? context.push('/aluno/:${widget.aluno.uid}', extra: widget.aluno)
            : showModalBottomSheet(
                context: context,
                builder: (context) => SelecionarPasta(
                  treinoId: widget.treinoId!,
                  treino: widget.treino!,
                  alunoUid: widget.aluno.uid,
                  sexo: widget.aluno.sexo,
                ),
              ),
        title: Text(
          widget.aluno.nome,
          style: SafeGoogleFont('Open Sans',
              fontSize: 16, fontWeight: FontWeight.w500),
        ),
        //subTitleText: list[index].descricao,
        subTitle: Text(
          widget.aluno.email,
          style: SafeGoogleFont('Open Sans', fontSize: 12, color: Colors.grey),
        ),
        listItemTextColor: Colors.white,
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        padding: const EdgeInsets.all(10),
        shadow: BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 1,
            offset: const Offset(1, 1),
            blurStyle: BlurStyle.normal),

        //icon: Icon(Icons.favorite)
      ),
    );
  }
}

class Aluno {
  final String nome;
  final String descricao;
  final String uid;

  Aluno({required this.nome, required this.descricao, required this.uid});
}

class SelecionarPasta extends StatefulWidget {
  final Treino treino;
  final String treinoId;
  final String alunoUid;
  final String sexo;
  const SelecionarPasta(
      {super.key,
      required this.treino,
      required this.treinoId,
      required this.alunoUid,
      required this.sexo});

  @override
  State<SelecionarPasta> createState() => _SelecionarPastaState();
}

class _SelecionarPastaState extends State<SelecionarPasta> {
  @override
  void initState() {
    BlocProvider.of<GetPastasBloc>(context).add(BuscarPastas(widget.alunoUid));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPastasBloc, GetPastasState>(
      builder: (context, pastasState) {
        if (pastasState is GetPastasInitial) {
          return const Center(
            child: Text('Iniciando busca das pastas'),
          );
        } else if (pastasState is GetPastasLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (pastasState is GetPastasError) {
          return const Center(
            child: Text(
              'Erro ao tentar buscar pastas, recarregue a tela',
              textAlign: TextAlign.center,
            ),
          );
        } else if (pastasState is GetPastasLoaded) {
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Container(
                              width: 50,
                              height: 2,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.folder_copy_outlined,
                              color: Colors.green,
                            ),
                          ),
                        ],
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
                              showDialog(
                                context: context,
                                builder: (context) => EnviarTreino(
                                    pastaId: pastasIds[index]['id'],
                                    treino: widget.treino,
                                    treinoId: widget.treinoId,
                                    alunoUid: widget.alunoUid),
                              );
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
                                    Text(pastasIds[index]['id']),
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

class EnviarTreino extends StatefulWidget {
  final Treino treino;
  final String pastaId;
  final String treinoId;
  final String alunoUid;
  const EnviarTreino(
      {super.key,
      required this.pastaId,
      required this.treino,
      required this.treinoId,
      required this.alunoUid});

  @override
  State<EnviarTreino> createState() => _EnviarTreinoState();
}

class _EnviarTreinoState extends State<EnviarTreino> {
  final TreinoServices _treinoServices = TreinoServices();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void enviarTreino() async {
    try {
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonPressed());
      await _treinoServices.addTreino(
          uid, widget.alunoUid, widget.pastaId, widget.treino);
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      MensagemDeSucesso()
          .showSuccessSnackbar(context, 'Treino enviado com sucesso');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      TratamentoDeErros()
          .showErrorSnackbar(context, 'Erro ao enviar treino, tente novamente');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        BlocProvider.of<ElevatedButtonBloc>(context).add(ElevatedButtonReset());
      },
      child: GFFloatingWidget(
        verticalPosition: MediaQuery.of(context).size.height * 0.3,
        child: GFAlert(
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(
              color: Colors.red, fontSize: 18, decoration: TextDecoration.none),
          title: 'Atenção!',
          content: const Text(
            'Deseja enviar este treino para o aluno?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                decoration: TextDecoration.none),
          ),
          bottomBar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GFButton(
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  shape: GFButtonShape.pills,
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                builder: (context, buttonState) {
                  return GFButton(
                    onPressed: buttonState is ElevatedButtonBlocLoading
                        ? null
                        : () {
                            enviarTreino();
                          },
                    shape: GFButtonShape.pills,
                    color: Colors.green,
                    icon: buttonState is ElevatedButtonBlocLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Icon(Icons.keyboard_arrow_right,
                            color: GFColors.WHITE),
                    position: GFPosition.end,
                    text: 'Enviar',
                    textStyle: const TextStyle(fontSize: 16),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
