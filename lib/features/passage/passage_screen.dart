import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/edition.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/analytics.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/passage.dart';
import '../../domain/listening/listening_controller.dart';
import '../../domain/random_word.dart';
import '../../domain/search/search_engine.dart';
import '../../shared/widgets/verses_text.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/golden_shimmer.dart';
import '../../shared/widgets/section_label.dart';
import 'reading_blocks.dart';

/// Pantalla de lectura. Desliza a los lados para avanzar cronológicamente.
class PassageScreen extends ConsumerStatefulWidget {
  const PassageScreen({super.key, required this.passageId});

  final String passageId;

  @override
  ConsumerState<PassageScreen> createState() => _PassageScreenState();
}

class _PassageScreenState extends ConsumerState<PassageScreen> {
  PageController? _controller;
  int _index = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onShown(Passage passage) {
    ref.read(progressProvider.notifier).markRead(passage.id);
    Analytics.log('open_word', {'id': passage.id});
  }

  @override
  Widget build(BuildContext context) {
    return AsyncContent(
      builder: (context, content) {
        if (_controller == null) {
          final passage = content.passageById(widget.passageId);
          if (passage == null) {
            return const Scaffold(
              body: Center(child: Text('Palabra no encontrada')),
            );
          }
          _index = content.indexOf(passage);
          _controller = PageController(initialPage: _index);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _onShown(passage),
          );
        }
        final current = content.passages[_index];
        return Scaffold(
          appBar: _ReadingAppBar(passage: current),
          body: PageView.builder(
            controller: _controller,
            itemCount: content.passages.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              HapticFeedback.selectionClick();
              _onShown(content.passages[i]);
            },
            itemBuilder: (context, i) => _PassageView(
              key: ValueKey(content.passages[i].id),
              passage: content.passages[i],
              content: content,
            ),
          ),
          bottomNavigationBar: _ChronologyBar(
            index: _index,
            total: content.passages.length,
            eraTitle: content.eraById(current.era)?.title ?? '',
            onPrevious: _index == 0 ? null : () => _go(_index - 1),
            onNext: _index == content.passages.length - 1
                ? null
                : () => _go(_index + 1),
            onRandom: () => _goRandom(content),
            onListen: () => context.push(Routes.listenFrom(current.id)),
          ),
        );
      },
    );
  }

  /// Salta a cualquier palabra de la Biblia (sin animar las cientos de
  /// páginas intermedias).
  void _goRandom(ContentBundle content) {
    final next = pickRandom(
      content.passages,
      ref.read(randomProvider),
      except: content.passages[_index],
    );
    if (next == null) return;
    HapticFeedback.mediumImpact();
    _controller?.jumpToPage(content.indexOf(next));
    Analytics.log('random_word', {'id': next.id});
  }

  void _go(int page) => _controller?.animateToPage(
    page,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutCubic,
  );
}

class _ReadingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ReadingAppBar({required this.passage});

  final Passage passage;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isSavedProvider(passage.id));
    final palette = AppPalette.of(context);
    return AppBar(
      title: Text(
        passage.reference,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: [
        IconButton(
          tooltip: 'Repetir esta palabra',
          icon: const Icon(Icons.repeat_one_rounded),
          onPressed: () {
            final listening = ref.read(listeningProvider.notifier);
            if (ref.read(listeningProvider).repeat == ListenRepeat.off) {
              listening.setRepeat(ListenRepeat.word);
            }
            context.push(Routes.listenFrom(passage.id));
          },
        ),
        IconButton(
          tooltip: saved ? 'Quitar de guardadas' : 'Guardar palabra',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              saved ? Icons.bookmark : Icons.bookmark_outline,
              key: ValueKey(saved),
              color: saved ? palette.gold : null,
            ),
          ),
          onPressed: () {
            final nowSaved = ref
                .read(savedWordsProvider.notifier)
                .toggle(passage.id);
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    nowSaved
                        ? 'Guardada en «Las palabras que guardé»'
                        : 'Quitada de tus palabras guardadas',
                  ),
                ),
              );
            Analytics.log(nowSaved ? 'save_word' : 'unsave_word', {
              'id': passage.id,
            });
          },
        ),
        IconButton(
          tooltip: 'Compartir',
          icon: const Icon(Icons.ios_share_outlined),
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(
                text: passage.toShareText(),
                subject: passage.reference,
              ),
            );
            Analytics.log('share_word', {'id': passage.id});
          },
        ),
      ],
    );
  }
}

class _ChronologyBar extends StatelessWidget {
  const _ChronologyBar({
    required this.index,
    required this.total,
    required this.eraTitle,
    required this.onPrevious,
    required this.onNext,
    required this.onRandom,
    required this.onListen,
  });

  final int index;
  final int total;
  final String eraTitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onRandom;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: palette.warmGray.withValues(alpha: 0.12)),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Palabra al azar',
              onPressed: onRandom,
              icon: Icon(Icons.shuffle_rounded, color: palette.gold),
            ),
            IconButton(
              tooltip: 'Palabra anterior',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    eraTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: palette.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (index + 1) / total,
                      minHeight: 2,
                      color: palette.gold,
                      backgroundColor: palette.warmGray.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Palabra ${index + 1} de $total',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Palabra siguiente',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              tooltip: 'Escuchar desde aquí',
              onPressed: onListen,
              icon: Icon(Icons.headphones_outlined, color: palette.gold),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassageView extends ConsumerWidget {
  const _PassageView({super.key, required this.passage, required this.content});

  final Passage passage;
  final ContentBundle content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final prayed = ref.watch(
      progressProvider.select((p) => p.prayedIds.contains(passage.id)),
    );

    Duration d(int ms) => Duration(milliseconds: ms);

    return DecoratedBox(
      // Pergamino moderno: luz cálida muy sutil en la parte superior.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, -0.2),
          colors: [palette.parchment, palette.background],
        ),
      ),
      child: ListView(
        key: const Key('reading-list'),
        padding: const EdgeInsets.fromLTRB(26, 28, 26, 48),
        children: [
          // 1. Lo que dijo Dios
          FadeSlideIn(child: SectionLabel('${passage.speaker} dijo')),
          const SizedBox(height: 22),
          GoldenShimmer(
            delay: d(700),
            child: FadeSlideIn(
              delay: d(150),
              duration: d(1400),
              child: Text(
                '«${passage.quote}»',
                style: theme.textTheme.headlineMedium?.copyWith(
                  // Pasajes largos: letra algo menor para leer con calma.
                  fontSize: passage.quote.length > 700
                      ? 21
                      : passage.quote.length > 280
                      ? 24
                      : 29,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          // 2. Referencia bíblica
          FadeSlideIn(
            delay: d(700),
            child: Row(
              children: [
                Container(width: 26, height: 1.2, color: palette.gold),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    passage.reference,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: palette.gold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Los versículos completos: toda la conversación, sin cortes.
          FadeSlideIn(
            delay: d(850),
            child: FullVersesCard(passage: passage),
          ),
          const SizedBox(height: 32),
          // 3. ¿A quién habló Dios?
          FadeSlideIn(
            delay: d(1000),
            child: _RecipientCard(passage: passage),
          ),
          const SizedBox(height: 14),
          // 4. Contexto histórico
          FadeSlideIn(
            delay: d(1150),
            child: ExpandableCard(
              title: 'Contexto histórico',
              icon: Icons.account_balance_outlined,
              text: passage.historicalContext,
            ),
          ),
          const SizedBox(height: 14),
          // 5. ¿Qué estaba pasando?
          FadeSlideIn(
            delay: d(1250),
            child: ExpandableCard(
              title: '¿Qué estaba pasando?',
              icon: Icons.hourglass_empty_rounded,
              text: passage.situation,
            ),
          ),
          const SizedBox(height: 28),
          // 6. Problema que Dios estaba tratando
          FadeSlideIn(
            delay: d(1350),
            child: ProblemCard(items: passage.problems, text: passage.problem),
          ),
          const SizedBox(height: 40),
          // 7. Explicación sencilla
          ReadingSection(
            label: 'Explicación sencilla',
            text: passage.explanation,
          ),
          const SizedBox(height: 36),
          // 8. Aplicación para hoy
          ApplicationCard(text: passage.application),
          const SizedBox(height: 28),
          // 9. Oración de liberación
          PrayerBlock(
            prayer: passage.prayer,
            prayed: prayed,
            onAmen: () {
              ref.read(progressProvider.notifier).markPrayed(passage.id);
              HapticFeedback.mediumImpact();
              Analytics.log('prayer_done', {'id': passage.id});
            },
          ),
          const SizedBox(height: 32),
          // Botón especial
          FilledButton.icon(
            onPressed: () => context.push(Routes.personalize(passage.id)),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Necesito esta palabra para mí'),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in passage.categories)
                if (content.categoryById(id) case final category?)
                  ActionChip(
                    avatar: Icon(category.icon, size: 16, color: palette.gold),
                    label: Text(category.title),
                    onPressed: () => context.push(Routes.category(category.id)),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({required this.passage});

  final Passage passage;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final initial = passage.recipient.isEmpty
        ? '·'
        : passage.recipient.characters.first.toUpperCase();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: passage.people.isEmpty
            ? null
            : () => context.push(
                Routes.searchWith(
                  query: passage.people.first,
                  mode: SearchMode.person,
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [palette.goldSoft, palette.blueSoft],
                  ),
                  border: Border.all(
                    color: palette.gold.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  initial,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: palette.gold,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿A quién habló ${Edition.current.speaker}?',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(passage.recipient, style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              if (passage.people.isNotEmpty)
                Tooltip(
                  message: 'Más palabras dirigidas a ${passage.people.first}',
                  child: Icon(
                    Icons.person_search_outlined,
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
