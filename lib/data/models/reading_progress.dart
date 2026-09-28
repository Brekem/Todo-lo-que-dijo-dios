import 'package:flutter/foundation.dart';

/// Estadísticas espirituales locales.
@immutable
class ReadingProgress {
  const ReadingProgress({
    this.readIds = const {},
    this.prayedIds = const {},
    this.prayersCount = 0,
    this.activeDays = const {},
    this.lastReadId,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress(
        readIds: {
          ...(json['readIds'] as List<dynamic>? ?? const []).cast<String>(),
        },
        prayedIds: {
          ...(json['prayedIds'] as List<dynamic>? ?? const []).cast<String>(),
        },
        prayersCount: (json['prayersCount'] as num?)?.toInt() ?? 0,
        activeDays: {
          ...(json['activeDays'] as List<dynamic>? ?? const []).cast<String>(),
        },
        lastReadId: json['lastReadId'] as String?,
      );

  final Set<String> readIds;
  final Set<String> prayedIds;
  final int prayersCount;

  /// Días con actividad, formato `yyyy-mm-dd`.
  final Set<String> activeDays;
  final String? lastReadId;

  Map<String, dynamic> toJson() => {
    'readIds': readIds.toList(),
    'prayedIds': prayedIds.toList(),
    'prayersCount': prayersCount,
    'activeDays': activeDays.toList(),
    if (lastReadId != null) 'lastReadId': lastReadId,
  };

  ReadingProgress copyWith({
    Set<String>? readIds,
    Set<String>? prayedIds,
    int? prayersCount,
    Set<String>? activeDays,
    String? lastReadId,
  }) => ReadingProgress(
    readIds: readIds ?? this.readIds,
    prayedIds: prayedIds ?? this.prayedIds,
    prayersCount: prayersCount ?? this.prayersCount,
    activeDays: activeDays ?? this.activeDays,
    lastReadId: lastReadId ?? this.lastReadId,
  );

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Días seguidos con actividad, contando hasta hoy (o ayer, si hoy aún no).
  int streak(DateTime today) {
    var day = DateTime(today.year, today.month, today.day);
    if (!activeDays.contains(dayKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (activeDays.contains(dayKey(day))) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }
}
