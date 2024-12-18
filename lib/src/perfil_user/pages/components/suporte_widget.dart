import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../autenticacao/services/log_services.dart';
import '../../../utils.dart';
import '../../../widgets_comuns/flutter_flow/ff_button_options.dart';

class SuporteWidget extends StatefulWidget {
  const SuporteWidget({super.key});

  @override
  State<SuporteWidget> createState() => _SuporteWidgetState();
}

class _SuporteWidgetState extends State<SuporteWidget> {
  final LogServices _logServices = LogServices();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 32, 32, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 325),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.55,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Ajuda e Suporte',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                          ),
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Procurando informações sobre nós?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                              ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 8, 0, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              // TODO: Implement
                                            },
                                            child: Text(
                                              'Saiba mais',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Dicas de como usar a plataforma?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                              ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 8, 0, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              // TODO: Implement
                                            },
                                            child: Text(
                                              'Saiba mais',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Precisa de algo mais?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                          ),
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 0, 8, 0),
                                              child: Icon(
                                                Icons.support_agent_rounded,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                size: 24,
                                              ),
                                            ),
                                            Expanded(
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // TODO: Implement
                                                  },
                                                  child: Text(
                                                    'Falar com suporte',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 14),
                                                    softWrap: true,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 16, 0, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 0, 8, 0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .solidCircleQuestion,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 24,
                                                ),
                                              ),
                                              Expanded(
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // TODO: Implement
                                                    },
                                                    child: Text(
                                                      'Perguntas frequentes',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: 14),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.clip,
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
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 16, 0, 16),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      final confirmarSaida =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmar Saída'),
                                            content: Text(
                                                'Tem certeza que deseja sair?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .color),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Text('Sair',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error)),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmarSaida == true &&
                                          context.mounted) {
                                        await _logServices.logOut(context);
                                        if (context.mounted) {
                                          context.go('/');
                                        }
                                      }
                                    },
                                    text: 'Sair',
                                    icon: Icon(
                                      Icons.logout,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      size: 15,
                                    ),
                                    options: FFButtonOptions(
                                      height: 34,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              24, 0, 24, 0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      textStyle: SafeGoogleFont(
                                        'Open Sans',
                                        fontSize: 14,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      elevation: 0,
                                      borderSide: BorderSide(
                                        color: Colors.red[700]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      hoverColor:
                                          Theme.of(context).dividerColor,
                                      hoverBorderSide: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 2,
                                      ),
                                      hoverTextColor: const Color(0xFF15161E),
                                      hoverElevation: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
