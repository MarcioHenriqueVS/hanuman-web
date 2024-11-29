import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import '../../utils.dart';
import '../bloc/get_treino_finalizado/get_treino_finalizado_bloc.dart';
import '../bloc/get_treino_finalizado/get_treino_finalizado_event.dart';
import '../bloc/get_treino_finalizado/get_treino_finalizado_state.dart';
import '../models/exercicio_treino_model.dart';
import '../models/treino_model.dart';
import 'treino_start.dart';

class TreinoFinalizadoScreen extends StatefulWidget {
  final TreinoFinalizado? treino;
  final String? treinoId;
  final String alunoUid;

  const TreinoFinalizadoScreen({
    super.key,
    this.treino,
    this.treinoId,
    required this.alunoUid,
  });

  @override
  State<TreinoFinalizadoScreen> createState() => _TreinoFinalizadoScreenState();
}

class _TreinoFinalizadoScreenState extends State<TreinoFinalizadoScreen> {
  TreinoFinalizado? newTreino;
  CachedNetworkImageProvider? cachedNetworkImage;

  @override
  void initState() {
    verificarTreino();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void verificarTreino() async {
    if (widget.treino == null) {
      BlocProvider.of<GetTreinoFinalizadoBloc>(context).add(
        BuscarTreinoFinalizado(widget.alunoUid, widget.treinoId!),
      );
    } else {
      setState(() {
        newTreino = widget.treino;
        newTreino!.foto != null
            ? cachedNetworkImage = CachedNetworkImageProvider(
                newTreino!.foto!,
              )
            : null;
      });
    }
  }

  void verificarFoto() {}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                //Text(treino.titulo == '' ? 'Sem título' : treino.titulo),
                // IconButton(
                //   onPressed: () async {
                //     final result = await Navigator.push(context,
                //         '/aluno/:uid/treinos/:pastaId/editarTreino/:treinoId',
                //         arguments: {
                //           'treino': widget.treino,
                //           'personalUid': widget.personalUid,
                //           'pastaId': widget.pastaId,
                //           'treinoId': widget.treino.id
                //         }) as Map<String, dynamic>?;

                //     if (result != null) {
                //       setState(() {
                //         widget.treino.titulo = result['titulo'];
                //         widget.treino.exercicios = result['exercicios'];
                //       });
                //     }
                //   },
                //   icon: const Text(
                //     'Editar treino',
                //     style: TextStyle(color: Colors.green),
                //   ),
                // ),
                const SizedBox.shrink(),
              ],
            ),
          ),
          body: BlocConsumer<GetTreinoFinalizadoBloc, GetTreinoFinalizadoState>(
            listener: (context, treinoState) {
              if (treinoState is GetTreinoFinalizadoLoaded) {
                setState(
                  () {
                    newTreino = treinoState.treino;
                    newTreino!.foto != null
                        ? cachedNetworkImage = CachedNetworkImageProvider(
                            newTreino!.foto!,
                          )
                        : null;
                  },
                );
              }
            },
            builder: (context, state) {
              return newTreino == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      newTreino!.titulo == ''
                                          ? 'Sem título'
                                          : newTreino!.titulo,
                                      style: SafeGoogleFont('Open Sans',
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: width * 0.9,
                                  height: 0.5,
                                  color: Colors.grey),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                height: 105,
                                width: width * 0.9,
                                decoration: BoxDecoration(
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color.fromARGB(255, 33, 49, 33),
                                      Color.fromARGB(255, 36, 50, 36),
                                      Color.fromARGB(255, 39, 58, 40),
                                      Color.fromARGB(255, 36, 51, 36),
                                      Color.fromARGB(255, 35, 48, 35),
                                      Color.fromARGB(255, 33, 43, 33),
                                      Color.fromARGB(255, 30, 34, 30),
                                      Color.fromARGB(255, 28, 33, 28),
                                      Color.fromARGB(255, 27, 29, 27),
                                      //Color.fromARGB(255, 59, 171, 62),
                                      //Color.fromARGB(255, 53, 171, 57),
                                      // Color.fromARGB(255, 51, 170, 55),
                                    ],
                                    radius: 0.85,
                                    center: Alignment.topRight,
                                  ),
                                  //color: Color.fromARGB(255, 59, 171, 62),
                                  //border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DURAÇÃO',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            newTreino!.duracao!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // const Text(
                                          //   ' %',
                                          //   style: TextStyle(
                                          //       fontSize: 21,
                                          //       fontWeight: FontWeight.bold),
                                          // )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                            spacing: width * 0.025,
                            children: [
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              Container(
                                height: 105,
                                width: width * 0.425,
                                decoration: BoxDecoration(
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color.fromARGB(255, 33, 49, 33),
                                      Color.fromARGB(255, 36, 50, 36),
                                      Color.fromARGB(255, 39, 58, 40),
                                      Color.fromARGB(255, 36, 51, 36),
                                      Color.fromARGB(255, 35, 48, 35),
                                      Color.fromARGB(255, 33, 43, 33),
                                      Color.fromARGB(255, 30, 34, 30),
                                      Color.fromARGB(255, 28, 33, 28),
                                      Color.fromARGB(255, 27, 29, 27),
                                      //Color.fromARGB(255, 59, 171, 62),
                                      //Color.fromARGB(255, 53, 171, 57),
                                      // Color.fromARGB(255, 51, 170, 55),
                                    ],
                                    radius: 0.85,
                                    center: Alignment.topRight,
                                  ),
                                  //color: Color.fromARGB(255, 59, 171, 62),
                                  //border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'VOLUME',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            newTreino!.volume!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Text(
                                            'kg',
                                            style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // ],
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              Container(
                                height: 105,
                                width: width * 0.425,
                                decoration: BoxDecoration(
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color.fromARGB(255, 33, 49, 33),
                                      Color.fromARGB(255, 36, 50, 36),
                                      Color.fromARGB(255, 39, 58, 40),
                                      Color.fromARGB(255, 36, 51, 36),
                                      Color.fromARGB(255, 35, 48, 35),
                                      Color.fromARGB(255, 33, 43, 33),
                                      Color.fromARGB(255, 30, 34, 30),
                                      Color.fromARGB(255, 28, 33, 28),
                                      Color.fromARGB(255, 27, 29, 27),
                                      //Color.fromARGB(255, 59, 171, 62),
                                      //Color.fromARGB(255, 53, 171, 57),
                                      // Color.fromARGB(255, 51, 170, 55),
                                    ],
                                    radius: 0.85,
                                    center: Alignment.topRight,
                                  ),
                                  //color: Color.fromARGB(255, 59, 171, 62),
                                  //border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SÉRIES',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            newTreino!.series!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // const Text(
                                          //   'kg',
                                          //   style: TextStyle(
                                          //       fontSize: 21,
                                          //       fontWeight: FontWeight.bold),
                                          // )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ],
                          // ),
                          const SizedBox(height: 20),
                          newTreino!.foto != null && newTreino!.foto != ''
                              ? Container(
                                  height: newTreino!.nota != null &&
                                          newTreino!.nota != ''
                                      ? 401
                                      : 380,
                                  width: width * 0.95,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[800]!),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _showImage(cachedNetworkImage!);
                                            },
                                            child: SizedBox(
                                              height: 308,
                                              width: width * 0.9,
                                              child: Image(
                                                image: cachedNetworkImage!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      newTreino!.nota != null &&
                                              newTreino!.nota != ''
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 20, top: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      newTreino!.nota!,
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: newTreino!.nota != null &&
                                                    newTreino!.nota != ''
                                                ? 0
                                                : 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Row(
                                                children: [
                                                  FaIcon(
                                                      FontAwesomeIcons.heart),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text('Curtir')
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TreinoFinalizadoDetailsScreen(
                                                          treino: newTreino!,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Row(
                                                    children: [
                                                      Text(
                                                        'Ver detalhes do treino',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_outlined,
                                                        size: 16,
                                                        color: Colors.green,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TreinoFinalizadoDetailsScreen(
                                                treino: newTreino!,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Row(
                                          children: [
                                            Text(
                                              'Ver detalhes do treino',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_outlined,
                                              size: 16,
                                              color: Colors.green,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  String intervaloTipoParaString(IntervaloTipo tipo) {
    switch (tipo) {
      case IntervaloTipo.segundos:
        return 'segundos';
      case IntervaloTipo.minutos:
        return 'minutos';
      default:
        return '';
    }
  }

  void _showImage(CachedNetworkImageProvider cachedNetworkImageProvider) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.9,
            child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 2,
              imageProvider: cachedNetworkImageProvider,
            ),
          ),
        );
      },
    );
  }
}
