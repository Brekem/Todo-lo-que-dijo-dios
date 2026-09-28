import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/models/content_bundle.dart';

/// Construye [builder] cuando el contenido está listo.
class AsyncContent extends ConsumerWidget {
  const AsyncContent({super.key, required this.builder});

  final Widget Function(BuildContext context, ContentBundle content) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    return switch (content) {
      AsyncData(:final value) => builder(context, value),
      AsyncError(:final error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No se pudo cargar el contenido.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
    };
  }
}
