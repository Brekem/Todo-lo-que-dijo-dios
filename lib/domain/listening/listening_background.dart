import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'background_audio.dart';
import 'listening_controller.dart';

/// Reproducción en segundo plano de Android (`null` en los tests y si no se
/// pudo iniciar).
final backgroundAudioProvider = Provider<BackgroundAudio?>((ref) => null);

/// Mantiene al día la notificación de lo que se escucha y obedece sus
/// botones, los de los auriculares y las pausas por llamadas.
final listeningBackgroundProvider = Provider<void>((ref) {
  final audio = ref.watch(backgroundAudioProvider);
  if (audio == null) return;
  final controller = ref.read(listeningProvider.notifier);
  var shown = false;
  // Se cerró desde la notificación: no volver a mostrarla hasta que se
  // vuelva a escuchar.
  var dismissed = false;

  audio.attach((
    play: () async {
      dismissed = false;
      await controller.play();
    },
    pause: controller.pause,
    next: controller.nextWord,
    previous: controller.previousWord,
    stop: () async {
      dismissed = true;
      await controller.stop();
      shown = false;
      await audio.hide();
    },
  ));

  void sync(ListeningState s) {
    if (s.isPlaying) dismissed = false;
    final content = ref.read(contentProvider).value;
    if (!s.isActive || dismissed || content == null) {
      if (shown) {
        shown = false;
        audio.hide();
      }
      return;
    }
    final total = content.passages.length;
    final index = s.passageIndex.clamp(0, total - 1);
    final length = s.length(total);
    shown = true;
    audio.show(
      playing: s.isPlaying,
      title: content.passages[index].reference,
      subtitle: [
        s.fromSearch
            ? 'Búsqueda: ${s.step + 1} de $length'
            : 'Palabra ${index + 1} de $total',
        s.section.title,
      ].join(' · '),
    );
  }

  ref.listen(
    listeningProvider.select(
      (s) => (s.status, s.passageIndex, s.step, s.section),
    ),
    (_, _) => sync(ref.read(listeningProvider)),
    fireImmediately: true,
  );
});
