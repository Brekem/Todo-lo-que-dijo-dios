import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/passage.dart';
import '../../domain/listening/listening_controller.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/random_word.dart';
import '../../shared/widgets/rotating_search_bar.dart';
import '../../shared/widgets/section_label.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncContent(
          builder: (context, content) => _HomeBody(content: content),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.content});

  final ContentBundle content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final lastReadId = ref.watch(progressProvider.select((p) => p.lastReadId));
    final lastRead = lastReadId == null
        ? null
        : content.passageById(lastReadId);
    final today = content.wordOfTheDay(DateTime.now());

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Todo lo que Dios dijo',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Ajustes',
                  icon: Icon(Icons.tune, color: palette.warmGray),
                  onPressed: () => context.push(Routes.settings),
                ),
              ],
            ),
          ),
        ),
        // Barra superior fija.
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedSearch(
            background: palette.background,
            onTap: () => context.push(Routes.search),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          sliver: SliverList.list(
            children: [
              FadeSlideIn(
                child: _FeaturedWord(
                  label: 'Palabra de hoy',
                  passage: today,
                  onTap: () => context.push(Routes.passage(today.id)),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: _ListenCard(total: content.passages.length),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 130),
                child: _RandomWordCard(passages: content.passages),
              ),
              if (lastRead != null && lastRead != today) ...[
                const SizedBox(height: 14),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: _ContinueJourney(
                    passage: lastRead,
                    position: content.indexOf(lastRead) + 1,
                    total: content.passages.length,
                  ),
                ),
              ],
              const SizedBox(height: 44),
              const SectionLabel('Dios habla sobre…'),
              const SizedBox(height: 18),
              for (final (i, category) in content.categories.indexed) ...[
                FadeSlideIn(
                  delay: Duration(milliseconds: 120 + 70 * i),
                  child: CategoryCard(
                    category: category,
                    count: content.byCategory(category.id).length,
                    onTap: () => context.push(Routes.category(category.id)),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => context.go(Routes.journey),
                icon: Icon(Icons.timeline, color: palette.gold),
                label: const Text('Recorrer la Voz de Dios desde Génesis'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinnedSearch extends SliverPersistentHeaderDelegate {
  _PinnedSearch({required this.background, required this.onTap});

  final Color background;
  final VoidCallback onTap;

  static const _height = 74.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: RotatingSearchBar(onTap: onTap),
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedSearch old) => old.background != background;
}

class _FeaturedWord extends StatelessWidget {
  const _FeaturedWord({
    required this.label,
    required this.passage,
    required this.onTap,
  });

  final String label;
  final Passage passage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      color: palette.blueSoft,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.blueSoft,
                Color.alphaBlend(palette.glow, palette.blueSoft),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label),
              const SizedBox(height: 18),
              Text(
                '«${passage.quote}»',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                passage.reference,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueJourney extends StatelessWidget {
  const _ContinueJourney({
    required this.passage,
    required this.position,
    required this.total,
  });

  final Passage passage;
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        leading: Icon(Icons.play_circle_outline, color: palette.gold, size: 30),
        title: const Text('Continuar recorrido'),
        subtitle: Text(
          '${passage.reference} · palabra $position de $total',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: palette.warmGray,
        ),
        onTap: () => context.push(Routes.passage(passage.id)),
      ),
    );
  }
}

class _RandomWordCard extends ConsumerWidget {
  const _RandomWordCard({required this.passages});

  final List<Passage> passages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        leading: Icon(Icons.shuffle_rounded, color: palette.gold, size: 28),
        title: const Text('Palabra al azar'),
        subtitle: Text(
          'Abre cualquiera de las ${passages.length} palabras de Dios',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: palette.warmGray,
        ),
        onTap: () => openRandomWord(context, ref, passages),
      ),
    );
  }
}

class _ListenCard extends ConsumerWidget {
  const _ListenCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listeningProvider);
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final resume = state.hasSavedPosition && state.started;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.listen),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.gold,
                ),
                child: Icon(
                  state.isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.headphones_rounded,
                  color: const Color(0xFF1B1609),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escuchar las $total palabras',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.isPlaying
                          ? 'Escuchando la palabra ${state.passageIndex + 1}…'
                          : resume
                          ? 'Te quedaste en la palabra ${state.passageIndex + 1} de $total'
                          : state.fromSearch
                          ? 'Las palabras de tu búsqueda «${state.searchQuery}»'
                          : state.shuffle
                          ? 'En orden aleatorio, con oración y todo'
                          : 'De Génesis a Apocalipsis, con oración y todo',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: palette.warmGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
