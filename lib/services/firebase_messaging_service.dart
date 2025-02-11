import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService{

  Future<void> requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Para Android 13+
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('❌ Permissão de notificação negada');
    } else {
      print('✅ Permissão de notificação concedida');
    }
  }

  static void setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensagem recebida no app: ${message.notification?.title}");

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Usuário tocou na notificação e abriu o app.");
    });
  }

  static void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("Token do dispositivo: $token");
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Mensagem recebida em segundo plano: ${message.messageId}");
  }
}