import 'dart:convert';
import 'dart:io';

import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';

/// Carga el contenido real empaquetado en la app.
ContentBundle loadContent() => ContentBundle.fromJson(
  jsonDecode(File('assets/data/content.json').readAsStringSync())
      as Map<String, dynamic>,
);
