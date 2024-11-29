import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeasurementTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? unit;
  final double? width;
  final FormFieldValidator<String>? validator;

  const MeasurementTextField({
    super.key,
    required this.controller,
    required this.label,
    this.unit,
    this.width,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 110,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          labelText: unit != null ? '$label ($unit)' : label,
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
          CommaToPointInputFormatter(),
        ],
        validator: validator,
      ),
    );
  }
}

class CommaToPointInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(',', '.');
    return newValue.copyWith(text: newText);
  }
}
