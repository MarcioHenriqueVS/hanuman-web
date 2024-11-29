import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: ElevatedButton(
            onPressed: () {
              //Navigator.push(context, '/selecionargrupomuscular');
              context.push('/selecionargrupomuscular');
            },
            child: const Text('Criar Exercício'),
          )),
        ],
      ),
    );
  }
}
