import 'package:flutter/material.dart';
import '../../decorations/button_styles.dart';
import '../../decorations/text_styles.dart';
import '../../responsiveness/dynamic_size.dart';
import '../texts/base_text.dart';

/// Base text button with custom parameters
class BaseTextButton extends StatelessWidget {
  /// Wraps [TextButton] with [FittedBox], and gives some paddings.
  const BaseTextButton({
    required this.text,
    required this.onPressed,
    this.style,
    this.padding,
    super.key,
  });

  /// Text of the button.
  final String text;

  /// Callback to call on pressed.
  final VoidCallback onPressed;

  /// Style of the [text].
  final TextStyle? style;

  /// Padding inside the button.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final dynamicSize = DynamicSize(context);
    return FittedBox(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyles(context).textButtonStyle(
          padding: padding ?? EdgeInsets.fromLTRB
          (dynamicSize.responsiveSize * 3, dynamicSize.responsiveSize * 3, dynamicSize.responsiveSize * 3, dynamicSize.responsiveSize * 1),
        ),
        child: BaseText(
          text,
          //style: TextStyles(context).normalStyle().merge(style),
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            //sublinhado
            //decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
