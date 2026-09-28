import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/era.dart';
import '../../data/models/passage.dart';
import '../../shared/widgets/async_content.dart';

/// "Recorrido de la Voz de Dios": línea de tiempo con cada momento en que Dios habló.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncContent(
          builder: (context, content) => _Timeline(content: content),
        ),
      ),
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline({required this.content});

  final ContentBundle content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final read = ref.watch(progressProvider.select((p) => p.readIds));
    final eras = content.eras
        .where((e) => content.byEra(e.id).isNotEmpty)
        .toList();
    final rows = <_Row>[];
    for (final (i, era) in eras.indexed) {
      final passages = content.byEra(era.id);
      rows.add(_EraRow(era, passages));
      for (final (j, p) in passages.indexed) {
        rows.add(
          _WordRow(p, last: i == eras.length - 1 && j == passages.length - 1),
        );
      }
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recorrido de la\nVoz de Dios',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Recorre toda la Biblia viendo únicamente cuándo Dios habló. '
                  '${read.length} de ${content.passages.length} palabras escuchadas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.warmGray,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.push(Routes.listen),
                  icon: const Icon(Icons.headphones_rounded),
                  label: const Text('Escuchar el recorrido completo'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: eras.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ActionChip(
                      label: Text(eras[i].title),
                      onPressed: () {
                        final first = content.byEra(eras[i].id).first;
                        context.push(Routes.passage(first.id));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Lista perezosa: con cientos de palabras solo se construye lo visible.
        SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) => switch (rows[i]) {
            _EraRow(:final era, :final passages) => _EraHeader(
              era: era,
              done: passages.where((p) => read.contains(p.id)).length,
              total: passages.length,
            ),
            _WordRow(:final passage, :final last) => Padding(
              padding: const EdgeInsets.only(left: 24, right: 20),
              child: _TimelineWord(
                passage: passage,
                read: read.contains(passage.id),
                drawLine: !last,
              ),
            ),
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

sealed class _Row {
  const _Row();
}

class _EraRow extends _Row {
  const _EraRow(this.era, this.passages);
  final Era era;
  final List<Passage> passages;
}

class _WordRow extends _Row {
  const _WordRow(this.passage, {required this.last});
  final Passage passage;
  final bool last;
}

class _EraHeader extends StatelessWidget {
  const _EraHeader({
    required this.era,
    required this.done,
    required this.total,
  });

  final Era era;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.background,
                      border: Border.all(color: palette.gold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: palette.glow,
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1.2,
                      color: palette.gold.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      era.period.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(era.title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      era.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.warmGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$done / $total escuchadas',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineWord extends StatelessWidget {
  const _TimelineWord({
    required this.passage,
    required this.read,
    required this.drawLine,
  });

  final Passage passage;
  final bool read;
  final bool drawLine;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 1.2,
                      color: drawLine
                          ? palette.gold.withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: read ? palette.gold : palette.background,
                      border: Border.all(
                        color: palette.gold.withValues(alpha: 0.8),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push(Routes.passage(passage.id)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${passage.reference}  ·  ${passage.recipient}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: palette.gold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '«${passage.quote}»',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
