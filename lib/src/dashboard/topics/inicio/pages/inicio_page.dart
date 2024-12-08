import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../alunos/bloc/get_alunos/get_alunos_bloc.dart';
import '../../../../alunos/pages/components/table.dart';
import '../../../../autenticacao/services/user_services.dart';
import '../../../../utils.dart';
import 'components/atts.dart';
import 'components/stats_containers.dart';

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
                          'Total de Alunos', null, Icons.people, true),
                      buildStatContainer('Alunos Ativos (7 dias)', null,
                          Icons.check_circle, true),
                      buildStatContainer('Alunos Inativos (7 dias)', null,
                          Icons.warning, true),
                    ],
                  ),
          );
        } else if (state is GetAlunosLoaded) {
          final alunos = state.alunos;
          String totalAlunos = alunos.length.toString();

          DateTime parseLastAtt(String? dateStr) {
            if (dateStr == null) return DateTime(1900);
            try {
              List<String> parts = dateStr.split(' ');
              List<String> dateParts = parts[0].split('/');
              List<String> timeParts = parts[1].split(':');
              return DateTime(
                int.parse(dateParts[2]), // ano
                int.parse(dateParts[1]), // mes
                int.parse(dateParts[0]), // dia
                int.parse(timeParts[0]), // hora
                int.parse(timeParts[1]), // minuto
                int.parse(timeParts[2]), // segundo
              );
            } catch (e) {
              return DateTime(1900);
            }
          }

          String alunosAtivos = alunos
              .where((aluno) =>
                  aluno.lastAtt != null &&
                  DateTime.now()
                          .difference(parseLastAtt(aluno.lastAtt))
                          .inDays <=
                      7)
              .toList()
              .length
              .toString();

          String alunosInativos = alunos
              .where((aluno) =>
                  aluno.lastAtt == null ||
                  DateTime.now()
                          .difference(parseLastAtt(aluno.lastAtt))
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
                          'Total de Alunos', totalAlunos, Icons.people, false),
                      buildStatContainer('Alunos Ativos (7 dias)', alunosAtivos,
                          Icons.check_circle, false),
                      buildStatContainer('Alunos Inativos (7 dias)',
                          alunosInativos, Icons.warning, false),
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
                          'Total de Alunos', '0', Icons.people, false),
                      buildStatContainer('Alunos Ativos (7 dias)', '0',
                          Icons.check_circle, false),
                      buildStatContainer('Alunos Inativos (7 dias)', '0',
                          Icons.warning, false),
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
    bool isVerySmallScreen = maxWidth < 768;

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
                    'Olá, ',
                    style: SafeGoogleFont(
                      'Open Sans',
                      fontSize: 31,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
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
                        color: Colors.green,
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
                    'Seja bem vindo(a) à inovação!',
                    style: SafeGoogleFont('Plus Jakarta Sans',
                        fontSize: 16,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
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
      //height: isSmallScreen ? maxHeight * 1 : maxHeight * 0.95,
      decoration: BoxDecoration(
        //color: Colors.black,
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(5),
        //cor da borda
        border: Border.all(
          color: Colors.grey[800]!,
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
                            'Atualizações',
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
                            'Veja as atividades dos alunos',
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
