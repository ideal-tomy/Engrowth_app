// モバイル/デスクトップ用: just_audio で MP3 再生
import 'dart:async';

import 'package:just_audio/just_audio.dart';

final AudioPlayer _player = AudioPlayer();

/// URL から再生（キャッシュヒット時など）
Future<void> playFromUrl(String url) async {
  await _player.stop();
  await _player.setUrl(url);
  await _player.play();
  await _player.playerStateStream
      .where((s) =>
          s.processingState == ProcessingState.completed ||
          s.processingState == ProcessingState.idle)
      .first
      .timeout(const Duration(seconds: 60));
}

Future<void> playBytes(List<int> bytes) async {
  await _player.stop();
  final uri = Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg');
  await _player.setUrl(uri.toString());
  await _player.play();
  await _player.playerStateStream
      .where((s) =>
          s.processingState == ProcessingState.completed ||
          s.processingState == ProcessingState.idle)
      .first
      .timeout(const Duration(seconds: 30));
}

void stop() {
  _player.stop();
}
