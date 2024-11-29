import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildTextFormField extends StatelessWidget {
  final TextFormFieldData data;
  final int? maxLines;
  const BuildTextFormField({super.key, required this.data, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        maxLines: maxLines ?? 1,
        keyboardType: data.keyboardType,
        inputFormatters: data.inputFormatters ?? [],
        controller: data.controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          labelText: data.labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(25), // Raio da borda arredondada
            borderSide: BorderSide.none, // Remove a borda
          ),
        ),
        validator: data.validateFunction,
      ),
    );
  }
}

class TextFormFieldData {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String labelText;
  final String? Function(String?) validateFunction;
  final BuildContext context;

  TextFormFieldData({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    required this.labelText,
    required this.validateFunction,
    required this.context,
  });
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Remove todos os caracteres que não são números
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Defina a lógica de formatação
    final formattedText = _getFormattedDate(digitsOnly);

    // Retorne o novo valor de texto com a formatação aplicada
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _getFormattedDate(String digitsOnly) {
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(digitsOnly[i]);
    }

    return buffer.toString();
  }
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Remove caracteres que não são válidos para um endereço de e-mail
    final validText = _removeInvalidCharacters(text);

    return TextEditingValue(
      text: validText,
      selection: newValue.selection.copyWith(
        baseOffset: validText.length,
        extentOffset: validText.length,
      ),
    );
  }

  String _removeInvalidCharacters(String text) {
    final RegExp emailRegExp = RegExp(r'[a-zA-Z0-9@._-]');
    return text.split('').where((char) => emailRegExp.hasMatch(char)).join();
  }
}
