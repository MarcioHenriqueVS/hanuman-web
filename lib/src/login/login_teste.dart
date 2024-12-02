import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'components/reset_senha_dialog.dart';
import 'event_bloc.dart';
import 'login_bloc.dart';
import 'state_bloc.dart';

class LoginTeste extends StatefulWidget {
  const LoginTeste({super.key});

  @override
  State<LoginTeste> createState() => _LoginTesteState();
}

class _LoginTesteState extends State<LoginTeste> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isDarkMode = true;
  bool _passwordVisible = false; // Adicione esta linha após as outras variáveis

  // Cores dinâmicas baseadas no tema com tipagem explícita
  Map<String, dynamic> get colors => {
        'background': isDarkMode ? Colors.grey[900]! : Colors.white,
        'cardBg': isDarkMode ? Colors.grey[800]! : Colors.white,
        'text': isDarkMode ? Colors.white : const Color(0xFF2D3748),
        'subtext': isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
        'inputBorder': isDarkMode ? Colors.grey[600]! : Colors.grey,
        'buttonColor': Colors.green,
        'gradient': isDarkMode
            ? [
                Colors.green.shade900,
                Colors.green.shade800,
                Colors.green.shade700,
              ]
            : [
                Colors.green,
                Colors.green.shade400,
                Colors.green.shade600,
              ],
      };

  void _showResetPasswordDialog() {
    showDialog(context: context, builder: (context) => ResetSenhaDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['background'] as Color,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 700, maxWidth: 1200),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colors['cardBg'] as Color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Coluna da esquerda - Imagem
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors['gradient']!,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('BANNER'),
                        Image.network(
                          'https://img.icons8.com/clouds/256/login.png',
                          width: 300,
                        ),
                      ],
                    ),
                  ),
                ),
                // Coluna da direita - Formulário
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Form(
                      key: _formKey,
                      child: BlocConsumer<LoginBloc, LoginState>(
                        listener: (context, state) async {
                          if (state is LoginSuccess) {
                            context.go('/');
                          } else if (state is LoginFailure) {
                            GFToast.showToast(
                              state.error,
                              context,
                              toastPosition: GFToastPosition.BOTTOM,
                              backgroundColor: Colors.red,
                            );
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seja Bem Vindo',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colors['text'] as Color,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Entre com suas credenciais para acessar',
                                style: TextStyle(
                                  color: colors['subtext'] as Color,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 50),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                      color: colors['inputBorder'] as Color),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colors['inputBorder'] as Color),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colors['inputBorder'] as Color),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colors['inputBorder'] as Color),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: colors['inputBorder'] as Color,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Por favor, insira seu email'
                                    : null,
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible, // Modificado
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  labelStyle: TextStyle(
                                      color: colors['inputBorder'] as Color),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colors['inputBorder'] as Color),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colors['inputBorder'] as Color),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colors['inputBorder'] as Color),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: colors['inputBorder'] as Color,
                                  ),
                                  suffixIcon: IconButton(
                                    // Adicione este bloco
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: colors['inputBorder'] as Color,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Por favor, insira sua senha'
                                    : null,
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showResetPasswordDialog,
                                  child: Text(
                                    'Esqueceu a senha?',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<LoginBloc>().add(
                                            PerformLoginEvent(
                                                _emailController.text,
                                                _passwordController.text),
                                          );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text(
                                    'Entrar',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => context.go('/cadastro'),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Não tem uma conta? ',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        children: [
                                          TextSpan(
                                            text: 'Cadastre-se',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
