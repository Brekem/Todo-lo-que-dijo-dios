import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../models/content_bundle.dart';

/// Lee el contenido empaquetado en la app y la copia en caché descargada.
class LocalContentSource {
  LocalContentSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<ContentBundle> loadBundled() async {
    final raw = await _bundle.loadString(AppConfig.bundledContentAsset);
    return ContentBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<ContentBundle?> loadCached() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return ContentBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // Caché corrupta o ilegible: se ignora.
    }
  }

  Future<void> saveCache(Map<String, dynamic> json) async {
    final file = await _cacheFile();
    await file.writeAsString(jsonEncode(json), flush: true);
  }

  Future<File> _cacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/${AppConfig.cachedContentFile}');
  }
}
