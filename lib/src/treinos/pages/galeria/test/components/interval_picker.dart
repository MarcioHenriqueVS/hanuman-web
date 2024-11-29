import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntervalPickerWidget extends StatefulWidget {
  final List<String> intervalos;
  final String nome;
  final Map<String, String?> exerciseIntervalMap;
  const IntervalPickerWidget(
      {super.key, required this.intervalos, required this.nome, required this.exerciseIntervalMap});

  @override
  State<IntervalPickerWidget> createState() => _IntervalPickerWidgetState();
}

class _IntervalPickerWidgetState extends State<IntervalPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Confirmar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Expanded(
            child: CupertinoPicker(
              diameterRatio: 1.5,
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                setState(() {
                  widget.exerciseIntervalMap[widget.nome] = widget.intervalos[index];
                });
              },
              children: widget.intervalos
                  .map<Widget>((intervalo) => Center(child: Text(intervalo)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
