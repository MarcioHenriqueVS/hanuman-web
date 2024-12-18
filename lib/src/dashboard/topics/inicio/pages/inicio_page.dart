import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../../../../alunos/pages/components/table.dart';
import '../../../../autenticacao/services/user_services.dart';
import '../../../../utils.dart';
import 'components/atts.dart';
import 'components/stats_containers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final UserServices userServices = UserServices();
  String firstName = '';

  @override
  void initState() {
    super.initState();
    getFirstName();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getFirstName() async {
    final name = userServices.getFirstName();
    setState(() {
      firstName = name;
    });
  }

  Widget _buildStatisticsContainers(
      double maxWidth, double maxHeight, bool isSmallScreen) {
    final shouldStack = maxWidth < 700;
    final containerWidth = shouldStack ? maxWidth * 0.9 : (maxWidth * 0.92) / 3;
    final containerHeight = maxHeight * 0.185;

    Widget buildStatContainer(
        String title, String? value, IconData icon, bool loading) {
      return StatsContainers(
        title: title,
        value: value,
        containerWidth: containerWidth,
        containerHeight: containerHeight,
        maxWidth: maxWidth,
        loading: loading,
      );
    }

    return BlocBuilder<GetAlunosBloc, GetAlunosState>(
      builder: (context, state) {
        if (state is GetAlunosLoading || state is GetAlunosInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: shouldStack ? maxWidth * 0.05 : maxWidth * 0.01,
            ),
            child: shouldStack
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildStatContainer(
                          AppLocalizations.of(context)!.totalStudents,
                          null,
                          Icons.people,
                          true),
                      buildStatContainer(
                          AppLocalizations.of(context)!.activeStudents,
                          null,
                          Icons.check_circle,
                          true),
                      buildStatContainer(
                          AppLocalizations.of(context)!.inactiveStudents,
                          null,
                          Icons.warning,
                          true),
                    ],
                  ),
          );
        } else if (state is GetAlunosLoaded) {
          final alunos = state.alunos;
          String totalAlunos = alunos.length.toString();

          String alunosAtivos = alunos
              .where((aluno) =>
                  aluno.lastActivity != null &&
                  DateTime.now()
                          .difference(aluno.lastActivity!.toDate())
                          .inDays <=
                      7)
              .toList()
              .length
              .toString();

          String alunosInativos = alunos
              .where((aluno) =>
                  aluno.lastActivity == null ||
                  DateTime.now()
                          .difference(aluno.lastActivity!.toDate())
                          .inDays >
                      7)
              .toList()
              .length
              .toString();

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: shouldStack ? maxWidth * 0.05 : maxWidth * 0.01,
            ),
            child: shouldStack
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildStatContainer(
                          AppLocalizations.of(context)!.totalStudents,
                          totalAlunos,
                          Icons.people,
                          false),
                      buildStatContainer(
                          AppLocalizations.of(context)!.activeStudents,
                          alunosAtivos,
                          Icons.check_circle,
                          false),
                      buildStatContainer(
                          AppLocalizations.of(context)!.inactiveStudents,
                          alunosInativos,
                          Icons.warning,
                          false),
                    ],
                  ),
          );
        } else if (state is GetAlunosDataIsEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: shouldStack ? maxWidth * 0.05 : maxWidth * 0.01,
            ),
            child: shouldStack
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildStatContainer(
                          AppLocalizations.of(context)!.totalStudents,
                          '0',
                          Icons.people,
                          false),
                      buildStatContainer(
                          AppLocalizations.of(context)!.activeStudents,
                          '0',
                          Icons.check_circle,
                          false),
                      buildStatContainer(
                          AppLocalizations.of(context)!.inactiveStudents,
                          '0',
                          Icons.warning,
                          false),
                    ],
                  ),
          );
        } else {
          return const Center(child: Text('Erro ao buscar dados'));
        }
      },
    );
  }

  Widget _buildResponsiveLayout(
      BuildContext context, double maxWidth, double maxHeight) {
    bool isSmallScreen = maxWidth < 1000;
    return Column(
      crossAxisAlignment:
          isSmallScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? maxWidth * 0.025 : maxWidth * 0.025,
          ),
          child: Column(
            crossAxisAlignment: isSmallScreen
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hello,
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 31,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                    child: Text(
                      firstName,
                      style: SafeGoogleFont(
                        'Open Sans',
                        fontSize: 31,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: SafeGoogleFont('Plus Jakarta Sans',
                        fontSize: 16,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: maxHeight * 0.03),
        _buildStatisticsContainers(maxWidth, maxHeight, isSmallScreen),
        SizedBox(height: maxHeight * 0.03),
        isSmallScreen
            ? Center(
                child: Column(
                  children: [
                    _buildContainer(maxWidth, maxHeight, isSmallScreen, true),
                    SizedBox(height: maxHeight * 0.02),
                    _buildContainer(maxWidth, maxHeight, isSmallScreen, false),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Adicionar esta linha
                children: [
                  _buildContainer(maxWidth, maxHeight, isSmallScreen, true),
                  SizedBox(width: maxWidth * 0.02),
                  _buildContainer(maxWidth, maxHeight, isSmallScreen, false),
                ],
              ),
      ],
    );
  }

  Widget _buildContainer(
      double maxWidth, double maxHeight, bool isSmallScreen, bool isFirst) {
    final containerWidth = isSmallScreen
        ? maxWidth * 0.96
        : (isFirst
            ? (maxWidth < 1410 ? maxWidth * 0.55 : maxWidth * 0.59)
            : (maxWidth < 1410 ? maxWidth * 0.39 : maxWidth * 0.35));

    return Container(
      width: containerWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? maxWidth * 0.03 : maxWidth * 0.01,
          vertical: isFirst ? 0 : maxHeight * 0.03,
        ),
        child: isFirst
            ? Column(
                children: [
                  SizedBox(height: maxHeight * 0.02),
                  _buildAlunosList(maxWidth, maxHeight),
                  SizedBox(height: 30),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                          child: Text(
                            AppLocalizations.of(context)!.updates,
                            style: SafeGoogleFont(
                              'Open Sans',
                              textStyle: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 4, 12, 0),
                          child: Text(
                            AppLocalizations.of(context)!.seeStudentActivities,
                            style: SafeGoogleFont(
                              'Open Sans',
                              textStyle: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: maxHeight * 0.02),
                  DashboardAtts(
                    isSamallScreen: isSmallScreen,
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildAlunosList(double maxWidth, double maxHeight) {
    return
        //AlunosRecentesList();
        AlunosTable();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = MediaQuery.of(context).size.height * 0.8;
          return _buildResponsiveLayout(context, maxWidth, maxHeight);
        },
      ),
    );
  }
}
