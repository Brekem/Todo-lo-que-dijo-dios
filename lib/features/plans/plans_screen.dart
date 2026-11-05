import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/boricua_resources.dart';

/// Planes de lectura.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(boricuaResourcesProvider).value;
    final progress = ref.watch(bibleUserProvider.select((d) => d.plans));
    final palette = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Planes de lectura')),
      body: resources == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final p in resources.plans)
                  Card(
                    child: ListTile(
                      key: Key('plan-${p.id}'),
                      title: Text(p.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.description),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value:
                                (progress[p.id]?.length ?? 0) / p.days.length,
                            color: palette.gold,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progress[p.id]?.length ?? 0} de ${p.days.length} días',
                          ),
                        ],
                      ),
                      onTap: () => context.push(Routes.plan(p.id)),
                    ),
                  ),
              ],
            ),
    );
  }
}

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(boricuaResourcesProvider).value;
    final bible = ref.watch(bibleProvider).value;
    final done =
        ref.watch(bibleUserProvider.select((d) => d.plans[planId])) ?? {};
    final ReadingPlan? plan = resources?.plan(planId);
    if (plan == null || bible == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final next = List.generate(
      plan.days.length,
      (i) => i,
    ).where((i) => !done.contains(i)).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: plan.days.length,
        itemBuilder: (context, i) {
          final day = plan.days[i];
          final label = day
              .map(
                (c) => '${bible.book(c.bookId)?.name ?? c.bookId} ${c.chapter}',
              )
              .join(' · ');
          return CheckboxListTile(
            key: Key('plan-day-$i'),
            value: done.contains(i),
            selected: i == next,
            title: Text('Día ${i + 1}'),
            subtitle: Text(label),
            secondary: IconButton(
              tooltip: 'Leer',
              icon: const Icon(Icons.menu_book),
              onPressed: () => context.push(
                Routes.chapter(day.first.bookId, day.first.chapter),
              ),
            ),
            onChanged: (_) =>
                ref.read(bibleUserProvider.notifier).togglePlanDay(plan.id, i),
          );
        },
      ),
    );
  }
}
