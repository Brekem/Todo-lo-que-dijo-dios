import 'package:flutter/foundation.dart';

import '../models/content_bundle.dart';
import '../sources/local_content_source.dart';
import '../sources/remote_content_source.dart';

/// Estrategia offline-first:
/// 1. Usa la versión más reciente disponible en el dispositivo (caché o asset).
/// 2. En segundo plano consulta Firestore; si hay una versión mayor, la guarda.
class ContentRepository {
  ContentRepository({required this.local, this.remote});

  final LocalContentSource local;
  final RemoteContentSource? remote;

  Future<ContentBundle> load() async {
    final bundled = await local.loadBundled();
    final cached = await local.loadCached();
    if (cached != null && cached.version > bundled.version) return cached;
    return bundled;
  }

  /// Devuelve el contenido nuevo si se descargó, o `null`.
  Future<ContentBundle?> syncFromRemote(int currentVersion) async {
    final source = remote;
    if (source == null) return null;
    try {
      final json = await source.fetchIfNewer(currentVersion);
      if (json == null) return null;
      final bundle = ContentBundle.fromJson(json);
      await local.saveCache(json);
      return bundle;
    } catch (e, st) {
      debugPrint('Sincronización de contenido omitida: $e\n$st');
      return null;
    }
  }
}
