
import 'package:flutter/material.dart';

class TreinoThemeData {
  final Color headerBackgroundColor;
  final Color metricCardBackgroundColor;
  final Color metricCardBorderColor;
  final Color metricLabelColor;
  final Color metricValueColor;

  const TreinoThemeData({
    required this.headerBackgroundColor,
    required this.metricCardBackgroundColor,
    required this.metricCardBorderColor,
    required this.metricLabelColor,
    required this.metricValueColor,
  });
}

extension TreinoTheme on ThemeData {
  static final _defaultLightTreinoTheme = TreinoThemeData(
    headerBackgroundColor: const Color(0xFFF5F5F5),
    metricCardBackgroundColor: Colors.white,
    metricCardBorderColor: Colors.grey[300]!,
    metricLabelColor: Colors.grey[600]!,
    metricValueColor: Colors.black87,
  );

  static final _defaultDarkTreinoTheme = TreinoThemeData(
    headerBackgroundColor: const Color(0xFF212121),
    metricCardBackgroundColor: const Color(0xFF212121),
    metricCardBorderColor: Colors.white10,
    metricLabelColor: Colors.white54,
    metricValueColor: Colors.white,
  );

  TreinoThemeData get treinoTheme =>
      brightness == Brightness.light ? _defaultLightTreinoTheme : _defaultDarkTreinoTheme;
}