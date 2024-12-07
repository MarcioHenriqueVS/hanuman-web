import 'package:flutter/material.dart';
import '../../../widgets_comuns/flutter_flow/ff_button_options.dart';

class ConfigsWidget extends StatefulWidget {
  const ConfigsWidget({super.key});

  @override
  State<ConfigsWidget> createState() => _ConfigsWidgetState();
}

class _ConfigsWidgetState extends State<ConfigsWidget> {
  String _selectedThemeMode = 'Dark mode'; // Novo controller para o tema

  TextEditingController nome = TextEditingController();
  TextEditingController sobrenome = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController endereco = TextEditingController();

  //focus nodes
  FocusNode nomeFocus = FocusNode();
  FocusNode sobrenomeFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode enderecoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nome.dispose();
    sobrenome.dispose();
    email.dispose();
    endereco.dispose();
    nomeFocus.dispose();
    sobrenomeFocus.dispose();
    emailFocus.dispose();
    enderecoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.55,
            decoration: BoxDecoration(
              //color: Theme.of(context).scaffoldBackgroundColor,
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Configurações Gerais', // Alterado
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 24,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Atualize seu perfil e como as pessoas podem entrar em contato com você', // Alterado
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 14,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Divider(
                                thickness: 0.5,
                                color: Theme.of(context).dividerColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Detalhes do perfil', // Alterado
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        'Editar', // Alterado
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nome', // Alterado
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 8, 0, 0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: TextFormField(
                                        controller: nome,
                                        focusNode: nomeFocus,
                                        autofocus: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                              ),
                                          hintText: 'Amos',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                        validator: (value) {
                                          if (value != null && value.isEmpty) {
                                            return 'Campo obrigatório';
                                          }
                                          return null;
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sobrenome', // Alterado
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 8, 0, 0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: TextFormField(
                                        controller: sobrenome,
                                        focusNode: sobrenomeFocus,
                                        autofocus: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                              ),
                                          hintText: 'Ndeto',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                letterSpacing: 0.0,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                        validator: (value) {
                                          if (value != null && value.isEmpty) {
                                            return 'Campo obrigatório';
                                          }
                                          return null;
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endereço de email', // Alterado
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: TextFormField(
                                      controller: email,
                                      focusNode: emailFocus,
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                        hintText: 'anzacloud@gmail.com',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            letterSpacing: 0.0,
                                          ),
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Campo obrigatório';
                                        }
                                        return null;
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endereço', // Alterado
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: TextFormField(
                                      controller: endereco,
                                      focusNode: enderecoFocus,
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                        hintText: '1 Hackerway, SF',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            letterSpacing: 0.0,
                                          ),
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Campo obrigatório';
                                        }
                                        return null;
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 32, 0, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Divider(
                                thickness: 0.5,
                                color: Theme.of(context).dividerColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Idiomas', // Alterado
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_United_Kingdom_%281-2%29.svg/1200px-Flag_of_the_United_Kingdom_%281-2%29.svg.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              'Inglês', // Alterado
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        FFButtonWidget(
                          onPressed: () {
                            print('Button pressed ...');
                          },
                          text: 'Alterar', // Alterado
                          options: FFButtonOptions(
                            height: 40,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            iconPadding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color:
                                //Theme.of(context).scaffoldBackgroundColor,
                                Colors.grey[900],
                            textStyle:
                                // Theme.of(context)
                                //     .textTheme
                                //     .titleSmall
                                //     ?.copyWith(
                                //       color:
                                //           Theme.of(context).textTheme.titleSmall?.color,
                                //       letterSpacing: 0.0,
                                //     ),
                                TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.0,
                            ),
                            elevation: 0,
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Divider(
                                thickness: 0.5,
                                color: Theme.of(context).dividerColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Aparência do aplicativo', // Alterado
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Modo claro',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      letterSpacing: 0.0,
                                    )),
                            value: 'Light mode',
                            groupValue: _selectedThemeMode,
                            onChanged: (value) {
                              setState(() {
                                _selectedThemeMode = value!;
                              });
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Modo escuro',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      letterSpacing: 0.0,
                                    )),
                            value: 'Dark mode',
                            groupValue: _selectedThemeMode,
                            onChanged: (value) {
                              setState(() {
                                _selectedThemeMode = value!;
                              });
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Preferência do sistema',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      letterSpacing: 0.0,
                                    )),
                            value: 'System preference',
                            groupValue: _selectedThemeMode,
                            onChanged: (value) {
                              setState(() {
                                _selectedThemeMode = value!;
                              });
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Divider(
                                thickness: 0.5,
                                color: Theme.of(context).dividerColor,
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
          ),
        ),
      ],
    );
  }
}
