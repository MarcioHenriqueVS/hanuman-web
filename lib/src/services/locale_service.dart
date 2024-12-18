import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Importe para web
import 'dart:io' show Platform; // Importe para mobile

class LocaleService {
  static Future<Locale> getDeviceLocale() async {
    if (kIsWeb) {
      // Para Web, use o idioma do navegador
      final browserLanguage = html.window.navigator.language;
      final languageCode = browserLanguage.split('-')[0];
      final countryCode = browserLanguage.split('-').length > 1
          ? browserLanguage.split('-')[1]
          : '';

      debugPrint('📍 Plataforma: Web');
      debugPrint('🌐 Idioma do navegador: $browserLanguage');
      debugPrint('🏳️ Locale definido: $languageCode-$countryCode');

      return Locale(languageCode, countryCode);
    }

    try {
      // Verifica permissão
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Verificando permissão de localização: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Solicitando permissão de localização: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permissão negada. Usando locale padrão: en');
        return const Locale('en', ''); // Fallback para inglês
      }

      // Obtém a posição
      final position = await Geolocator.getCurrentPosition();
      debugPrint('📍 Localização atual:');
      debugPrint('   Latitude: ${position.latitude}');
      debugPrint('   Longitude: ${position.longitude}');

      // Baseado nas coordenadas, define o locale
      // Isso é uma simplificação. Você pode usar um serviço de geocoding
      // para uma definição mais precisa do país
      if (position.latitude >= -33.7683 &&
          position.latitude <= 5.2718 &&
          position.longitude >= -73.9856 &&
          position.longitude <= -28.6341) {
        debugPrint('🇧🇷 Localização detectada: Brasil');
        return const Locale('pt', 'BR'); // Brasil
      } else if (position.latitude >= 36.8928 &&
          position.latitude <= 42.1543 &&
          position.longitude >= -9.5000 &&
          position.longitude <= -6.1891) {
        debugPrint('🇵🇹 Localização detectada: Portugal');
        return const Locale('pt', 'PT'); // Portugal
      }

      debugPrint(
          '🌍 Localização fora das áreas definidas. Usando locale padrão: en');
      return const Locale('en', ''); // Fallback para inglês
    } catch (e) {
      debugPrint('❌ Erro ao obter localização: $e');
      debugPrint('   Usando locale padrão: en');
      return const Locale('en', ''); // Fallback para inglês em caso de erro
    }
  }
}
