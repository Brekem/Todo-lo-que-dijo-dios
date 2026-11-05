import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/bible.dart';
import '../models/boricua_resources.dart';

/// La Biblia completa y los recursos boricuas vienen empaquetados en la app:
/// se leen sin conexión. El JSON grande se decodifica fuera del hilo de la
/// pantalla.
class BibleSource {
  const BibleSource({
    this.bibleAsset = 'assets/data/biblia_rv1909.json',
    this.resourcesAsset = 'assets/data/boricua_recursos.json',
    AssetBundle? bundle,
  }) : _bundle = bundle; // ignore: prefer_initializing_formals

  final String bibleAsset;
  final String resourcesAsset;
  final AssetBundle? _bundle;

  AssetBundle get bundle => _bundle ?? rootBundle;

  Future<Bible> loadBible() async {
    final raw = await bundle.loadString(bibleAsset, cache: false);
    return compute(_decodeBible, raw);
  }

  Future<BoricuaResources> loadResources() async {
    final raw = await bundle.loadString(resourcesAsset);
    return BoricuaResources.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

Bible _decodeBible(String raw) =>
    Bible.fromJson(jsonDecode(raw) as Map<String, dynamic>);
