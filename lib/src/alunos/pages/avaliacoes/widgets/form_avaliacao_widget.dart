import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils.dart';
import 'measurement_text_field.dart';

class FormBasicoAvaliacaoWidget extends StatelessWidget {
  final TextEditingController titulo;
  final TextEditingController obs;
  final TextEditingController pesoController;
  final TextEditingController alturaController;
  final GlobalKey<FormState> formBasicoAvaliacaoKey; // Renomeado aqui

  const FormBasicoAvaliacaoWidget({
    super.key,
    required this.titulo,
    required this.obs,
    required this.pesoController,
    required this.alturaController,
    required this.formBasicoAvaliacaoKey, // Renomeado aqui
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formBasicoAvaliacaoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados básicos',
            style: SafeGoogleFont(
              'Outfit',
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // campo para preencher o titulo da avaliacao
          _buildFormField(
            controller: titulo,
            keyboardType: TextInputType.text,
            inputFormatters: [
              LengthLimitingTextInputFormatter(25),
            ],
            validateFunction: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o título';
              }
              return null;
            },
            label: 'Título da Avaliação',
          ),
          const SizedBox(height: 16),
          // campo para preencher observações
          _buildFormField(
            controller: obs,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
              ),
              LengthLimitingTextInputFormatter(200),
            ],
            validateFunction: (value) {
              return null;
            },
            label: 'Observações',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^\d*[.,]?\d*')), // Permite apenas números e ponto
                    CommaToPointInputFormatter(), // Substitui vírgulas por pontos
                  ],
                  label: 'Peso (kg)',
                  validateFunction: (value) {
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: alturaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    CommaToPointInputFormatter(), // Substitui vírgulas por pontos
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                  ],
                  label: 'Altura (m)',
                  validateFunction: (value) {
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController? controller,
    required String label,
    required List<TextInputFormatter>? inputFormatters,
    required TextInputType? keyboardType,
    required String? Function(String?) validateFunction,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      validator: validateFunction,
      style: SafeGoogleFont(
        'Readex Pro',
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: SafeGoogleFont(
          'Readex Pro',
          textStyle: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
