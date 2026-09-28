import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_config.dart';

/// Descarga contenido actualizado desde Cloud Firestore.
///
/// Permite publicar nuevos pasajes o correcciones sin sacar una versión nueva
/// en Google Play. Solo se usa si Firebase está configurado.
class RemoteContentSource {
  RemoteContentSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Devuelve el JSON remoto solo si su versión es mayor que [currentVersion].
  Future<Map<String, dynamic>?> fetchIfNewer(int currentVersion) async {
    final ref = _firestore
        .collection(AppConfig.firestoreContentCollection)
        .doc(AppConfig.firestoreContentDoc);
    final snapshot = await ref.get().timeout(const Duration(seconds: 10));
    final data = snapshot.data();
    if (data == null) return null;
    final version = (data['version'] as num?)?.toInt() ?? 0;
    return version > currentVersion ? data : null;
  }
}
