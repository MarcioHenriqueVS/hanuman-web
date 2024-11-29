import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelecionarMecanismo extends StatelessWidget {
  final String grupoMuscular;
  SelecionarMecanismo({super.key, required this.grupoMuscular});

  final List<String> mecanismo = [
    'Barra',
    'Haltere',
    'Máquina',
    'Livre',
    'Faixa de Resistência',
    'Faixa de Suspensão',
    'Anilha',
    'Kettlebell',
    'Bola Suíça',
    'Rolo de Espuma'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione o mecanismo'),
      ),
      body: ListView.builder(
        itemCount: mecanismo.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(mecanismo[index]),
              onTap: () {
                // Navigator.push(
                //   context,
                //   '/criarexercicio',
                //   arguments: {
                //     'grupoMuscular': grupoMuscular,
                //     'mecanismo': mecanismo[index]
                //   },
                // );
                context.push(
                  '/criarexercicio',
                  extra: {
                    'grupoMuscular': grupoMuscular,
                    'mecanismo': mecanismo[index]
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
