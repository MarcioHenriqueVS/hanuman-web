import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import '../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../alunos/pages/alunos_list_page.dart';
import '../atualizacoes/atts_bloc/qtd_missoes_pendentes_bloc.dart';
import '../atualizacoes/atts_bloc/qtd_missoes_pendentes_event.dart';
import '../chat/chat_screen.dart';
import '../perfil_user/get_user_data/get_user_data_bloc.dart';
import '../perfil_user/pages/personal_profile_page.dart';
import '../treinos/bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../treinos/bloc/get_pastas_personal/get_pastas_event.dart';
import 'topics/inicio/pages/inicio_page.dart';
import '../treinos/pages/galeria/pastas_list_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Painel extends StatefulWidget {
  const Painel({super.key});

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isFirstRowVisible = true;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        context.go('/');
      }
    });
    _scrollController.addListener(_onScroll);
    BlocProvider.of<GetPastasPersonalBloc>(context).add(BuscarPastasPersonal());
    BlocProvider.of<GetAlunosBloc>(context).add(BuscarAlunos());
    BlocProvider.of<AttsHomeBloc>(context).add(BuscarAttsHome());
    BlocProvider.of<GetUserDataBloc>(context).add(
      GetUserData(),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && _isFirstRowVisible) {
      setState(() => _isFirstRowVisible = false);
    } else if (_scrollController.offset <= 10 && !_isFirstRowVisible) {
      setState(() => _isFirstRowVisible = true);
    }
  }

  // Widgets para cada tela
  final List<Widget> _telas = [
    const Center(
      child: InicioPage(),
    ),
    const Center(
      child: AlunosListPage(),
    ),
    const Center(
      child: TreinosListPage(),
    ),
    const Center(
      child: PersonalProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: SizedBox(
        height: 40,
        width: 280,
        child: FloatingActionButton.extended(
          onPressed: () {
            // abrir chat lateral
            showGeneralDialog(
              barrierColor: Colors.black.withOpacity(0.75),
              context: context,
              pageBuilder: (context, animation1, animation2) {
                return const SizedBox.shrink();
              },
              barrierDismissible: true, // Fecha o modal ao tocar fora dele.
              barrierLabel: "Barrier", // Descrição semântica.
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin:
                        const Offset(1, 0), // Começa do lado direito da tela.
                    end: Offset.zero, // Termina alinhado à tela.
                  ).animate(animation),
                  child: Align(
                    alignment:
                        Alignment.centerRight, // Alinha o modal à direita.
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.36, // Define a largura do modal.
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.9),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.8),
                          ],
                          stops: [0.0, 0.6, 0.8, 1.0],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.9),
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.7),
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.6),
                                  ],
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'VirtueFit AI',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(
                                        Bootstrap.x,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(child: ChatScreen()),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              transitionDuration:
                  const Duration(milliseconds: 100), // Duração da animação.
            );
          },
          label: Row(
            children: [
              Icon(
                Bootstrap.chat,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.artificialIntelligence,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        //backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        toolbarHeight: _isFirstRowVisible ? 120 : 80,
        title: Column(
          children: [
            if (_isFirstRowVisible)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Bootstrap.menu_app,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'VirtueFit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Bootstrap.facebook,
                          size: 17,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Bootstrap.instagram,
                          size: 17,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Bootstrap.whatsapp,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (_isFirstRowVisible) const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedIndex == 0
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            AppLocalizations.of(context)!.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            AppLocalizations.of(context)!.students,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 2),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedIndex == 2
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            AppLocalizations.of(context)!.workouts,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 2
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 2
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 3),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedIndex == 3
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            AppLocalizations.of(context)!.profile,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 3
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 3
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: screenWidth > 1200
              ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20)
              : const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1400),
              child: _telas[_selectedIndex],
            ),
          ),
        ),
      ),
    );
  }
}
