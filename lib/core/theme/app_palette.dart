import 'package:flutter/material.dart';

/// Colores de marca: marfil, dorado, azul profundo, gris cálido y un rojo
/// carmesí apagado reservado para acentos (favoritos, oración).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.parchment,
    required this.gold,
    required this.goldSoft,
    required this.blue,
    required this.blueSoft,
    required this.warmGray,
    required this.ink,
    required this.crimson,
    required this.glow,
  });

  static const light = AppPalette(
    background: Color(0xFFFAF7F0), // blanco marfil
    parchment: Color(0xFFF4EEE1), // pergamino moderno
    gold: Color(0xFFB8964E), // dorado suave
    goldSoft: Color(0xFFF1E6CB),
    blue: Color(0xFF1F2E52), // azul profundo
    blueSoft: Color(0xFFE4E8F1),
    warmGray: Color(0xFF7D746A), // gris cálido
    ink: Color(0xFF26221E),
    crimson: Color(0xFF94343C),
    glow: Color(0x33E9CF8F),
  );

  static const dark = AppPalette(
    background: Color(0xFF0A0A0C), // negro profundo
    parchment: Color(0xFF141419),
    gold: Color(0xFFC7A968), // dorado tenue
    goldSoft: Color(0xFF2B2518),
    blue: Color(0xFF8FA6D6),
    blueSoft: Color(0xFF151D30), // azul nocturno
    warmGray: Color(0xFFA59D92),
    ink: Color(0xFFF1EBE0), // blanco cálido
    crimson: Color(0xFFC96A70),
    glow: Color(0x22C7A968),
  );

  final Color background;
  final Color parchment;
  final Color gold;
  final Color goldSoft;
  final Color blue;
  final Color blueSoft;
  final Color warmGray;
  final Color ink;
  final Color crimson;
  final Color glow;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  @override
  AppPalette copyWith({
    Color? background,
    Color? parchment,
    Color? gold,
    Color? goldSoft,
    Color? blue,
    Color? blueSoft,
    Color? warmGray,
    Color? ink,
    Color? crimson,
    Color? glow,
  }) => AppPalette(
    background: background ?? this.background,
    parchment: parchment ?? this.parchment,
    gold: gold ?? this.gold,
    goldSoft: goldSoft ?? this.goldSoft,
    blue: blue ?? this.blue,
    blueSoft: blueSoft ?? this.blueSoft,
    warmGray: warmGray ?? this.warmGray,
    ink: ink ?? this.ink,
    crimson: crimson ?? this.crimson,
    glow: glow ?? this.glow,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      parchment: Color.lerp(parchment, other.parchment, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t)!,
      warmGray: Color.lerp(warmGray, other.warmGray, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      crimson: Color.lerp(crimson, other.crimson, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}
