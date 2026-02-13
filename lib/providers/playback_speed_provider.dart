import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/playback_speed_service.dart';
import '../services/tts_service.dart';

final playbackSpeedProvider =
    StateNotifierProvider<PlaybackSpeedNotifier, double>((ref) {
  return PlaybackSpeedNotifier();
});

class PlaybackSpeedNotifier extends StateNotifier<double> {
  PlaybackSpeedNotifier() : super(1.0) {
    _load();
  }

  Future<void> _load() async {
    state = await PlaybackSpeedService.getSpeed();
    TtsService.setDefaultSpeechRate(state);
  }

  Future<void> setSpeed(double speed) async {
    state = speed;
    await PlaybackSpeedService.setSpeed(speed);
    TtsService.setDefaultSpeechRate(speed);
  }
}
