import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../utils.dart';
import '../../../../models/serie_model.dart';
import 'build_series_button.dart';

class BuildSeriesInput extends StatefulWidget {
  final List<Serie> seriesList;
  final Map<String, List<Serie>> exercicioSeriesMap;
  final String newId;
  const BuildSeriesInput(
      {super.key,
      required this.seriesList,
      required this.exercicioSeriesMap,
      required this.newId});

  @override
  State<BuildSeriesInput> createState() => _BuildSeriesInputState();
}

final Map<String, IconData> seriesIcons = {
  'Série de aquecimento': Icons.local_fire_department,
  'Série normal': Icons.fitness_center,
  'Série de falha': Icons.sports_gymnastics,
  'Série de drop': Icons.trending_down,
};

class _BuildSeriesInputState extends State<BuildSeriesInput> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 850),
      child: Column(
        children: widget.seriesList.asMap().entries.map(
          (entry) {
            int index = entry.key;
            Serie serie = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'SÉRIE',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            //width: 80,
                            height: 40,
                            child: InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    "${index + 1}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'PESO(kg)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(
                              () {
                                serie.kg = int.tryParse(value) ?? 0;
                              },
                            );
                          },
                          controller: serie.pesoController,
                          decoration: InputDecoration(
                            labelStyle: SafeGoogleFont(
                              'Open Sans',
                              textStyle: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'REPS',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              serie.reps = int.tryParse(value) ?? 0;
                            });
                          },
                          controller: serie.repsController, // Preserva o valor
                          decoration: InputDecoration(
                            labelStyle: SafeGoogleFont(
                              'Open Sans',
                              textStyle: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'TIPO',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: BuildSeriesButton(
                              serie: serie,
                              seriesIcons: seriesIcons,
                              index: index,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 60,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            ' ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          index != 0
                              ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(
                                        () {
                                          // Remove a série na posição do índice
                                          widget
                                              .exercicioSeriesMap[widget.newId]
                                              ?.removeAt(index);

                                          // Atualiza a lista depois da remoção
                                          widget.exercicioSeriesMap[
                                              widget.newId] = List.from(
                                            widget.exercicioSeriesMap[
                                                    widget.newId] ??
                                                [],
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 17,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 16.5,
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
