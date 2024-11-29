import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notificacoess.dart';

class FirebaseMessagingService {
  FirebaseMessagingService();

  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
    await FirebaseMessaging.instance.requestPermission();
    getDeviceFirebaseToken();
    _onMessage();
  }

  getDeviceFirebaseToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      sound: true,
    );
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      if (notification != null && android != null || apple != null) {
        _notificationService.showNotification(CustomNotification(
          id: android.hashCode,
          title: notification?.title!,
          body: notification?.body!,
          payload: message.data['rota'] ?? '',
        ));
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String rota = message.data['rota'] ?? '';
    if (rota.isNotEmpty) {
      //! Rotas.router.push(rota);
    }
  }

  Future<void> enviarNotificacao(
      String token, String title, String body, String? rota, data) async {
    const postUrl =
        "https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/enviarNotificacao";

    Dio dio = Dio();

    try {
      Response response = await dio.post(
        postUrl,
        data: {
          'body': body,
          'title': title,
          'token': token,
          'data': data,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Notificação enviada com sucesso');
      } else {
        debugPrint('Falha ao enviar notificação: ${response.data}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
    }
  }

  Future<void> enviarNotificacaoParaAluno(
      String alunoUid, String title, String body, data) async {
    const postUrl =
        "https://southamerica-east1-hanuman-4e9f4.cloudfunctions.net/enviarNotificacaoParaAluno2";

    Dio dio = Dio();

    try {
      Response response = await dio.post(
        postUrl,
        data: {
          'body': body,
          'title': title,
          'alunoUid': alunoUid,
          'data': data ?? '',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Notificação enviada com sucesso');
      } else {
        debugPrint('Falha ao enviar notificação: ${response.data}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
    }
  }
}
