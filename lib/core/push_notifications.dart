import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'config/edition.dart';

/// Notificaciones push (Firebase Cloud Messaging). La app se suscribe a los
/// temas de su edición; el envío lo hace la Cloud Function programada
/// (functions/src/index.ts). Sin Firebase no se usa.
abstract final class PushNotifications {
  /// Versículo del día, cada mañana.
  static String get dailyTopic => '${Edition.current.name}-versiculo-del-dia';

  static Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      await messaging.subscribeToTopic(dailyTopic);
    } catch (e) {
      debugPrint('Notificaciones push no disponibles: $e');
    }
  }
}
