import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/praying_hands_icon.dart';
import '../../shared/widgets/section_label.dart';

/// Estadísticas espirituales: sin rankings ni comparaciones, solo tu camino.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncContent(
          builder: (context, content) {
            final readPassages = [
              for (final id in progress.readIds) ?content.passageById(id),
            ];
            final exploredCategories = {
              for (final p in readPassages) ...p.categories,
            };
            final total = content.passages.length;
            final streak = progress.streak(DateTime.now());

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              children: [
                Text('Mi camino', style: theme.textTheme.displaySmall),
                const SizedBox(height: 12),
                Text(
                  'Un registro sereno de lo que has escuchado. Solo tú lo ves.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.warmGray,
                  ),
                ),
                const SizedBox(height: 28),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  children: [
                    FadeSlideIn(
                      child: _StatTile(
                        value: '${readPassages.length}',
                        label: 'Palabras leídas',
                        caption: 'de $total',
                        icon: const Icon(Icons.auto_stories_outlined),
                        progress: total == 0 ? 0 : readPassages.length / total,
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: _StatTile(
                        value: '$streak',
                        label: 'Días seguidos',
                        caption: streak == 1 ? 'día' : 'días',
                        icon: const Icon(Icons.wb_sunny_outlined),
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: _StatTile(
                        value: '${exploredCategories.length}',
                        label: 'Temas explorados',
                        caption: 'de ${content.categories.length}',
                        icon: const Icon(Icons.explore_outlined),
                        progress: content.categories.isEmpty
                            ? 0
                            : exploredCategories.length /
                                  content.categories.length,
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: _StatTile(
                        value: '${progress.prayersCount}',
                        label: 'Oraciones realizadas',
                        caption: 'amén',
                        icon: PrayingHandsIcon(size: 22, color: palette.gold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const SectionLabel('Por tema'),
                const SizedBox(height: 18),
                for (final c in content.categories) ...[
                  Builder(
                    builder: (context) {
                      final all = content.byCategory(c.id);
                      final done = all
                          .where((p) => progress.readIds.contains(p.id))
                          .length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(c.icon, size: 18, color: palette.gold),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  c.title,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '$done/${all.length}',
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: all.isEmpty ? 0 : done / all.length,
                              ),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) =>
                                  LinearProgressIndicator(
                                    value: v,
                                    minHeight: 4,
                                    color: palette.gold,
                                    backgroundColor: palette.warmGray
                                        .withValues(alpha: 0.12),
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.caption,
    required this.icon,
    this.progress,
  });

  final String value;
  final String label;
  final String caption;
  final Widget icon;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTheme(
              data: IconThemeData(color: palette.gold, size: 22),
              child: icon,
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.displayMedium?.copyWith(height: 1),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(caption, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: theme.textTheme.labelLarge),
            if (progress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  color: palette.gold,
                  backgroundColor: palette.warmGray.withValues(alpha: 0.12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
