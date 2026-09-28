import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_config.dart';

/// Descarga contenido actualizado desde Cloud Firestore.
///
/// Estructura (ver tool/firestore/seed.mjs):
///   content/current                 → { version, translation, eras, categories, chunks }
///   content/current/chunks/{0..n-1} → { passages: [...] }
/// Los pasajes van en partes porque un documento admite como máximo 1 MiB.
///
/// Permite publicar nuevas palabras o correcciones sin sacar una versión en
/// Google Play. Solo se usa si Firebase está configurado.
class RemoteContentSource {
  RemoteContentSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Devuelve el JSON remoto completo solo si su versión es mayor que [currentVersion].
  Future<Map<String, dynamic>?> fetchIfNewer(int currentVersion) async {
    final ref = _firestore
        .collection(AppConfig.firestoreContentCollection)
        .doc(AppConfig.firestoreContentDoc);
    final snapshot = await ref.get().timeout(const Duration(seconds: 10));
    final data = snapshot.data();
    if (data == null) return null;
    final version = (data['version'] as num?)?.toInt() ?? 0;
    if (version <= currentVersion) return null;

    final chunks = (data['chunks'] as num?)?.toInt();
    if (chunks == null) return data; // formato antiguo: todo en un documento
    final passages = <dynamic>[];
    for (var i = 0; i < chunks; i++) {
      final part = await ref
          .collection('chunks')
          .doc('$i')
          .get()
          .timeout(const Duration(seconds: 20));
      final list = part.data()?['passages'] as List<dynamic>?;
      if (list == null) return null; // publicación incompleta: se ignora
      passages.addAll(list);
    }
    return {...data, 'passages': passages}..remove('chunks');
  }
}
