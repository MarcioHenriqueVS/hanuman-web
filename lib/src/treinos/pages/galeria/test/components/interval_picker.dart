import 'package:flutter/material.dart';

class IntervalPickerWidget extends StatefulWidget {
  final List<String> intervalos;
  final String nome;
  final Map<String, String?> exerciseIntervalMap;

  const IntervalPickerWidget({
    super.key,
    required this.intervalos,
    required this.nome,
    required this.exerciseIntervalMap,
  });

  @override
  State<IntervalPickerWidget> createState() => _IntervalPickerWidgetState();
}

class _IntervalPickerWidgetState extends State<IntervalPickerWidget> {
  String? selectedInterval;
  String? originalInterval;

  @override
  void initState() {
    super.initState();
    originalInterval = widget.exerciseIntervalMap[widget.nome];
    // Só define selectedInterval se o valor existir na lista de intervalos
    selectedInterval =
        widget.intervalos.contains(originalInterval) ? originalInterval : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Intervalo de Descanso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            icon: const Icon(Icons.arrow_drop_down_circle_outlined),
            isExpanded: true,
            value: selectedInterval,
            hint: const Text('Escolha um intervalo'),
            items: widget.intervalos.map((String intervalo) {
              return DropdownMenuItem<String>(
                value: intervalo,
                child: Text(
                  intervalo,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedInterval = newValue;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // Só atualiza se for selecionado um novo valor válido
                  if (selectedInterval != null &&
                      widget.intervalos.contains(selectedInterval) &&
                      selectedInterval != originalInterval) {
                    widget.exerciseIntervalMap[widget.nome] = selectedInterval;
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
