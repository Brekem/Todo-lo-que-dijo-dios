import 'package:flutter/foundation.dart';

/// Una etapa del recorrido cronológico (Adán, Noé, Abraham…).
@immutable
class Era {
  const Era({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.period,
  });

  factory Era.fromJson(Map<String, dynamic> json) => Era(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    period: json['period'] as String,
  );

  final String id;
  final String title;
  final String subtitle;

  /// Referencia temporal aproximada, p. ej. "c. 2000 a. C.".
  final String period;
}
