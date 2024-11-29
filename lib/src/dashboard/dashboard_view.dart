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
import '../treinos/bloc/get_pastas_personal/get_pastas_bloc.dart';
import '../treinos/bloc/get_pastas_personal/get_pastas_event.dart';
import 'topics/inicio/pages/inicio_page.dart';
import '../treinos/pages/galeria/pastas_list_page.dart';

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
    // const Center(
    //   child: Text('Tela Financeiro'),
    // ),
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
                            Color(0xFF121212),
                            Color(0xFF121212),
                            Color(0xFF1E1E1E),
                            Color(0xFF2A2A2A),
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
                                    Colors.green.shade900,
                                    Colors.green.shade800,
                                    Colors.green.shade700,
                                    Colors.green.shade600,
                                  ],
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[800]!,
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
          label: const Row(
            children: [
              Icon(
                Bootstrap.chat,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Inteligência artificial',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
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
        backgroundColor: Colors.grey[900],
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
                        icon: const Icon(
                          Bootstrap.menu_app,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'VirtueFit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
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
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Início',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 0
                                  ? Colors.green
                                  : Colors.white,
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
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Alunos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 1
                                  ? Colors.green
                                  : Colors.white,
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
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Treinos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedIndex == 2
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: _selectedIndex == 2
                                  ? Colors.green
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 50),
                  // MouseRegion(
                  //   cursor: SystemMouseCursors.click,
                  //   child: GestureDetector(
                  //     onTap: () => setState(() => _selectedIndex = 3),
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         border: Border(
                  //           bottom: BorderSide(
                  //             color: _selectedIndex == 3
                  //                 ? Colors.green
                  //                 : Colors.transparent,
                  //             width: 1,
                  //           ),
                  //         ),
                  //       ),
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(bottom: 5),
                  //         child: Text(
                  //           'Financeiro',
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             fontWeight: _selectedIndex == 3
                  //                 ? FontWeight.bold
                  //                 : FontWeight.w400,
                  //             color: _selectedIndex == 3
                  //                 ? Colors.green
                  //                 : Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
          child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 1400), child: _telas[_selectedIndex],),),
        ),
      ),
    );
  }
}
