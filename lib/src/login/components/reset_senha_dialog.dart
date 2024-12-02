import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:web_test/src/login/animated_login/src/utils/validators.dart';
import '../../autenticacao/services/user_services.dart';

class ResetSenhaDialog extends StatefulWidget {
  const ResetSenhaDialog({super.key});

  @override
  State<ResetSenhaDialog> createState() => _ResetSenhaDialogState();
}

class _ResetSenhaDialogState extends State<ResetSenhaDialog> {
  final _resetEmailController = TextEditingController();
  bool isDarkMode = true;
  final UserServices userServices = UserServices();
  //formKey
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: colors['cardBg'] as Color,
      title: Text(
        'Recuperar Senha',
        style: TextStyle(color: colors['text'] as Color),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Digite seu email para receber instruções de recuperação de senha',
            style: TextStyle(color: colors['subtext'] as Color),
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _resetEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: colors['inputBorder'] as Color),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors['inputBorder'] as Color),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: colors['inputBorder'] as Color,
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, insira um email';
                } else if (Validators().email(value) != null) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        GFButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await userServices.resetPassword(
                    context, _resetEmailController.text.trim());
                Navigator.pop(context);
                GFToast.showToast(
                  'Email de recuperação enviado!',
                  context,
                  toastPosition: GFToastPosition.BOTTOM,
                  backgroundColor: Colors.green,
                );
              } catch (e) {
                GFToast.showToast(
                  'Erro ao enviar email de recuperação',
                  context,
                  toastPosition: GFToastPosition.BOTTOM,
                  backgroundColor: Colors.red,
                );
              }
            }
          },
          color: colors['buttonColor'] as Color,
          borderShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Enviar'),
        ),
      ],
    );
  }
}
