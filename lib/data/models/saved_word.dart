import 'package:flutter/foundation.dart';

/// Resultado de "Necesito esta palabra para mí".
@immutable
class Personalization {
  const Personalization({
    required this.userSituation,
    required this.explanation,
    required this.application,
    required this.prayer,
    required this.generatedByAi,
  });

  factory Personalization.fromJson(Map<String, dynamic> json) =>
      Personalization(
        userSituation: json['userSituation'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        application: json['application'] as String? ?? '',
        prayer: json['prayer'] as String? ?? '',
        generatedByAi: json['generatedByAi'] as bool? ?? false,
      );

  final String userSituation;
  final String explanation;
  final String application;
  final String prayer;
  final bool generatedByAi;

  Map<String, dynamic> toJson() => {
    'userSituation': userSituation,
    'explanation': explanation,
    'application': application,
    'prayer': prayer,
    'generatedByAi': generatedByAi,
  };
}

/// Una palabra guardada en "Las palabras que guardé": versículo, aplicación
/// y oración (la original o la personalizada).
@immutable
class SavedWord {
  const SavedWord({
    required this.passageId,
    required this.savedAt,
    this.personalization,
  });

  factory SavedWord.fromJson(Map<String, dynamic> json) => SavedWord(
    passageId: json['passageId'] as String,
    savedAt: DateTime.parse(json['savedAt'] as String),
    personalization: json['personalization'] == null
        ? null
        : Personalization.fromJson(
            json['personalization'] as Map<String, dynamic>,
          ),
  );

  final String passageId;
  final DateTime savedAt;
  final Personalization? personalization;

  Map<String, dynamic> toJson() => {
    'passageId': passageId,
    'savedAt': savedAt.toIso8601String(),
    if (personalization != null) 'personalization': personalization!.toJson(),
  };
}
