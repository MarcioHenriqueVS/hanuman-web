import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../decorations/input_decorations.dart';
import '../../decorations/text_styles.dart';
import '../../providers/login_theme.dart';
import 'text_form_field_wrapper.dart';

/// Base [TextFormField] wrapped with [BaseTextFormFieldWrapper].
class CustomTextFormField extends StatelessWidget {
  /// Implements login decoration as default, can be customized with params.
  /// Used for implementation of name and email text form fields.
  const CustomTextFormField({
    required this.controller,
    required this.validator,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.backgroundColor,
    this.widthFactor,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const <String>[],
    this.textInputType,
    super.key,
  });

  /// Controller for the text form field.
  final TextEditingController controller;

  /// Validator of the text field.
  final FormFieldValidator<String?>? validator;

  /// Callback to call on text change.
  final void Function(String? text) onChanged;

  /// Hint text of the field.
  final String? hintText;

  /// Prefix icon.
  final IconData? prefixIcon;

  /// Custom prefix widget.
  final Widget? prefixWidget;

  /// Background color of the field.
  final Color? backgroundColor;

  /// Width factor.
  final double? widthFactor;

  /// Custom text input action.
  final TextInputAction textInputAction;

  /// Custom list of auto fill hints.
  final Iterable<String> autofillHints;

  /// Custom text input type.
  final TextInputType? textInputType;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<LoginTheme>();
    return Container(
      height: 55,
      constraints: const BoxConstraints(maxWidth: 450),
      child: BaseTextFormFieldWrapper(
        formField: TextFormField(
          
          cursorColor: Colors.grey,
          controller: controller,
          textInputAction: textInputAction,
          validator: validator,
          style: 
          //TextStyles(context).textFormStyle().merge(
            //theme.textFormStyle
            TextStyle(
              color: Colors.grey[900],
              fontSize: 16),
           // ),
          //decoration: theme.textFormFieldDeco ?? _getFormDeco(context),
          decoration: InputDecoration(
            //labelText: hintText,
            label: Text(hintText ?? '', style: TextStyle(color: Colors.grey)),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey,
            ),
          ),
          onChanged: onChanged,
          autofillHints: autofillHints,
          keyboardType: textInputType,
        ),
        widthFactor: widthFactor,
      ),
    );
  }

  InputDecoration _getFormDeco(BuildContext context) =>
      InputDeco(context).loginDeco(
        hintText: hintText,
        prefixIcon: prefixIcon,
        prefixWidget: prefixWidget,
      );
}
