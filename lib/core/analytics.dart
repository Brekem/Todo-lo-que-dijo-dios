import 'package:firebase_analytics/firebase_analytics.dart';

/// Envoltorio de analíticas: no hace nada si Firebase no está configurado.
abstract final class Analytics {
  static bool enabled = false;

  static void log(String name, [Map<String, Object>? params]) {
    if (!enabled) return;
    FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }
}
