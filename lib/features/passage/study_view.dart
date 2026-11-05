import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/passage.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/glossary_chips.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/verses_text.dart';
import 'reading_blocks.dart';

/// Estudio boricua de un pasaje: paráfrasis versículo por versículo y las
/// preguntas de la Escuela: ¿qué pasó?, ¿qué enseña de Dios, del ser humano y
/// de Jesucristo?, ¿cómo lo aplico? y una oración.
class StudyView extends ConsumerWidget {
  const StudyView({super.key, required this.passage, required this.content});

  final Passage passage;
  final ContentBundle content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final study = passage.study!;
    final prayed = ref.watch(
      progressProvider.select((p) => p.prayedIds.contains(passage.id)),
    );
    Widget gap(double h) => SizedBox(height: h);
    Widget teaching(String title, IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ExpandableCard(
        title: title,
        icon: icon,
        text: text,
        initiallyExpanded: true,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, -0.2),
          colors: [palette.parchment, palette.background],
        ),
      ),
      child: ListView(
        key: const Key('reading-list'),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          FadeSlideIn(
            child: Text(
              passage.reference,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: palette.gold,
              ),
            ),
          ),
          gap(20),
          // 1. Texto bíblico
          FadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: FullVersesCard(passage: passage),
          ),
          gap(24),
          // 2. Paráfrasis boricua
          const SectionLabel('Paráfrasis boricua'),
          gap(12),
          Container(
            key: const Key('study-paraphrase'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.blueSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in study.paraphrase.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${e.key} ',
                            style: TextStyle(
                              color: palette.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: e.value),
                        ],
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(height: 1.5),
                    ),
                  ),
              ],
            ),
          ),
          gap(28),
          ExpandableCard(
            title: 'Contexto',
            icon: Icons.account_balance_outlined,
            text: passage.historicalContext,
          ),
          gap(28),
          ReadingSection(label: '¿Qué pasó aquí?', text: passage.situation),
          gap(28),
          ReadingSection(
            label: 'Explicación simple',
            text: passage.explanation,
          ),
          GlossaryChips(
            text:
                '${passage.explanation} ${study.aboutGod} ${study.aboutHumans} ${study.aboutChrist}',
          ),
          gap(28),
          teaching(
            '¿Qué nos enseña acerca de Dios?',
            Icons.wb_sunny_outlined,
            study.aboutGod,
          ),
          teaching(
            '¿Qué nos enseña acerca del ser humano?',
            Icons.person_outline,
            study.aboutHumans,
          ),
          teaching(
            '¿Qué nos enseña acerca de Jesucristo?',
            Icons.add,
            study.aboutChrist,
          ),
          gap(14),
          ApplicationCard(
            title: '¿Cómo lo aplico hoy?',
            text: passage.application,
          ),
          gap(28),
          PrayerBlock(
            title: 'Oración sugerida',
            prayer: passage.prayer,
            prayed: prayed,
            onAmen: () {
              ref.read(progressProvider.notifier).markPrayed(passage.id);
              HapticFeedback.mediumImpact();
            },
          ),
          gap(28),
          FilledButton.icon(
            onPressed: () => context.push(Routes.personalize(passage.id)),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Necesito esta palabra para mí'),
          ),
          gap(28),
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
