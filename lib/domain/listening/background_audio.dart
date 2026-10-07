import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Órdenes que llegan de fuera de la app: la notificación, la pantalla de
/// bloqueo, los auriculares o una llamada.
typedef BackgroundCommands = ({
  Future<void> Function() play,
  Future<void> Function() pause,
  Future<void> Function() next,
  Future<void> Function() previous,
  Future<void> Function() stop,
});

/// Lo que Android necesita saber para que la lectura siga con la pantalla
/// apagada o en otra app, y se calle durante las llamadas.
abstract interface class BackgroundAudio {
  void attach(BackgroundCommands commands);

  /// Muestra (o actualiza) la notificación de lo que se escucha.
  Future<void> show({
    required bool playing,
    required String title,
    required String subtitle,
  });

  /// Quita la notificación y deja de reproducir en segundo plano.
  Future<void> hide();
}

/// Servicio de reproducción de Android (como una app de música o de
/// pódcast) y foco de audio: pausa en las llamadas y sigue al colgar.
class AndroidBackgroundAudio implements BackgroundAudio {
  AndroidBackgroundAudio._(this._handler, this._session);

  final _ListeningHandler _handler;
  final AudioSession _session;
  BackgroundCommands? _commands;
  bool _playing = false;

  /// Al terminar una llamada se sigue leyendo solo si se pausó por ella.
  bool _resumeAfterInterruption = false;

  static Future<AndroidBackgroundAudio?> init({
    required String channelId,
  }) async {
    try {
      final handler = await AudioService.init(
        builder: _ListeningHandler.new,
        config: AudioServiceConfig(
          androidNotificationChannelId: channelId,
          androidNotificationChannelName: 'Escuchar',
          androidNotificationChannelDescription:
              'Controles de la lectura en voz alta',
          // Pausado sigue en primer plano: así puede volver a leer al colgar
          // una llamada aunque la app no esté a la vista.
          androidStopForegroundOnPause: false,
        ),
      );
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      final audio = AndroidBackgroundAudio._(handler, session);
      handler.audio = audio;
      session.interruptionEventStream.listen(audio._onInterruption);
      session.becomingNoisyEventStream.listen((_) {
        // Se desconectaron los auriculares: no seguir por el altavoz.
        if (audio._playing) audio._commands?.pause();
      });
      return audio;
    } catch (e) {
      debugPrint('Sin reproducción en segundo plano: $e');
      return null;
    }
  }

  Future<void> _onInterruption(AudioInterruptionEvent event) async {
    if (event.begin) {
      if (event.type == AudioInterruptionType.duck || !_playing) return;
      // Llamada, alarma u otra app con sonido.
      _resumeAfterInterruption = event.type == AudioInterruptionType.pause;
      await _commands?.pause();
    } else {
      if (_resumeAfterInterruption &&
          event.type != AudioInterruptionType.duck) {
        _resumeAfterInterruption = false;
        await _commands?.play();
      }
    }
  }

  @override
  void attach(BackgroundCommands commands) => _commands = commands;

  @override
  Future<void> show({
    required bool playing,
    required String title,
    required String subtitle,
  }) async {
    if (playing && !_playing) {
      _resumeAfterInterruption = false;
      await _session.setActive(true);
    }
    _playing = playing;
    _handler.mediaItem.add(
      MediaItem(id: title, title: title, artist: subtitle),
    );
    _handler.playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.playPause},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: playing,
      ),
    );
  }

  @override
  Future<void> hide() async {
    _playing = false;
    _handler.playbackState.add(
      PlaybackState(processingState: AudioProcessingState.idle),
    );
    await _session.setActive(false);
  }
}

class _ListeningHandler extends BaseAudioHandler {
  AndroidBackgroundAudio? audio;

  BackgroundCommands? get _commands => audio?._commands;

  @override
  Future<void> play() async => _commands?.play();

  @override
  Future<void> pause() async => _commands?.pause();

  @override
  Future<void> skipToNext() async => _commands?.next();

  @override
  Future<void> skipToPrevious() async => _commands?.previous();

  @override
  Future<void> stop() async => _commands?.stop();

  /// Al cerrar la app desde «recientes» sigue leyendo (como una app de
  /// música); si estaba en pausa, se quita la notificación.
  @override
  Future<void> onTaskRemoved() async {
    if (audio?._playing != true) await _commands?.stop();
  }
}
