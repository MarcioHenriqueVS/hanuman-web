import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/notificacoes/fcm.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = 'pk_test_51QUiLJGDBCf7us1AHzCj0ffQvJnJsnUGf8o04tll26q9kzu4iwVwVXKxmAxyfo05AJFv8H1fBTs5MLGLokGFS3ui00ywUSwZb9';
  await initializeDateFormatting('pt_BR', null);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessagingService service = FirebaseMessagingService();
  service.initialize();
 
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.presentError(details);
  //   debugPrint('ERRO DETALHADO: ${details.toString()}');
  // };

  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Material(
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       child: SelectableText(
  //         'Erro: ${details.exception}\n'
  //         'Stack: ${details.stack}',
  //         style: const TextStyle(color: Colors.red),
  //       ),
  //     ),
  //   );
  // };
  runApp(MyApp(settingsController: settingsController));
}
