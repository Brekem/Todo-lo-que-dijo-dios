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
    this.onGold = const Color(0xFF1B1609),
    this.onGoldSoft = const Color(0xFF4A3A14),
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

  /// Edición «Jehová»: azul y blanco. El azul brillante ocupa el lugar del
  /// dorado.
  static const jehovaLight = AppPalette(
    background: Color(0xFFFFFFFF), // blanco
    parchment: Color(0xFFF2F6FC), // blanco azulado
    gold: Color(0xFF2B5CB0), // azul real
    goldSoft: Color(0xFFDDE8F8),
    blue: Color(0xFF12264A), // azul marino
    blueSoft: Color(0xFFE6EDF8),
    warmGray: Color(0xFF66718A), // gris azulado
    ink: Color(0xFF111C33),
    crimson: Color(0xFF94343C),
    glow: Color(0x332B5CB0),
    onGold: Color(0xFFFFFFFF),
    onGoldSoft: Color(0xFF173469),
  );

  static const jehovaDark = AppPalette(
    background: Color(0xFF060A14), // azul noche
    parchment: Color(0xFF0E1628),
    gold: Color(0xFF8DB3F2), // azul cielo
    goldSoft: Color(0xFF15233F),
    blue: Color(0xFFB9CCF2),
    blueSoft: Color(0xFF111C33),
    warmGray: Color(0xFF9AA5BA),
    ink: Color(0xFFF2F6FD), // blanco
    crimson: Color(0xFFC96A70),
    glow: Color(0x228DB3F2),
    onGold: Color(0xFF07142B),
    onGoldSoft: Color(0xFFDCE7FA),
  );

  /// Edición «Jesús»: dorado y verde. El verde profundo ocupa el lugar
  /// del azul.
  static const jesusLight = AppPalette(
    background: Color(0xFFFBFAF3), // blanco marfil
    parchment: Color(0xFFF3F1E2),
    gold: Color(0xFFB8913A), // dorado
    goldSoft: Color(0xFFF2E8C9),
    blue: Color(0xFF1E4D2B), // verde profundo
    blueSoft: Color(0xFFE3EFE5),
    warmGray: Color(0xFF6F7568), // gris verdoso
    ink: Color(0xFF1C261E),
    crimson: Color(0xFF94343C),
    glow: Color(0x33B8913A),
  );

  static const jesusDark = AppPalette(
    background: Color(0xFF07100A), // verde noche
    parchment: Color(0xFF0F1A12),
    gold: Color(0xFFD4B062), // dorado
    goldSoft: Color(0xFF2A2615),
    blue: Color(0xFF9FD3A8), // verde claro
    blueSoft: Color(0xFF12241A),
    warmGray: Color(0xFFA3AB9C),
    ink: Color(0xFFF3F1E6),
    crimson: Color(0xFFC96A70),
    glow: Color(0x22D4B062),
    onGoldSoft: Color(0xFFF1E6CB),
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

  /// Texto sobre [gold] y sobre [goldSoft].
  final Color onGold;
  final Color onGoldSoft;

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
    Color? onGold,
    Color? onGoldSoft,
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
    onGold: onGold ?? this.onGold,
    onGoldSoft: onGoldSoft ?? this.onGoldSoft,
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
      onGold: Color.lerp(onGold, other.onGold, t)!,
      onGoldSoft: Color.lerp(onGoldSoft, other.onGoldSoft, t)!,
    );
  }
}
