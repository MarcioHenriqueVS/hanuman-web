import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../autenticacao/services/log_services.dart';
import '../../../../../autenticacao/services/user_services.dart';

class BuildDrawerWeb extends StatelessWidget {
  final bool isAdmin;
  BuildDrawerWeb({super.key, required this.isAdmin});

  final UserServices userServices = UserServices();
  final LogServices logServices = LogServices();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const DrawerHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Teste'),
                ],
              ),
            ),
            Card(
              child: InkWell(
                onTap: () {},
                child: const ListTile(
                  title: Text('Teste'),
                ),
              ),
            ),
            isAdmin
                ? Card(
                    child: InkWell(
                      onTap: () {
                        //Navigator.push(context, '/admin');
                        context.push('/admin');
                      },
                      child: const ListTile(
                        title: Text('Painel do administrador'),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ElevatedButton(
            onPressed: () async {
              await logServices.logOut(context);
              if (context.mounted) {
                // await Navigator.of(context).pushAndRemoveUntil(
                //     '/', (Route<dynamic> route) => false);
                context.go('/');
              }
            },
            child: const Text('Sair'),
          ),
        ),
      ],
    );
  }
}
