import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../utils.dart';
import '../../../models/treino_model.dart';
import '../../treino_start.dart';

class TreinoFinalizadoCard extends StatefulWidget {
  final List<TreinoFinalizado> treinos;
  final String nomeAluno;
  final bool buscandoMais;
  const TreinoFinalizadoCard(
      {super.key,
      required this.treinos,
      required this.nomeAluno,
      required this.buscandoMais});

  @override
  State<TreinoFinalizadoCard> createState() => _TreinoFinalizadoCardState();
}

class _TreinoFinalizadoCardState extends State<TreinoFinalizadoCard> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.treinos.length,
          itemBuilder: (context, index) {
            TreinoFinalizado treino = widget.treinos[index];
            return Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/fotoDePerfilNull.jpg'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.nomeAluno),
                            Text(formatarTimestamp(treino.timestamp!)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Wrap(
                      spacing: 11,
                      children: [
                        Text(
                          'Séries: ${treino.series}',
                          style: SafeGoogleFont('Open Sans',
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        Container(
                          color: Colors.grey,
                          height: 20,
                          width: 1,
                        ),
                        Text(
                          'Volume: ${treino.volume}kg',
                          style: SafeGoogleFont('Open Sans',
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        Container(
                          color: Colors.grey,
                          height: 20,
                          width: 1,
                        ),
                        Text(
                          'Duração: ${treino.duracao}',
                          style: SafeGoogleFont('Open Sans',
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    treino.foto != null && treino.foto != ''
                        ? Container(
                            height: treino.nota != null && treino.nota != ''
                                ? 401
                                : 380,
                            width: width * 0.95,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[800]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showImage(CachedNetworkImageProvider(
                                            treino.foto!));
                                      },
                                      child: SizedBox(
                                        height: 308,
                                        width: width * 0.9,
                                        child: Image(
                                          image: CachedNetworkImageProvider(
                                              treino.foto!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                treino.nota != null && treino.nota != ''
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, top: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                treino.nota!,
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                      top: treino.nota != null &&
                                              treino.nota != ''
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
                                            FaIcon(FontAwesomeIcons.heart),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Curtir')
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TreinoFinalizadoDetailsScreen(
                                                treino: treino,
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
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                          treino: treino,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Row(
                                    children: [
                                      Text(
                                        'Ver detalhes do treino',
                                        style: TextStyle(color: Colors.green),
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
                  ],
                ),
              ),
            );
          },
        ),
        widget.buscandoMais
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const SizedBox.shrink(),
      ],
    );
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

  String formatarTimestamp(String timestamp) {
    // Converte a String para DateTime
    DateTime dateTime = DateTime.parse(timestamp);

    // Formatar a data de forma personalizada
    String day = DateFormat.d('pt_BR').format(dateTime);
    String month = DateFormat.MMM('pt_BR').format(dateTime);
    String time = DateFormat.Hm('pt_BR').format(dateTime);

    return "$day de $month às $time h";
  }
}
