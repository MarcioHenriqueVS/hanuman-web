import 'package:flutter/material.dart';

class ActionButtonThemeData {
  final Color labelColor;
  final Color iconColor;
  final Color hoverColor;

  const ActionButtonThemeData({
    required this.labelColor,
    required this.iconColor,
    required this.hoverColor,
  });
}

extension ActionButtonTheme on ThemeData {
  static final _defaultLightActionButtonTheme = ActionButtonThemeData(
    labelColor: Colors.green,
    iconColor: Colors.green,
    hoverColor: Colors.green.withOpacity(0.1),
  );

  static final _defaultDarkActionButtonTheme = ActionButtonThemeData(
    labelColor: Colors.green,
    iconColor: Colors.green,
    hoverColor: Colors.green.withOpacity(0.1),
  );

  ActionButtonThemeData get actionButtonTheme => brightness == Brightness.light
      ? _defaultLightActionButtonTheme
      : _defaultDarkActionButtonTheme;
}
