// Web 専用: Blob + AudioElement で MP3 再生（OpenAI TTS 用）
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

html.AudioElement? _current;
String? _currentUrl;
html.AudioElement? _stoppedElement;

String _audioErrorDetail(html.Event e) {
  final el = e.target;
  if (el is html.AudioElement && el.error != null) {
    final err = el.error!;
    return 'code=${err.code} message=${err.message}';
  }
  return 'type=${e.type}';
}

/// URL から再生（キャッシュヒット時など）
Future<void> playFromUrl(String url) async {
  stop();
  _currentUrl = url;
  _current = html.AudioElement()..src = url;

  final completer = Completer<void>();

  _current!.onEnded.listen((_) {
    _currentUrl = null;
    _current = null;
    if (!completer.isCompleted) completer.complete();
  });
  _current!.onError.listen((html.Event e) {
    final target = e.target;
    final detail = _audioErrorDetail(e);
    final isStoppedElement = target == _stoppedElement;
    final isEmptySrc = detail.contains('Empty src') || detail.contains('empty src');
    if (isStoppedElement || isEmptySrc) {
      _stoppedElement = null;
      _currentUrl = null;
      _current = null;
      if (!completer.isCompleted) completer.complete();
      return;
    }
    if (kDebugMode) {
      debugPrint('OpenAI TTS (Web) playback error: $detail');
    }
    final el = _current;
    if (el != null) {
      el.pause();
      el.src = '';
    }
    _currentUrl = null;
    _current = null;
    if (!completer.isCompleted) {
      completer.completeError(Exception('Audio playback error: $detail'));
    }
  });

  await _current!.onCanPlay.first.timeout(const Duration(seconds: 10));
  try {
    await _current!.play();
  } catch (e) {
    final msg = e.toString().toLowerCase();
    if (kDebugMode) {
      if (msg.contains('notallowed') || msg.contains('not allowed')) {
        debugPrint(
          'OpenAI TTS (Web): 再生がブロックされました（ブラウザのオートプレイ制限）。'
          '再生ボタンをタップした直後のみ再生可能です。',
        );
      }
      debugPrint('OpenAI TTS (Web) play() error: $e');
    }
    _currentUrl = null;
    _current = null;
    throw Exception('Audio playback error: $e');
  }
  await completer.future.timeout(const Duration(seconds: 60));
}

Future<void> playBytes(List<int> bytes) async {
  stop();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'audio/mpeg');
  final url = html.Url.createObjectUrlFromBlob(blob);
  _currentUrl = url;
  _current = html.AudioElement()..src = url;

  final completer = Completer<void>();

  _current!.onEnded.listen((_) {
    _revoke();
    if (!completer.isCompleted) completer.complete();
  });
  _current!.onError.listen((html.Event e) {
    final target = e.target;
    final detail = _audioErrorDetail(e);
    final isStoppedElement = target == _stoppedElement;
    final isEmptySrc = detail.contains('Empty src') || detail.contains('empty src');
    if (isStoppedElement || isEmptySrc) {
      _stoppedElement = null;
      if (!completer.isCompleted) completer.complete();
      return;
    }
    if (kDebugMode) {
      debugPrint('OpenAI TTS (Web) playback error: $detail');
    }
    final el = _current;
    if (el != null) {
      el.pause();
      el.src = '';
    }
    _revoke();
    if (!completer.isCompleted) {
      completer.completeError(Exception('Audio playback error: $detail'));
    }
  });

  await _current!.onCanPlay.first.timeout(const Duration(seconds: 10));
  try {
    await _current!.play();
  } catch (e) {
    final msg = e.toString().toLowerCase();
    if (kDebugMode) {
      if (msg.contains('notallowed') || msg.contains('not allowed')) {
        debugPrint(
          'OpenAI TTS (Web): 再生がブロックされました（ブラウザのオートプレイ制限）。'
          '再生ボタンをタップした直後のみ再生可能です。',
        );
      }
      debugPrint('OpenAI TTS (Web) play() error: $e');
    }
    _revoke();
    throw Exception('Audio playback error: $e');
  }
  await completer.future.timeout(const Duration(seconds: 30));
}

void _revoke() {
  if (_currentUrl != null) {
    // オブジェクト URL の場合のみ revoke（外部 URL は revoke しない）
    try {
      if (_currentUrl!.startsWith('blob:')) {
        html.Url.revokeObjectUrl(_currentUrl!);
      }
    } catch (_) {}
    _currentUrl = null;
  }
  _current = null;
}

void stop() {
  final el = _current;
  if (el != null) {
    _stoppedElement = el;
    el.pause();
    el.src = '';
  }
  _revoke();
}
