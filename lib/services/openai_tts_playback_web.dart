// Web 専用: Blob + AudioElement で MP3 再生（OpenAI TTS 用）
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'analytics_service.dart';
import 'tts_playback_blocked_exception.dart';

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

/// 再生エラー種別を分類（観測用）
String _classifyPlayError(dynamic e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('notallowed') || msg.contains('not allowed')) {
    return 'not_allowed';
  }
  if (msg.contains('decode') || msg.contains('mediasource')) {
    return 'decode';
  }
  if (msg.contains('network') || msg.contains('fetch') || msg.contains('failed to load')) {
    return 'network';
  }
  return 'other';
}

/// MediaError の code を分類
String _classifyMediaError(int code) {
  switch (code) {
    case 2:
      return 'network';
    case 3:
      return 'decode';
    case 4:
      return 'decode';
    default:
      return 'other';
  }
}

/// URL から再生（キャッシュヒット時など）
Future<void> playFromUrl(String url, {String? ttsSessionId}) async {
  stop();
  _currentUrl = url;
  _current = html.AudioElement()..src = url;

  final completer = Completer<void>();

  void logAndCompleteError(String errorType, [String? urlHost]) {
    AnalyticsService().logTtsWebPlayError(
      errorType: errorType,
      ttsSessionId: ttsSessionId,
      urlHost: urlHost ?? (url.startsWith('http') ? Uri.tryParse(url)?.host : null),
    );
  }

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
    final el = target is html.AudioElement ? target : null;
    final errorType = el?.error != null
        ? _classifyMediaError(el!.error!.code)
        : 'other';
    logAndCompleteError(errorType, Uri.tryParse(url)?.host);
    if (kDebugMode) {
      debugPrint('OpenAI TTS (Web) playback error: $detail');
    }
    final currentEl = _current;
    if (currentEl != null) {
      currentEl.pause();
      currentEl.src = '';
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
    final errorType = _classifyPlayError(e);
    logAndCompleteError(errorType, Uri.tryParse(url)?.host);
    if (kDebugMode) {
      if (errorType == 'not_allowed') {
        debugPrint(
          'OpenAI TTS (Web): 再生がブロックされました（ブラウザのオートプレイ制限）。'
          '再生ボタンをタップした直後のみ再生可能です。',
        );
      }
      debugPrint('OpenAI TTS (Web) play() error: $e');
    }
    _currentUrl = null;
    _current = null;
    if (errorType == 'not_allowed') {
      throw TtsPlaybackBlockedException('not_allowed');
    }
    throw Exception('Audio playback error: $e');
  }
  await completer.future.timeout(const Duration(seconds: 60));
}

Future<void> playBytes(List<int> bytes, {String? ttsSessionId}) async {
  stop();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'audio/mpeg');
  final url = html.Url.createObjectUrlFromBlob(blob);
  _currentUrl = url;
  _current = html.AudioElement()..src = url;

  final completer = Completer<void>();

  void logAndCompleteErrorBytes(String errorType) {
    AnalyticsService().logTtsWebPlayError(
      errorType: errorType,
      ttsSessionId: ttsSessionId,
    );
  }

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
    final el = target is html.AudioElement ? target : null;
    final errorType = el?.error != null
        ? _classifyMediaError(el!.error!.code)
        : 'other';
    logAndCompleteErrorBytes(errorType);
    if (kDebugMode) {
      debugPrint('OpenAI TTS (Web) playback error: $detail');
    }
    final currentEl = _current;
    if (currentEl != null) {
      currentEl.pause();
      currentEl.src = '';
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
    final errorType = _classifyPlayError(e);
    logAndCompleteErrorBytes(errorType);
    if (kDebugMode) {
      if (errorType == 'not_allowed') {
        debugPrint(
          'OpenAI TTS (Web): 再生がブロックされました（ブラウザのオートプレイ制限）。'
          '再生ボタンをタップした直後のみ再生可能です。',
        );
      }
      debugPrint('OpenAI TTS (Web) play() error: $e');
    }
    _revoke();
    if (errorType == 'not_allowed') {
      throw TtsPlaybackBlockedException('not_allowed');
    }
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
