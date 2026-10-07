import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/background_audio.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/listening_background.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/listening_controller.dart';

import 'listening_test.dart';

/// Notificación falsa: guarda lo que se mostró y permite pulsar sus botones.
class FakeBackgroundAudio implements BackgroundAudio {
  late BackgroundCommands commands;
  ({bool playing, String title, String subtitle})? shown;
  int hides = 0;

  @override
  void attach(BackgroundCommands commands) => this.commands = commands;

  @override
  Future<void> show({
    required bool playing,
    required String title,
    required String subtitle,
  }) async => shown = (playing: playing, title: title, subtitle: subtitle);

  @override
  Future<void> hide() async {
    shown = null;
    hides++;
  }
}

void main() {
  test(
    'la notificación muestra lo que se escucha y sus botones mandan',
    () async {
      final audio = FakeBackgroundAudio();
      final (c, tts, _) = await setUpContainer(const {}, [
        backgroundAudioProvider.overrideWithValue(audio),
      ]);
      c.read(listeningBackgroundProvider);
      final ctrl = c.read(listeningProvider.notifier);
      expect(audio.shown, isNull);

      await ctrl.playFrom(0);
      await settle();
      expect(audio.shown?.playing, isTrue);
      expect(audio.shown?.title, 'Génesis 1:3');
      expect(audio.shown?.subtitle, startsWith('Palabra 1 de '));

      // Pausa desde la notificación (o por una llamada): sigue visible.
      await audio.commands.pause();
      await settle();
      expect(c.read(listeningProvider).isPlaying, isFalse);
      expect(audio.shown?.playing, isFalse);

      // Al colgar, sigue leyendo.
      await audio.commands.play();
      await settle();
      expect(c.read(listeningProvider).isPlaying, isTrue);
      expect(audio.shown?.playing, isTrue);

      // Siguiente palabra desde la notificación.
      await audio.commands.next();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 1);
      expect(audio.shown?.subtitle, startsWith('Palabra 2 de '));

      // Cerrar: se detiene, guarda dónde iba y quita la notificación.
      await audio.commands.stop();
      await settle();
      expect(c.read(listeningProvider).isPlaying, isFalse);
      expect(c.read(listeningProvider).hasSavedPosition, isTrue);
      expect(audio.shown, isNull);
      expect(tts.speaking, isFalse);

      // Volver a escuchar la muestra otra vez.
      await ctrl.play();
      await settle();
      expect(audio.shown?.playing, isTrue);
      await ctrl.pause();
    },
  );
}
