import 'package:flutter/services.dart';

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