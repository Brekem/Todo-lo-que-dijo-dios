import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/passage_tile.dart';
import '../../shared/widgets/random_word.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passages = ref.watch(
      contentProvider.select((c) => c.value?.byCategory(categoryId)),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (passages != null && passages.length > 1)
            RandomWordAction(
              passages: passages,
              tooltip: 'Una palabra al azar de este tema',
            ),
        ],
      ),
      body: AsyncContent(
        builder: (context, content) {
          final category = content.categoryById(categoryId);
          if (category == null) {
            return const Center(child: Text('Tema no encontrado'));
          }
          final passages = content.byCategory(categoryId);
          final palette = AppPalette.of(context);
          final theme = Theme.of(context);
          final header = [
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
              style: theme.textTheme.labelMedium?.copyWith(color: palette.gold),
            ),
            const SizedBox(height: 28),
          ];
          // Lista perezosa: algunos temas tienen cientos de palabras.
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            itemCount: header.length + passages.length,
            itemBuilder: (context, i) {
              if (i < header.length) return header[i];
              final j = i - header.length;
              final p = passages[j];
              final tile = PassageTile(
                passage: p,
                onTap: () => context.push(Routes.passage(p.id)),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                // Solo las primeras aparecen con animación; las demás al
                // desplazarse deben verse al instante.
                child: j < 8
                    ? FadeSlideIn(
                        delay: Duration(milliseconds: 250 + 60 * j),
                        child: tile,
                      )
                    : tile,
              );
            },
          );
        },
      ),
    );
  }
}
