import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../autenticacao/cadastro/bloc/cadastro_bloc.dart';
import '../autenticacao/cadastro/bloc/event_bloc.dart';
import '../autenticacao/cadastro/bloc/state_bloc.dart';
import '../autenticacao/services/user_services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isDarkMode = true;
  final RegisterBloc registerBloc = RegisterBloc(UserServices());
  bool _showPassword = false;
  bool _showConfirmPassword = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['background'] as Color,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 700, maxWidth: 1200),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.78,
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
                          'https://img.icons8.com/clouds/256/add-user.png',
                          width: 300,
                        ),
                      ],
                    ),
                  ),
                ),
                // Coluna da direita - Formulário
                BlocConsumer<RegisterBloc, RegisterState>(
                  bloc: registerBloc,
                  listener: (context, state) async {
                    if (state is RegisterFailure) {
                      context.loaderOverlay.visible
                          ? context.loaderOverlay.hide()
                          : null;
                      GFToast.showToast(
                        state.error,
                        context,
                        toastPosition: GFToastPosition.BOTTOM,
                        backgroundColor: Colors.red,
                      );
                    } else if (state is RegisterSuccess) {
                      context.loaderOverlay.visible
                          ? context.loaderOverlay.hide()
                          : null;
                      if (context.mounted) {
                        context.go('/');
                      }
                    }
                  },
                  builder: (context, state) {
                    return Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Criar Conta',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: colors['text'] as Color,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Preencha seus dados para criar sua conta',
                                  style: TextStyle(
                                    color: colors['subtext'] as Color,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 20),
                                _buildTextField(
                                  controller: _nomeController,
                                  label: 'Nome completo',
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Digite seu nome' : null,
                                ),
                                SizedBox(height: 20),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'Digite seu email';
                                    if (!value.contains('@'))
                                      return 'Email inválido';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Senha',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'Digite sua senha';
                                    if (value.length < 6)
                                      return 'Mínimo 6 caracteres';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar senha',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value != _passwordController.text)
                                      return 'Senhas não conferem';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (_passwordController.text !=
                                            _confirmPasswordController.text) {
                                          GFToast.showToast(
                                            'As senhas não conferem',
                                            context,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                          );
                                          return;
                                        }
                                        context.loaderOverlay.show();
                                        registerBloc.add(
                                          PerformRegisterEvent(
                                              _nomeController.text.trim(),
                                              _emailController.text.trim(),
                                              _passwordController.text.trim()),
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
                                      'Cadastrar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Já tem uma conta? ',
                                          style: TextStyle(
                                              color: colors['subtext']),
                                          children: [
                                            TextSpan(
                                              text: 'Fazer login',
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
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword
          ? (label == 'Senha' ? !_showPassword : !_showConfirmPassword)
          : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors['inputBorder'] as Color),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors['inputBorder'] as Color),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors['inputBorder'] as Color),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors['inputBorder'] as Color),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(
          icon,
          color: colors['inputBorder'] as Color,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  label == 'Senha'
                      ? (_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility)
                      : (_showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                  color: colors['inputBorder'] as Color,
                ),
                onPressed: () {
                  setState(() {
                    if (label == 'Senha') {
                      _showPassword = !_showPassword;
                    } else {
                      _showConfirmPassword = !_showConfirmPassword;
                    }
                  });
                },
              )
            : null,
      ),
      validator: validator,
    );
  }
}
