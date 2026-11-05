import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/boricua_resources.dart';
import '../../shared/widgets/glossary_chips.dart';
import '../../shared/widgets/section_label.dart';
import '../passage/reading_blocks.dart';

/// Escuela Bíblica: siete niveles, del primer paso a ayudar a otros a crecer.
class SchoolScreen extends ConsumerWidget {
  const SchoolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(boricuaResourcesProvider);
    final done = ref.watch(bibleUserProvider.select((d) => d.lessonsDone));
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escuela Bíblica'),
        actions: [
          IconButton(
            tooltip: 'Teología simple',
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => context.push(Routes.glossary),
          ),
        ],
      ),
      body: resources.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) {
          final total = r.school.fold<int>(0, (n, l) => n + l.lessons.length);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(
                'Aprende la fe paso a paso: lecturas, explicaciones, ejemplos de '
                'la vida real y oraciones guiadas.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: done.length / total,
                color: palette.gold,
              ),
              const SizedBox(height: 4),
              Text('${done.length} de $total lecciones'),
              const SizedBox(height: 16),
              for (final level in r.school)
                _LevelCard(level: level, done: done),
            ],
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.done});

  final SchoolLevel level;
  final Set<String> done;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final finished = level.lessons.where((l) => done.contains(l.id)).length;
    return Card(
      child: ExpansionTile(
        key: Key('level-${level.level}'),
        leading: CircleAvatar(
          backgroundColor: finished == level.lessons.length
              ? palette.gold
              : palette.blueSoft,
          child: Text(
            '${level.level}',
            style: TextStyle(
              color: finished == level.lessons.length
                  ? palette.onGold
                  : palette.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text('Nivel ${level.level}: ${level.title}'),
        subtitle: Text(level.description),
        children: [
          for (final l in level.lessons)
            ListTile(
              key: Key('lesson-${l.id}'),
              leading: Icon(
                done.contains(l.id)
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: palette.gold,
              ),
              title: Text(l.title),
              subtitle: Text(l.readings.join(' · ')),
              onTap: () => context.push(Routes.lesson(l.id)),
            ),
        ],
      ),
    );
  }
}

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(boricuaResourcesProvider).value;
    final bible = ref.watch(bibleProvider).value;
    final done = ref.watch(
      bibleUserProvider.select((d) => d.lessonsDone.contains(lessonId)),
    );
    final lesson = resources?.lesson(lessonId);
    final palette = AppPalette.of(context);
    if (lesson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        children: [
          const SectionLabel('Lecturas'),
          const SizedBox(height: 8),
          for (final r in lesson.readings)
            if (bible?.parse(r) case final p?)
              Card(
                child: ListTile(
                  title: Text(r, style: TextStyle(color: palette.gold)),
                  subtitle: Text(
                    [
                      for (var v = p.from; v <= p.to; v++)
                        '$v ${p.book.chapter(p.chapter)[v - 1]}',
                    ].join(' '),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    Routes.chapter(p.book.id, p.chapter, verse: p.from),
                  ),
                ),
              ),
          const SizedBox(height: 24),
          ReadingSection(label: 'Explicación', text: lesson.explanation),
          GlossaryChips(text: lesson.explanation),
          const SizedBox(height: 28),
          ExpandableCard(
            title: 'Para reflexionar',
            icon: Icons.psychology_alt_outlined,
            text: lesson.reflection,
            initiallyExpanded: true,
          ),
          const SizedBox(height: 14),
          ApplicationCard(
            title: 'Un ejemplo de la vida real',
            text: lesson.example,
          ),
          const SizedBox(height: 28),
          PrayerBlock(title: 'Oración guiada', prayer: lesson.prayer),
          const SizedBox(height: 28),
          FilledButton.icon(
            key: const Key('lesson-done'),
            onPressed: () => ref
                .read(bibleUserProvider.notifier)
                .markLesson(lessonId, done: !done),
            icon: Icon(done ? Icons.check_circle : Icons.check),
            label: Text(done ? 'Lección completada' : 'Marcar como completada'),
          ),
        ],
      ),
    );
  }
}
