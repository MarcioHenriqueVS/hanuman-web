import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../autenticacao/checagem/checagem.dart';
import '../dashboard/dashboard_view.dart';
import '../login/reset_senha_screen.dart';
import '../stripe/stripe_test.dart';
import '../treinos/editar_treino/new_edit_treino_screen.dart';
import '../treinos/models/treino_model.dart';
import '../treinos/pages/galeria/test/criar_treino_personal_screen.dart';
import '../treinos/screens/treinos_criados/personal_treinos_criados_screen.dart';
import '../treinos/screens/treinos_criados/selecionar_aluno.dart';
import '../treinos/services/treino_services.dart';
import '../treinos/teste/treinos_screen.dart';
import '../web/checagem/checagem.dart';
import '../login/cadastro_page.dart';
import '../login/login_teste.dart';

class Rotas {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        name: '/',
        path: '/',
        builder: (context, state) =>
            kIsWeb ? const WebChecagem() : const Checagem(),
      ),
      GoRoute(
        name: '/login',
        path: '/login',
        //builder: (context, state) => const LoginScreen(),
        builder: (context, state) => const LoginTeste()
      ),
      GoRoute(
        name: '/cadastro',
        path: '/cadastro',
        //builder: (context, state) => const CadastroScreen(),
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        name: '/redefinirsenha',
        path: '/redefinirsenha',
        builder: (context, state) => RedefinirSenha(),
      ),
      // GoRoute(
      //   name: '/teste',
      //   path: '/teste',
      //   builder: (context, state) => kIsWeb ? const NavBar() : TesteMobile(),
      // ),
      GoRoute(
        name: '/painel',
        path: '/painel',
        builder: (context, state) => kIsWeb ? const Painel() : Container(),
        //builder: (context, state) => const StripeTest(),
        //builder: (context, state) => const AddAvaPrototipo(),

        // builder: (context, state) {
        //   final TreinoServices treinoServices = TreinoServices();
        //   Treino treino =
        //       Treino.fromFirestore(treinoServices.treinoData, 'Treino A');
        //   //return TreinoCriadoScreen(treino: treino, pastaId: 'pasta teste');
        //   return NewEditarTreinoScreen(pastaId: 'pasta teste', treino: treino, treinoId: '0bea9041-84f9-4cf2-99d2-37157fab93f6',);
        //   //return NovoTreinoPersonalScreen(pastaId: 'pasta teste',);
        //   //return NovoTreinoPersonalScreen2(pastaId: 'pasta teste', funcao: 'addTreinoCriado');
        // },
      ),

      // GoRoute(
      //   name: '/notteste',
      //   path: '/notteste',
      //   builder: (context, state) => NotTeste(),
      // ),
      // GoRoute(
      //   name: '/navbar',
      //   path: '/navbar',
      //   builder: (context, state) => const NavBar(),
      // ),
      //!
      // GoRoute(
      //   name: '/alunos',
      //   path: '/alunos',
      //   builder: (context, state) => const AlunosListScreen(),
      // ),
      // GoRoute(
      //   name: '/pastas-personal',
      //   path: '/pastas-personal',
      //   builder: (context, state) => const PastasTreinosCriadosList(),
      // ),
      // GoRoute(
      //   name: '/pastas-personal/:pastaId',
      //   path: '/pastas-personal/:pastaId',
      //   builder: (context, state) {
      //     final pastaId = state.extra as String;
      //     return TreinosCriadosList(pastaId: pastaId);
      //   },
      // ),
      GoRoute(
        name: '/novotreino/treinos-personal/:pastaId',
        path: '/novotreino/treinos-personal/:pastaId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final pastaId = extra['pastaId']!;
          final titulosDosTreinos = extra['titulosDosTreinos']!;
          return NovoTreinoPersonalScreen2(pastaId: pastaId, funcao: 'addTreinoCriado', titulosDosTreinosSalvos: titulosDosTreinos);
        },
      ),
      // GoRoute(
      //   path: '/aluno/:uid',
      //   builder: (context, state) {
      //     final aluno = state.extra as AlunoModel;
      //     return AlunoProfileScreen(aluno: aluno);
      //   },
      // ),
      // GoRoute(
      //   name: '/aluno/:uid/editarAluno',
      //   path: '/aluno/:uid/editarAluno',
      //   builder: (context, state) {
      //     final aluno = state.extra as AlunoModel;
      //     return EditarAlunoScreen(aluno: aluno);
      //   },
      // ),
      GoRoute(
        name: '/aluno/:uid/treinos/:pastaId',
        path: '/aluno/:uid/treinos/:pastaId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final alunoUid = extra['alunoUid']!;
          final pastaId = extra['pastaId']!;
          final sexo = extra['sexo']!;
          return TreinosScreen(
              alunoUid: alunoUid, pastaId: pastaId, sexo: sexo);
        },
      ),
      // GoRoute(
      //   name: '/aluno/:uid/treinos/:pastaId/editarTreino/:treinoId',
      //   path: '/aluno/:uid/treinos/:pastaId/editarTreino/:treinoId',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     final alunoUid = extra['uid'];
      //     final pastaId = extra['pastaId']!;
      //     final treino = extra['treino'];
      //     final treinoId = extra['treinoId']!;
      //     return EditarTreinoScreen(
      //       treino: treino,
      //       alunoUid: alunoUid,
      //       pastaId: pastaId,
      //       treinoId: treinoId,
      //     );
      //   },
      // ),
      GoRoute(
        name: '/personal/:uid/treinos/:pastaId/editar-treino/:treinoId',
        path: '/personal/:uid/treinos/:pastaId/editar-treino/:treinoId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          //final alunoUid = extra['uid']!;
          final pastaId = extra['pastaId']!;
          final treino = extra['treino'];
          final treinoId = extra['treinoId']!;
          return NewEditarTreinoScreen(
            treino: treino,
            //alunoUid: alunoUid,
            pastaId: pastaId,
            treinoId: treinoId,
          );
        },
      ),
      GoRoute(
        name: '/personal/:uid/treinos/:pastaId/:treinoId/selecionar-aluno',
        path: '/personal/:uid/treinos/:pastaId/:treinoId/selecionar-aluno',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final pastaId = extra['pastaId']!;
          final treino = extra['treino'];
          final treinoId = extra['treinoId']!;
          return SelecionarAluno(
            treino: treino,
            pastaId: pastaId,
            treinoId: treinoId,
          );
        },
      ),
      //!
      // GoRoute(
      //   name: '/treinos/:uid',
      //   path: '/treinos/:uid',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     final alunoUid = extra['alunoUid']!;
      //     final sexo = extra['sexo']!;
      //     return Treinos(alunoUid: alunoUid, sexo: sexo);
      //   },
      // ),
      GoRoute(
        name: '/novotreino/:uid/:pastaId',
        path: '/novotreino/:uid/:pastaId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final alunoUid = extra['alunoUid']!;
          final pastaId = extra['pastaId']!;
          final sexo = extra['sexo']!;
          final titulosDosTreinos = extra['titulosDosTreinos']!;
          return NovoTreinoPersonalScreen2(
              alunoUid: alunoUid, pastaId: pastaId, sexo: sexo, funcao: 'addTreino', titulosDosTreinosSalvos: titulosDosTreinos);
        },
      ),
      // GoRoute(
      //   name: '/admin',
      //   path: '/admin',
      //   builder: (context, state) => const AdminScreen(),
      // ),
      // GoRoute(
      //   name: '/selecionargrupomuscular',
      //   path: '/selecionargrupomuscular',
      //   builder: (context, state) => SelecionarGrupoMuscular(),
      // ),
      // GoRoute(
      //   name: '/selecionarmecanismo',
      //   path: '/selecionarmecanismo',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     final grupoMuscular = extra['grupoMuscular']!;
      //     return SelecionarMecanismo(grupoMuscular: grupoMuscular);
      //   },
      // ),
      // GoRoute(
      //   name: '/criarexercicio',
      //   path: '/criarexercicio',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     final grupoMuscular = extra['grupoMuscular']!;
      //     final mecanismo = extra['mecanismo']!;
      //     return CriarExercicio(
      //         grupoMuscular: grupoMuscular, mecanismo: mecanismo);
      //   },
      // ),
      // GoRoute(
      //   name: '/perfil',
      //   path: '/perfil',
      //   builder: (context, state) => MultiBlocProvider(
      //     providers: [
      //       BlocProvider<UserBloc>.value(
      //           value: BlocProvider.of<UserBloc>(context)),
      //       BlocProvider<UserFotoBloc>.value(
      //           value: BlocProvider.of<UserFotoBloc>(context)),
      //     ],
      //     child: const PerfilScreen(),
      //   ),
      // ),
      //!
      // GoRoute(
      //   name: '/editarperfil',
      //   path: '/editarperfil',
      //   builder: (context, state) => MultiBlocProvider(
      //     providers: [
      //       BlocProvider<UserBloc>.value(
      //           value: BlocProvider.of<UserBloc>(context)),
      //       BlocProvider<UserFotoBloc>.value(
      //           value: BlocProvider.of<UserFotoBloc>(context)),
      //     ],
      //     child: const EditarPerfilScreen(),
      //   ),
      // ),
      // GoRoute(
      //   name: '/treinosfinalizados/:uid',
      //   path: '/treinosfinalizados/:uid',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     final alunoUid = extra['alunoUid']!;
      //     final nomeAluno = extra['nomeAluno']!;
      //     final fotoUrl = extra['fotoUrl']!;
      //     return TreinosFinalizadosScreen(
      //       alunoUid: alunoUid,
      //       nomeAluno: nomeAluno,
      //       fotoUrl: fotoUrl,
      //     );
      //   },
      // ),
    ],
  );
}
