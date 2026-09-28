import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../data/models/category.dart';

/// Tarjeta grande de la página principal: "Dios habla sobre el miedo".
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.count,
    required this.onTap,
  });

  final Category category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final accent = Color.lerp(category.color, palette.gold, 0.35)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 20, 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(category.icon, color: accent, size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.headline, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      category.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.warmGray,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      count == 1 ? '1 palabra' : '$count palabras',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: palette.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: palette.warmGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
