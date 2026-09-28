import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

/// Rótulo pequeño en versalitas con una línea dorada, para separar secciones.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding = EdgeInsets.zero});

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(width: 18, height: 1, color: palette.gold),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.gold,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
