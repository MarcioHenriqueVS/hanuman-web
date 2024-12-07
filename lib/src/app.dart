import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'alunos/antropometria/bloc/get_avaliacao/get_avaliacao_bloc.dart';
import 'alunos/antropometria/bloc/get_avaliacao_recente/get_avaliacao_recente_bloc.dart';
import 'alunos/antropometria/bloc/get_avaliacoes_data/get_avaliacoes_data_bloc.dart';
import 'alunos/antropometria/bloc/get_foto_avaliacao/get_foto_avaliacao_bloc.dart';
import 'alunos/antropometria/bloc/get_pastas/get_avaliacoes_bloc.dart';
import 'alunos/bloc/get_alunos/get_alunos_bloc.dart';
import 'alunos/bloc/get_foto_cadastro/bloc/get_foto_cadastro_aluno_bloc.dart';
import 'atualizacoes/atts_bloc/qtd_missoes_pendentes_bloc.dart';
import 'autenticacao/cadastro/bloc/cadastro_bloc.dart';
import 'autenticacao/services/log_services.dart';
import 'autenticacao/services/user_services.dart';
import 'dashboard/dashboard_view.dart';
import 'exercicios/bloc/exercicios_bloc.dart';
import 'exercicios/services/exercicios_services.dart';
import 'login/login_bloc.dart';
import 'perfil_user/edit_foto/foto_bloc.dart';
import 'perfil_user/foto/get_foto_bloc.dart';
import 'perfil_user/get_user_data/get_user_data_bloc.dart';
import 'perfil_user/nome/get_name_bloc.dart';
import 'rotas/rotas.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'treinos/bloc/concluir_serie/concluir_serie_bloc.dart';
import 'treinos/bloc/get_pastas/get_pastas_bloc.dart';
import 'treinos/bloc/get_pastas_personal/get_pastas_bloc.dart';
import 'treinos/bloc/get_treino_finalizado/get_treino_finalizado_bloc.dart';
import 'treinos/bloc/get_treinos/get_treinos_bloc.dart';
import 'treinos/bloc/get_treinos_criados/get_treinos_criados_bloc.dart';
import 'treinos/bloc/get_treinos_finalizados/get_treinos_finalizados_bloc.dart';
import 'treinos/novo_treino/bloc/selecionar/select_bloc.dart';
import 'web/home/screens/components/drawer/bloc/drawer_bloc.dart';
import 'widgets_comuns/button_bloc/elevated_button_bloc.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(
            userServices: UserServices(),
          ),
        ),
        BlocProvider(
          create: (context) => UserFotoBloc(
            userServices: UserServices(),
          ),
        ),
        BlocProvider(
          create: (context) => ExercicioBloc(
            ExerciciosServices(),
          ),
        ),
        BlocProvider(
          create: (context) => ExercicioSelectionBloc(),
        ),
        BlocProvider(
          create: (context) => ConcluirSerieBloc(),
        ),
        BlocProvider(
          create: (context) => DrawerBloc(),
        ),
        BlocProvider(
          create: (context) => GetAlunosBloc(),
        ),
        BlocProvider(
          create: (context) => GetPastasBloc(),
        ),
        BlocProvider(
          create: (context) => GetTreinosBloc(),
        ),
        BlocProvider(
          create: (context) => GetFotoCadastroAlunoBloc(),
        ),
        BlocProvider(
          create: (context) => ElevatedButtonBloc(),
        ),
        BlocProvider(
          create: (context) => AttsHomeBloc(),
        ),
        BlocProvider(
          create: (context) => GetFotoAvaliacaoBloc(),
        ),
        BlocProvider(
          create: (context) => GetAvaliacoesBloc(),
        ),
        BlocProvider(
          create: (context) => GetAvaliacoesDataBloc(),
        ),
        BlocProvider(
          create: (context) => GetAvaliacaoBloc(),
        ),
        BlocProvider(
          create: (context) => GetAvaliacaoMaisRecenteBloc(),
        ),
        BlocProvider(
          create: (context) => GetTreinoFinalizadoBloc(),
        ),
        BlocProvider(
          create: (context) => LoginBloc(LogServices(), UserServices()),
        ),
        BlocProvider(
          create: (context) => RegisterBloc(UserServices()),
        ),
        BlocProvider(
          create: (context) => GetUserDataBloc(),
        ),
        BlocProvider(
          create: (context) => GetPastasPersonalBloc(),
        ),
        BlocProvider(
          create: (context) => GetTreinosCriadosBloc(),
        ),
        BlocProvider(
          create: (context) => GetTreinosFinalizadosBloc(),
        ),
        BlocProvider(
          create: (context) => PickImageBloc(),
        ),
        // Adicionar quantos BLoCs precisar aqui
      ],
      child: ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return GlobalLoaderOverlay(
            duration: Durations.medium4,
            reverseDuration: Durations.medium4,
            overlayColor: Colors.grey[900]!.withOpacity(0.8),
            //useDefaultLoading: false,
            overlayWidgetBuilder: (_) {
              //ignored progress for the moment
              return const Center(
                child: SpinKitCubeGrid(
                  color: Colors.green,
                  size: 50.0,
                ),
              );
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'app',
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
              ],
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return child!;
                    },
                  ),
                );
              },
              theme: ThemeData(
                primaryColor: Colors.green,
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                colorScheme: ColorScheme.light(
                  primary: Colors.green,
                  secondary: Colors.green.shade400,
                  surface: Colors.white,
                  onPrimary: Colors.white,
                ),
                // ...existing code...
              ),
              darkTheme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: const Color(0xFF1A1A1A),
                primaryColor: Colors.green,
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white),
                  bodySmall: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white),
                  titleMedium: TextStyle(color: Colors.white),
                  titleSmall: TextStyle(color: Colors.white),
                  headlineLarge: TextStyle(color: Colors.white),
                  headlineMedium: TextStyle(color: Colors.white),
                  headlineSmall: TextStyle(color: Colors.white),
                  displayLarge: TextStyle(color: Colors.white),
                  displayMedium: TextStyle(color: Colors.white),
                  displaySmall: TextStyle(color: Colors.white),
                  labelLarge: TextStyle(color: Colors.white),
                  labelMedium: TextStyle(color: Colors.white),
                  labelSmall: TextStyle(color: Colors.white),
                ),
                colorScheme: ColorScheme.dark(
                  primary: Colors.green,
                  secondary: Colors.green.shade400,
                  surface: Color(0xFF121212),
                  //surface: const Color(0xFF1A1A1A),
                  onPrimary: Colors.white,
                  onSurface: Colors.white,
                ),
                sliderTheme: SliderThemeData(
                  activeTrackColor: Colors.green.shade400,
                  inactiveTrackColor: Colors.grey.shade800,
                  thumbColor: Colors.green.shade400,
                  overlayColor: Colors.green.shade400.withOpacity(0.3),
                  valueIndicatorColor: Colors.green.shade400,
                ),
                dividerColor: Colors.grey[850],
                // ...existing code...
              ),
              themeMode: settingsController.themeMode,
              routerConfig: Rotas.router,
            ),
          );
        },
      ),
    );
  }
}
