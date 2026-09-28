import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/passage.dart';
import '../../data/models/saved_word.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/praying_hands_icon.dart';

/// "Las palabras que guardé": versículo, aplicación y oración.
class SavedWordsScreen extends ConsumerWidget {
  const SavedWordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedWordsProvider);
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncContent(
          builder: (context, content) {
            final items = [
              for (final w in saved)
                if (content.passageById(w.passageId) case final p?) (w, p),
            ];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Las palabras\nque guardé',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          items.isEmpty
                              ? 'Cuando una palabra te hable, guárdala con el marcador. Aquí la encontrarás junto a su aplicación y su oración.'
                              : '${items.length} ${items.length == 1 ? 'palabra guardada' : 'palabras guardadas'}. Desliza para quitar.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.warmGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Icon(
                        Icons.bookmark_outline,
                        size: 56,
                        color: palette.gold.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final (word, passage) = items[i];
                        return Dismissible(
                          key: ValueKey(word.passageId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 28),
                            child: Icon(
                              Icons.delete_outline,
                              color: palette.crimson,
                            ),
                          ),
                          onDismissed: (_) {
                            ref
                                .read(savedWordsProvider.notifier)
                                .remove(word.passageId);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: const Text('Palabra quitada'),
                                  action: SnackBarAction(
                                    label: 'Deshacer',
                                    onPressed: () => ref
                                        .read(savedWordsProvider.notifier)
                                        .save(
                                          word.passageId,
                                          personalization: word.personalization,
                                        ),
                                  ),
                                ),
                              );
                          },
                          child: _SavedCard(word: word, passage: passage),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.word, required this.passage});

  final SavedWord word;
  final Passage passage;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final personal = word.personalization;
    final application = personal?.application ?? passage.application;
    final prayer = personal?.prayer ?? passage.prayer;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.passage(passage.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '«${passage.quote}»',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                passage.reference,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.gold,
                ),
              ),
              if (personal != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Para: ${personal.userSituation}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wb_twilight_outlined,
                    size: 18,
                    color: palette.gold,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      application,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrayingHandsIcon(size: 18, color: palette.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prayer,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
