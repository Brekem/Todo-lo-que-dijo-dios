import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_user_data.dart';

/// Guarda notas, resaltados, marcadores, historial y progreso en el teléfono.
class BibleUserRepository {
  BibleUserRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'bible_user_data_v1';
  static const _lastKey = 'bible_last_chapter';

  BibleUserData load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const BibleUserData();
    try {
      return BibleUserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const BibleUserData();
    }
  }

  Future<void> save(BibleUserData data) =>
      _prefs.setString(_key, jsonEncode(data.toJson()));

  /// Último capítulo abierto («jua.3»).
  String? get lastChapter => _prefs.getString(_lastKey);
  Future<void> setLastChapter(String key) => _prefs.setString(_lastKey, key);
}

/// Sincronización en la nube (Firebase Auth + Firestore). Si Firebase no está
/// configurado no se usa y todo sigue en el teléfono.
abstract interface class BibleCloudSync {
  /// Lo guardado en la nube, o `null` si no hay nada.
  Future<BibleUserData?> pull();
  Future<void> push(BibleUserData data);
}

/// users/{uid}: un documento por persona. La cuenta empieza anónima; se puede
/// vincular a correo o Google sin perder datos (ver docs/biblia-boricua).
class FirestoreBibleSync implements BibleCloudSync {
  FirestoreBibleSync({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<DocumentReference<Map<String, dynamic>>> _doc() async {
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user!;
    return _db.collection('users').doc(user.uid);
  }

  @override
  Future<BibleUserData?> pull() async {
    try {
      final snap = await (await _doc()).get();
      final data = snap.data()?['bible'] as Map<String, dynamic>?;
      return data == null ? null : BibleUserData.fromJson(data);
    } catch (e) {
      debugPrint('Sin sincronización: $e');
      return null;
    }
  }

  @override
  Future<void> push(BibleUserData data) async {
    try {
      await (await _doc()).set({
        'bible': data.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('No se pudo sincronizar: $e');
    }
  }
}
