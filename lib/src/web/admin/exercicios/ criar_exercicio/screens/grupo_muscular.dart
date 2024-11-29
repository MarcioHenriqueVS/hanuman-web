import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelecionarGrupoMuscular extends StatelessWidget {
  SelecionarGrupoMuscular({Key? key}) : super(key: key);

  final List<String> gruposMusculares = [
    'Peito',
    'Costas',
    'Bíceps',
    'Tríceps',
    'Ombros',
    'Abdômen',
    'Quadríceps',
    'Isquiotibiais',
    'Glúteos',
    'Panturrilhas'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Grupo Muscular'),
      ),
      body: ListView.builder(
        itemCount: gruposMusculares.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(gruposMusculares[index]),
              onTap: () {
                // Navigator.push(
                //   context,
                //   '/selecionarmecanismo',
                //   arguments: gruposMusculares[index],
                // );
                context.push(
                  '/selecionarmecanismo',
                  extra: {
                    'grupoMuscular': gruposMusculares[index],
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
