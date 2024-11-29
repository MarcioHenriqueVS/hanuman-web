import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_bloc.dart';
import 'event_bloc.dart';
import 'state_bloc.dart';

class WebChecagem extends StatelessWidget {
  const WebChecagem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WebAuthenticationBloc()..add(CheckWebAuthentication()),
      child: Scaffold(
        body: Center(
          child: BlocConsumer<WebAuthenticationBloc, WebAuthenticationState>(
            listener: (context, state) async {
              debugPrint(' ----------> WebChecagem <--------');
              String routeName;
              switch (state.status) {
                case WebUserStatus.desktopLogado:
                  routeName = '/painel';
                  break;
                case WebUserStatus.mobileLogado:
                  routeName = '/painel';
                  break;
                case WebUserStatus.desktopNaoLogado:
                  routeName = '/login';
                  break;
                case WebUserStatus.mobileNaoLogado:
                  routeName = '/login';
                  break;
                // Arrumar esta parte conforme as telas forem criadas
              }
              // await Navigator.of(context).pushAndRemoveUntil(
              //     routeName, (Route<dynamic> route) => false);
              context.go(routeName);
            },
            builder: (context, state) {
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
