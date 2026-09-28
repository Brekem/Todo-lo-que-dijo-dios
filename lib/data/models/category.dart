import 'package:flutter/material.dart';

@immutable
class Category {
  const Category({
    required this.id,
    required this.title,
    required this.headline,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    title: json['title'] as String,
    headline: json['headline'] as String,
    description: json['description'] as String,
    icon: _icons[json['icon']] ?? Icons.auto_awesome,
    color: Color(int.parse(json['color'] as String, radix: 16)),
  );

  final String id;

  /// Nombre de la categoría, p. ej. "Dios libera el miedo".
  final String title;

  /// Título de la tarjeta de inicio, p. ej. "Dios habla sobre el miedo".
  final String headline;
  final String description;
  final IconData icon;
  final Color color;

  // Mapa explícito para que el tree-shaking de iconos funcione en release.
  static const Map<String, IconData> _icons = {
    'shield': Icons.shield_outlined,
    'spa': Icons.spa_outlined,
    'water_drop': Icons.water_drop_outlined,
    'sentiment': Icons.sentiment_satisfied_alt_outlined,
    'group': Icons.group_outlined,
    'anchor': Icons.anchor_outlined,
    'route': Icons.route_outlined,
    'favorite': Icons.favorite_outline,
    'handshake': Icons.handshake_outlined,
    'sunny': Icons.wb_sunny_outlined,
    'undo': Icons.u_turn_left_rounded,
    'balance': Icons.balance_outlined,
    'record_voice': Icons.record_voice_over_outlined,
  };
}
