import 'package:flutter/material.dart';
import '../../../autenticacao/services/user_services.dart';
import 'components/app_bar.dart';

class WebHome extends StatelessWidget {
  WebHome({super.key});

  final UserServices userServices = UserServices();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff222629),
      appBar: NewAppBar(),
    );
  }
}
