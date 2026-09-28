import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/passage_tile.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AsyncContent(
        builder: (context, content) {
          final category = content.categoryById(categoryId);
          if (category == null) {
            return const Center(child: Text('Tema no encontrado'));
          }
          final passages = content.byCategory(categoryId);
          final palette = AppPalette.of(context);
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            children: [
              FadeSlideIn(
                child: Icon(
                  category.icon,
                  size: 36,
                  color: Color.lerp(category.color, palette.gold, 0.35),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  category.headline,
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  category.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.warmGray,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${passages.length} palabras en orden cronológico',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: palette.gold,
                ),
              ),
              const SizedBox(height: 28),
              for (final (i, p) in passages.indexed) ...[
                FadeSlideIn(
                  delay: Duration(milliseconds: 250 + 60 * i.clamp(0, 8)),
                  child: PassageTile(
                    passage: p,
                    onTap: () => context.push(Routes.passage(p.id)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}
